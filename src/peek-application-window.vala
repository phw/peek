/*
Peek Copyright (c) 2015 by Philipp Wolfer <ph.wolfer@gmail.com>

This file is part of Peek.

This software is licensed under the GNU General Public License
(version 3 or later). See the LICENSE file in this distribution.
*/

using Gtk;
using Cairo;

[GtkTemplate (ui = "/de/uploadedlobster/peek/application-window.ui")]
class PeekApplicationWindow : ApplicationWindow {
  public ScreenRecorder recorder { get; private set; }

  [GtkChild]
  private Widget recording_view;

  [GtkChild]
  private Button record_button;

  [GtkChild]
  private Button stop_button;

  [GtkChild]
  private Label size_indicator;

  private uint size_indicator_timeout = 0;
  private bool screen_supports_alpha = true;

  public PeekApplicationWindow (Gtk.Application application,
    ScreenRecorder recorder) {
    Object (application: application);

    this.recorder = recorder;
    this.recorder.recording_started.connect (() => {
      enter_recording_state ();
    });

    this.recorder.recording_finished.connect ((file) => {
      leave_recording_state ();

      if (file != null) {
        save_output (file);
      }
    });

    this.recorder.recording_aborted.connect ((status) => {
      stderr.printf ("Recording stopped unexpectedly with return code %i\n", status);
      leave_recording_state ();
    });

    this.set_keep_above (true);
  }

  public override void screen_changed (Gdk.Screen previous_screen) {
    var screen = this.get_screen ();
    var visual = screen.get_rgba_visual ();

    if (visual == null) {
      stderr.printf ("Screen does not support alpha channels!");
      visual = screen.get_system_visual ();
      screen_supports_alpha = false;
    }
    else {
      screen_supports_alpha = true;
    }

    this.set_visual (visual);
  }

  public override bool configure_event (Gdk.EventConfigure event) {
    if (recorder.is_recording) {
      recorder.cancel ();
    }

    return false;
  }

  public override bool delete_event (Gdk.EventAny event) {
    if (recorder.is_recording) {
      recorder.cancel ();
    }

    return false;
  }

  [GtkCallback]
  private bool on_recording_view_draw (Widget widget, Context ctx) {
    if (screen_supports_alpha) {
      ctx.set_source_rgba (0.0, 0.0, 0.0, 0.0);
    }
    else {
      ctx.set_source_rgb (0.0, 0.0, 0.0);
    }

    // Stance out the transparent inner part
    ctx.set_operator (Operator.CLEAR);
    ctx.paint ();
    ctx.fill ();

    // Set an input shape so that the recording view is not clickable
    var window_region = create_region_from_widget (widget.get_toplevel());
    var recording_viewRegion = create_region_from_widget (widget);
    window_region.subtract (recording_viewRegion);
    this.input_shape_combine_region (window_region);

    return false;
  }

  [GtkCallback]
  private void on_recording_view_size_allocate (Allocation allocation) {
    // Show the size
    if (this.get_realized ()) {
      var size_label = new StringBuilder ();
      var area = get_recording_area ();
      size_label.printf ("%i x %i", area.width, area.height);
      size_indicator.set_text (size_label.str);
      size_indicator.show ();

      if (size_indicator_timeout != 0) {
        Source.remove (size_indicator_timeout);
      }

      if (!recorder.is_recording) {
        size_indicator.opacity = 1.0;
        size_indicator_timeout = Timeout.add (800, () => {
          size_indicator_timeout = 0;
          size_indicator.opacity = 0.0;
          return false;
        });
      }
    }
  }

  [GtkCallback]
  private void on_cancel_button_clicked (Button source) {
    this.close ();
  }

  [GtkCallback]
  private void on_record_button_clicked (Button source) {
    var area = get_recording_area ();
    stdout.printf ("Recording area: %i, %i, %i, %i\n",
      area.left, area.top, area.width, area.height);
    recorder.record (area);
  }

