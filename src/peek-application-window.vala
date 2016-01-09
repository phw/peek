/*
Peek Copyright (c) 2015-2016 by Philipp Wolfer <ph.wolfer@gmail.com>

This file is part of Peek.

This software is licensed under the GNU General Public License
(version 3 or later). See the LICENSE file in this distribution.

This file contains GPL 3 code taken from corebird, a Gtk+ linux Twitter client.
Copyright (C) 2013 Timm Bäder, https://github.com/baedert/corebird/
*/

using Gtk;
using Cairo;

[GtkTemplate (ui = "/de/uploadedlobster/peek/application-window.ui")]
class PeekApplicationWindow : ApplicationWindow {
  public ScreenRecorder recorder { get; construct set; }

  public bool open_file_manager { get; set; }

  public int size_indicator_delay { get; set; }

  public int recording_start_delay { get; set; }

  public string default_file_name_format { get; set; }

  public string save_folder { get; set; }

  [GtkChild]
  private Widget recording_view;

  [GtkChild]
  private Button record_button;

  [GtkChild]
  private Button stop_button;

  [GtkChild]
  private Label size_indicator;

  [GtkChild]
  private Label delay_indicator;

  private uint size_indicator_timeout = 0;
  private uint delay_indicator_timeout = 0;
  private bool screen_supports_alpha = true;
  private bool is_recording = false;
  private RecordingArea active_recording_area;

  private GLib.Settings settings;

  public PeekApplicationWindow (Gtk.Application application,
    ScreenRecorder recorder) {
    Object (application: application);

    // Connect recorder signals
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

    // Bind settings
    settings = PeekApplication.get_app_settings ();

    settings.bind ("interface-open-file-manager",
      this, "open_file_manager",
      SettingsBindFlags.DEFAULT);

    settings.bind ("interface-size-indicator-delay",
      this, "size_indicator_delay",
      SettingsBindFlags.DEFAULT);

    settings.bind ("interface-default-file-name-format",
      this, "default_file_name_format",
      SettingsBindFlags.DEFAULT);

    settings.bind ("interface-prefer-dark-theme",
      this.get_settings (), "gtk_application_prefer_dark_theme",
      SettingsBindFlags.DEFAULT);

    settings.bind ("recording-framerate",
      this.recorder, "framerate",
      SettingsBindFlags.DEFAULT);

    settings.bind ("recording-start-delay",
      this, "recording_start_delay",
      SettingsBindFlags.DEFAULT);

    settings.bind ("persist-save-folder",
      this, "save_folder",
      SettingsBindFlags.DEFAULT);

    // Configure window
    this.set_keep_above (true);
    this.load_geometry ();
    this.on_window_screen_changed (null);
  }

  public override bool configure_event (Gdk.EventConfigure event) {
    if (recorder.is_recording) {
      var new_recording_area = get_recording_area ();
      if (!new_recording_area.equals (active_recording_area)) {
        recorder.cancel ();
      }
    }

    return base.configure_event (event);
  }

  public override bool delete_event (Gdk.EventAny event) {
    if (recorder.is_recording) {
      recorder.cancel ();
    }

    if (size_indicator_timeout != 0) {
      Source.remove (size_indicator_timeout);
    }

    if (delay_indicator_timeout != 0) {
      Source.remove (delay_indicator_timeout);
    }

    this.save_geometry ();

    return false;
  }

  [GtkCallback]
  public void on_window_screen_changed (Gdk.Screen? previous_screen) {
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

    update_input_shape ();

    return false;
  }

