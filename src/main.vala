/*
Peek Copyright (c) 2015 by Philipp Wolfer <ph.wolfer@gmail.com>

This file is part of Peek.

This software is licensed under the GNU General Public License
(version 3 or later). See the LICENSE file in this distribution.
*/

using Gtk;
using Cairo;

Window window;
Widget recording_view;
Button record_button;
Button stop_button;
Label size_indicator;
uint size_indicator_timeout = 0;
bool supports_alpha = true;
ScreenRecorder recorder = null;

public void on_application_window_screen_changed (Widget widget, Gdk.Screen oldScreen) {
  var screen = widget.get_screen ();
  var visual = screen.get_rgba_visual ();

  if (visual == null) {
    stderr.printf ("Screen does not support alpha channels!");
    visual = screen.get_system_visual ();
    supports_alpha = false;
  }
  else {
    supports_alpha = true;
  }

  widget.set_visual (visual);
}

public bool on_recording_view_draw (Widget widget, Context ctx) {
  if (supports_alpha) {
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
  window.input_shape_combine_region (window_region);

  return false;
}

public void on_recording_view_size_allocate (Widget widget, Rectangle rectangle) {
  // Show the size
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
      size_indicator.opacity = 0.0;
      return false;
    });
  }
}

public void on_application_window_delete_event (string[] args) {
  recorder.cancel ();
  Gtk.main_quit ();
}

public void on_cancel_button_clicked (Button source) {
  recorder.cancel ();
  Gtk.main_quit ();
}

public void on_record_button_clicked (Button source) {
  size_indicator.opacity = 0.0;
  record_button.hide ();
  stop_button.show ();
  freeze_window_size ();

  var area = get_recording_area ();
  stdout.printf ("Recording area: %i, %i, %i, %i\n",
    area.left, area.top, area.width, area.height);
  recorder.record (area);
}

public void on_stop_button_clicked (Button source) {
  var temp_file = recorder.stop ();
  stdout.printf ("Recording stopped\n");
  save_output (temp_file);
  stop_button.hide ();
  record_button.show ();
  unfreeze_window_size ();
}

private void freeze_window_size () {
  var width = window.get_allocated_width ();
  var height = window.get_allocated_height ();
  window.set_size_request (width, height);
  window.resizable = false;
}

private void unfreeze_window_size () {
  var width = window.get_allocated_width ();
  var height = window.get_allocated_height ();
  window.set_size_request (0, 0);
  window.set_default_size (width, height);
  window.resizable = true;
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

int main (string[] args) {
  Gtk.init (ref args);

  try {
    recorder = new ScreenRecorder();

    var builder = new Builder ();
    builder.add_from_resource ("/de/uploadedlobster/peek/peek.ui");
    builder.connect_signals (null);

    window = builder.get_object ("application_window") as Gtk.Window;
    window.set_keep_above (true);

    recording_view = builder.get_object ("recording_view") as Widget;
    record_button = builder.get_object ("record_button") as Button;
    stop_button = builder.get_object ("stop_button") as Button;
    size_indicator = builder.get_object ("size_indicator") as Label;

    window.show_all ();
    Gtk.main ();
  } catch (Error e) {
    stderr.printf ("Could not load UI: %s\n", e.message);
    return 1;
  }

  return 0;
}