  [GtkCallback]
  private void on_stop_button_clicked (Button source) {
    recorder.stop ();
  }

  private void enter_recording_state () {
    size_indicator.opacity = 0.0;
    record_button.hide ();
    stop_button.show ();
    freeze_window_size ();
  }

  private void leave_recording_state () {
    stop_button.hide ();
    record_button.show ();
    unfreeze_window_size ();
  }

  private void freeze_window_size () {
    var width = this.get_allocated_width ();
    var height = this.get_allocated_height ();
    this.set_size_request (width, height);
    this.resizable = false;
  }

  private void unfreeze_window_size () {
    var width = this.get_allocated_width ();
    var height = this.get_allocated_height ();
    this.set_size_request (0, 0);
    this.set_default_size (width, height);
    this.resizable = true;
  }

  private Region create_region_from_widget (Widget widget) {
    var rectangle = Cairo.RectangleInt () {
      width = widget.get_allocated_width (),
      height = widget.get_allocated_height ()
    };

    widget.translate_coordinates (widget.get_toplevel(), 0, 0, out rectangle.x, out rectangle.y);
    var region = new Region.rectangle (rectangle);

    return region;
  }

  private RecordingArea get_recording_area () {
    var area = RecordingArea() {
      width = recording_view.get_allocated_width (),
      height = recording_view.get_allocated_height ()
    };

    // Get absoulte window coordinates
    var recording_view_window = recording_view.get_window ();
    recording_view_window.get_origin (out area.left, out area.top);

    // FIXME: This is necessary for an exact position, not sure why.
    area.top -= 1;

    // Add relative widget coordinates
    int relative_left, relative_top;
    recording_view.translate_coordinates (recording_view.get_toplevel(), 0, 0,
      out relative_left, out relative_top);
    area.left += relative_left;
    area.top += relative_top;

    return area;
  }

  private void save_output (File in_file) {
    var chooser = new FileChooserDialog (
      "Select your favorite file", null, FileChooserAction.SAVE,
      "_Cancel",
      ResponseType.CANCEL,
      "_Save",
      ResponseType.ACCEPT);

    var filter = new FileFilter ();
    chooser.do_overwrite_confirmation = true;
    chooser.filter = filter;
    filter.add_mime_type ("image/gif");

    var folder = get_video_folder ();
    chooser.set_current_folder (folder);

    var now = new DateTime.now_local ();
    var default_name = now.format ("Peek %Y-%m-%d %H-%M.gif");
    chooser.set_current_name (default_name);

    if (chooser.run () == ResponseType.ACCEPT) {
      var out_file = chooser.get_file ();

      in_file.copy_async.begin (out_file, FileCopyFlags.OVERWRITE,
        Priority.DEFAULT, null, null, (obj, res) => {
          try {
            bool copy_success = in_file.copy_async.end (res);
            stdout.printf ("File saved %s: %s\n",
              copy_success.to_string (),
              out_file.get_uri ());

            in_file.delete_async.begin (Priority.DEFAULT, null, (obj, res) => {
              try {
                bool delete_success = in_file.delete_async.end (res);
                stdout.printf ("Temp file deleted: %s\n",
                  delete_success.to_string ());
              } catch (Error e) {
                stderr.printf ("Temp file delete error: %s\n", e.message);
              }
            });
          }
          catch (GLib.Error e) {
            stderr.printf ("File save error: %s\n", e.message);
           }
        });
    }

    // Close the FileChooserDialog:
    chooser.close ();
  }

  private string get_video_folder () {
    string folder;
    folder = GLib.Environment.get_user_special_dir (GLib.UserDirectory.VIDEOS);

    if (folder == null) {
      folder = GLib.Environment.get_user_special_dir (GLib.UserDirectory.PICTURES);
    }

    if (folder == null) {
      folder = GLib.Environment.get_home_dir ();
    }

    return folder;
  }
}