  [GtkCallback]
  private void on_recording_view_size_allocate (Allocation allocation) {
    // Show the size
    if (this.get_realized () && !is_recording) {
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
        size_indicator_timeout = Timeout.add (size_indicator_delay, () => {
          size_indicator_timeout = 0;
          size_indicator.opacity = 0.0;
          return false;
        });
      }
    }
  }

  [GtkCallback]
  private void on_record_button_clicked (Button source) {
    enter_recording_state ();
    var delay = this.recording_start_delay;

    if (delay > 0) {
      delay_indicator.set_text (delay.to_string ());
      delay_indicator.show ();
      size_indicator.hide ();
      delay_indicator_timeout = Timeout.add (1000, () => {
        delay -= 1;

        if (delay == 0) {
          delay_indicator_timeout = 0;
          delay_indicator.hide ();
          start_recording ();
          return false;
        }
        else {
          delay_indicator.set_text (delay.to_string ());
          return true;
        }
      });
    }
    else {
      start_recording ();
    }
  }

  [GtkCallback]
  private void on_stop_button_clicked (Button source) {
    if (delay_indicator_timeout != 0) {
      Source.remove (delay_indicator_timeout);
      delay_indicator_timeout = 0;
      leave_recording_state ();
    }
    else {
      stop_button.sensitive = false;
      recorder.stop ();
    }
  }

  private void start_recording () {
    var area = get_recording_area ();
    debug ("Recording area: %i, %i, %i, %i\n",
      area.left, area.top, area.width, area.height);
    active_recording_area = area;
    if (!recorder.record (area)) {
      leave_recording_state ();
    }
  }

  private void enter_recording_state () {
    is_recording = true;
    size_indicator.opacity = 0.0;
    record_button.hide ();
    stop_button.sensitive = true;
    stop_button.show ();
    freeze_window_size ();
    set_keep_above (true);
  }

  private void leave_recording_state () {
    delay_indicator.hide ();
    is_recording = false;
    stop_button.hide ();
    record_button.show ();
    unfreeze_window_size ();
  }

  private void update_input_shape () {
    // Set an input shape so that the recording view is not clickable
    var window_region = create_region_from_widget (recording_view.get_toplevel ());
    var recording_view_region = create_region_from_widget (recording_view);
    window_region.subtract (recording_view_region);

    // The fallback app menu overlaps the recording area
    var fallback_app_menu = get_fallback_app_menu ();
    if (fallback_app_menu != null && fallback_app_menu.visible) {
      var app_menu_region = create_region_from_widget (fallback_app_menu);
      window_region.union (app_menu_region);
    }

    this.input_shape_combine_region (window_region);
  }

  private Widget? get_fallback_app_menu () {
    if (this.application.prefers_app_menu ()) {
      return null;
    }

    Widget fallback_app_menu = null;

    this.forall ((child)  => {
      if (child is Gtk.Popover) {
        fallback_app_menu = child;
      }
    });

    return fallback_app_menu;
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
      null, this, FileChooserAction.SAVE,
      _ ("_Cancel"),
      ResponseType.CANCEL,
      _ ("_Save"),
      ResponseType.ACCEPT);

    var filter = new FileFilter ();
    chooser.do_overwrite_confirmation = true;
    chooser.filter = filter;
    filter.add_mime_type ("image/gif");

    var folder = load_preferred_save_folder ();
    chooser.set_current_folder (folder);

    var now = new DateTime.now_local ();
    var default_name = now.format (default_file_name_format);
    chooser.set_current_name (default_name);

    if (chooser.run () == ResponseType.ACCEPT) {
      var out_file = chooser.get_file ();

      in_file.copy_async.begin (out_file, FileCopyFlags.OVERWRITE,
        Priority.DEFAULT, null, null, (obj, res) => {
          try {
            bool copy_success = in_file.copy_async.end (res);
            debug ("File saved %s: %s\n",
              copy_success.to_string (),
              out_file.get_uri ());

            if (copy_success && open_file_manager) {
              DesktopIntegration.launch_file_manager (out_file);
              save_preferred_save_folder (out_file);
            }
            else if (!copy_success) {
              stderr.printf ("Saving file %s failed.", out_file.get_uri ());
            }

            in_file.delete_async.begin (Priority.DEFAULT, null, (obj, res) => {
              try {
                bool delete_success = in_file.delete_async.end (res);
                debug ("Temp file deleted: %s\n",
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

  private string load_preferred_save_folder () {
    var folder = save_folder;

    if (folder == null || folder == ""
      || !FileUtils.test (folder, FileTest.IS_DIR)) {
        folder = DesktopIntegration.get_video_folder ();
      }

    return folder;
  }

  private void save_preferred_save_folder (File out_file) {
    if (out_file.has_uri_scheme ("file")) {
      var parent = out_file.get_parent ();
      var new_folder = parent.get_path ();
      var default_folder = DesktopIntegration.get_video_folder ();

      if (new_folder != default_folder) {
        save_folder = new_folder;
      }
    }
  }

  private void load_geometry () {
    GLib.Variant geom = settings.get_value ("persist-window-geometry");
    int x = 0,
        y = 0,
        w = 0,
        h = 0;
    x = geom.get_child_value (0).get_int32 ();
    y = geom.get_child_value (1).get_int32 ();
    w = geom.get_child_value (2).get_int32 ();
    h = geom.get_child_value (3).get_int32 ();
    if (w == 0 || h == 0)
      return;

    if (x >= 0 && y >= 0) {
      move (x, y);
    }

    resize (w, h);
  }

  private void save_geometry () {
    var builder = new GLib.VariantBuilder (GLib.VariantType.TUPLE);
    int x = 0,
        y = 0,
        w = 0,
        h = 0;
    get_position (out x, out y);
    w = get_allocated_width ();
    h = get_allocated_height ();
    builder.add_value (new GLib.Variant.int32(x));
    builder.add_value (new GLib.Variant.int32(y));
    builder.add_value (new GLib.Variant.int32(w));
    builder.add_value (new GLib.Variant.int32(h));
    settings.set_value ("persist-window-geometry", builder.end ());
  }
}
