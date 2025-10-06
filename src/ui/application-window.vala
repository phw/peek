/*
Peek Copyright (c) 2015-2020 by Philipp Wolfer <ph.wolfer@gmail.com>

This file is part of Peek.

This software is licensed under the GNU General Public License
(version 3 or later). See the LICENSE file in this distribution.

This file contains GPL 3 code taken from corebird, a Gtk+ linux Twitter client.
Copyright (C) 2013 Timm Bäder, https://github.com/baedert/corebird/
*/

using Gtk;
using Cairo;
using Peek.Recording;

namespace Peek.Ui {

  [GtkTemplate (ui = "/com/uploadedlobster/peek/application-window.ui")]
  class ApplicationWindow : Gtk.ApplicationWindow {
    public ScreenRecorder recorder { get; construct set; }

    public bool open_file_manager { get; set; }

    public bool show_notification { get; set; }

    public int size_indicator_delay { get; set; }

    public int recording_start_delay { get; set; }

    public string default_file_name_format { get; set; }

    public string save_folder { get; set; }

    [GtkChild]
    private unowned HeaderBar headerbar;

    [GtkChild]
    private unowned Widget recording_view;

    [GtkChild]
    private unowned Button record_button;

    [GtkChild]
    private unowned Button stop_button;

    [GtkChild]
    private unowned Popover pop_format;

    [GtkChild]
    private unowned RadioButton gif_button;

    [GtkChild]
    private unowned RadioButton apng_button;

    [GtkChild]
    private unowned RadioButton webm_button;

    [GtkChild]
    private unowned MenuButton pop_format_menu;

    [GtkChild]
    private unowned Label size_indicator;

    [GtkChild]
    private unowned Label delay_indicator;

    [GtkChild]
    private unowned Label shortcut_label;

    [GtkChild]
    private unowned ToggleButton pop_menu_button;

    [GtkChild]
    private unowned Popover pop_menu;

    private uint start_recording_event_source = 0;
    private uint size_indicator_timeout = 0;
    private uint delay_indicator_timeout = 0;
    private uint time_indicator_timeout = 0;
    private bool is_recording = false;
    private bool is_postprocessing = false;
    private File in_file;
    private File out_file;
    private RecordingArea active_recording_area;
    private string stop_button_label;

    private signal void recording_finished ();

    private GLib.Settings settings;

    private const int SMALL_WINDOW_SIZE = 400;

    public ApplicationWindow (Peek.Application application,
      ScreenRecorder recorder) {
      Object (application: application);

      // Connect recorder signals
      this.recorder = recorder;
      this.recorder.recording_started.connect (() => {
        enter_recording_state ();
      });

      this.recorder.recording_postprocess_started.connect (() => {
        is_postprocessing = true;
        show_file_chooser ();
      });

      this.recorder.recording_finished.connect ((file) => {
        this.in_file = file;
        try_save_file ();
      });

      this.recorder.recording_aborted.connect ((reason) => {
        if (reason != null) {
          stderr.printf ("Recording canceled: %s\n", reason.message);
          ErrorDialog.present_single_instance (
            this,
            _ ("An unexpected error occurred during recording. Recording was aborted."),
            reason);
        } else {
          stderr.printf ("Recording canceled\n");
        }

        this.in_file = null;
        leave_recording_state ();
      });

      application.toggle_recording.connect (toggle_recording);

      application.start_recording.connect (prepare_start_recording);

      application.stop_recording.connect (prepare_stop_recording);

      // Bind settings
      settings = Peek.Application.get_app_settings ();

      settings.bind ("interface-open-file-manager",
        this, "open_file_manager",
        SettingsBindFlags.DEFAULT);

      settings.bind ("interface-show-notification",
        this, "show_notification",
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

      settings.bind ("recording-output-format",
        this.recorder.config, "output_format",
        SettingsBindFlags.DEFAULT);

      settings.bind ("recording-gifski-enabled",
        this.recorder.config, "gifski_enabled",
        SettingsBindFlags.DEFAULT);

      settings.bind ("recording-gifski-quality",
        this.recorder.config, "gifski_quality",
        SettingsBindFlags.DEFAULT);

      settings.bind ("recording-framerate",
        this.recorder.config, "framerate",
        SettingsBindFlags.DEFAULT);

      settings.bind ("recording-downsample",
        this.recorder.config, "downsample",
        SettingsBindFlags.DEFAULT);

      settings.bind ("recording-capture-mouse",
        this.recorder.config, "capture_mouse",
        SettingsBindFlags.DEFAULT);

      settings.bind ("recording-capture-sound",
        this.recorder.config, "capture_sound",
        SettingsBindFlags.DEFAULT);

      settings.bind ("recording-start-delay",
        this, "recording_start_delay",
        SettingsBindFlags.DEFAULT);

      settings.bind ("persist-save-folder",
        this, "save_folder",
        SettingsBindFlags.DEFAULT);

      // Update record button label when recording format changes
      this.recorder.config.notify["output-format"].connect ((pspec) => {
        update_format_label ();
      });

      // Configure window
      if (DesktopIntegration.is_tiling  () ){
        this.type_hint= UTILITY;
      }

      this.set_keep_above (true);
      this.load_geometry ();
      this.on_window_screen_changed (null);

      this.show.connect (() => {
        show_size_indicator ();
        update_format_label ();
      });

      stop_button_label = stop_button.label;

      // Make sure the close button is on the left if desktop environment
      // is configured that way.
      this.set_close_button_position ();
    }


    public void hide_headerbar () {
      this.get_style_context ().add_class ("headerbar-hidden");
      this.headerbar.hide ();
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
      debug ("delete_event: recorder.is_recording=%s, window.is_postprocessing=%s",
        recorder.is_recording.to_string (),
        this.is_postprocessing.to_string ()
      );

      if (recorder.is_recording || this.is_postprocessing) {
        // Recorder has stopped, but Peek is still saving / post processing the
        // file. Hide the window and close after it has finished.
        this.recording_finished.connect ((file) => {
          this.application.withdraw_notification ("background-rendering");
          this.close ();
        });

        if (recorder.is_recording) {
          recorder.cancel ();
        } else {
          var notification = build_standard_notification (_ ("Rendering animation…"));
          notification.set_body (_ ("Peek will close when rendering is finished."));
          this.application.send_notification ("background-rendering", notification);
        }

        this.hide ();
        return true;
      }

      if (start_recording_event_source != 0) {
        Source.remove (start_recording_event_source);
        start_recording_event_source = 0;
      }

      if (size_indicator_timeout != 0) {
        Source.remove (size_indicator_timeout);
        size_indicator_timeout = 0;
      }

      if (delay_indicator_timeout != 0) {
        Source.remove (delay_indicator_timeout);
        delay_indicator_timeout = 0;
      }

      if (time_indicator_timeout != 0) {
        Source.remove (time_indicator_timeout);
        time_indicator_timeout = 0;
      }

      this.save_geometry ();

      return false;
    }

    // Set file format
    private string get_format_name (OutputFormat format) {
      switch (format) {
        case OutputFormat.APNG: return _ ("APNG");
        case OutputFormat.GIF: return _ ("GIF");
        case OutputFormat.WEBM: return _ ("WebM");
        default: return "";
      }
    }

    private void select_format (OutputFormat format) {
      recorder.config.output_format = format;
    }

    private void update_format_label () {
      var format_name = get_format_name (recorder.config.output_format);
      record_button.set_label (_ ("Record as %s").printf (format_name));

      switch (recorder.config.output_format) {
        case OutputFormat.GIF:
          gif_button.set_active (true);
          break;
        case OutputFormat.APNG:
          apng_button.set_active (true);
          break;
        case OutputFormat.WEBM:
          webm_button.set_active (true);
          break;
      }

      var area = get_recording_area ();
      update_ui_size (area);
      pop_format.hide ();
    }

    private void update_time () {
      var title = new Gtk.Label (Utils.format_time (0));
      title.show ();
      headerbar.set_custom_title (title);
      time_indicator_timeout = Timeout.add_full (GLib.Priority.LOW, 500, () => {
        if (is_recording && !this.is_postprocessing) {
          var seconds = recorder.elapsed_seconds;
          title.label = Utils.format_time (seconds);
          return true;
        }

        time_indicator_timeout = 0;
        headerbar.set_custom_title (null);
        return false;
      });
    }

    [GtkCallback]
    public void on_window_screen_changed (Gdk.Screen? previous_screen) {
      var screen = this.get_screen ();
      var visual = screen.get_rgba_visual ();

      if (visual == null) {
        stderr.printf ("Screen does not support alpha channels!");
        visual = screen.get_system_visual ();
      }

      this.set_visual (visual);
    }

    [GtkCallback]
    private bool on_window_draw (Widget widget, Context ctx) {
      update_input_shape ();

      return false;
    }

    [GtkCallback]
    private bool on_recording_view_draw (Widget widget, Context ctx) {
      // Stance out the transparent inner part
      ctx.set_operator (Operator.CLEAR);
      ctx.paint ();

      return false;
    }

    [GtkCallback]
    private void on_recording_view_size_allocate (Allocation allocation) {
      // Show the size
      show_size_indicator ();
    }

    public RecordingArea get_recording_area () {
      return RecordingArea.create_for_widget (recording_view);
    }

    public void resize_recording_area (int width, int height) {
      if (is_recording) {
        return;
      }

      int window_width;
      int window_height;
      get_size (out window_width, out window_height);
      var area = this.get_recording_area ();

      // Update the UI elements to reflect the future window size
      update_ui_size (RecordingArea () {
        width = width,
        height = height
      });

      // Resize the window so that the recording areas results in the requested size.
      this.resize (
        width + (window_width - area.width),
        height + (window_height - area.height));
    }

    private void show_size_indicator () {
      if (this.get_realized ()) {
        update_input_shape ();
        var area = get_recording_area ();
        update_ui_size (area);

        if (!is_recording) {
          // Shortcut recording hint
          var shortcut = Application.get_app_settings ();
          string keys = shortcut.get_string ("keybinding-toggle-recording");
          uint accelerator_key;
          Gdk.ModifierType accelerator_mods;
          Gtk.accelerator_parse (keys, out accelerator_key, out accelerator_mods);
          var shortcut_hint = Gtk.accelerator_get_label (accelerator_key, accelerator_mods);
          shortcut_label.set_text (_ ("Start / Stop: %s").printf (shortcut_hint));
          shortcut_label.show ();

          var size_label = new StringBuilder ();
          size_label.printf ("%i x %i", area.width, area.height);
          size_indicator.set_text (size_label.str);
          size_indicator.show ();

          if (size_indicator_timeout != 0) {
            Source.remove (size_indicator_timeout);
          }

          if (!recorder.is_recording) {
            shortcut_label.opacity = 1.0;
            size_indicator.opacity = 1.0;
            size_indicator_timeout = Timeout.add (size_indicator_delay, () => {
              size_indicator_timeout = 0;
              size_indicator.opacity = 0.0;
              shortcut_label.opacity = 0.0;
              update_input_shape ();
              return false;
            });
          }
        }
      }
    }

    private void update_ui_size (RecordingArea area) {
      // Set the scale of shortcut_label
      Pango.AttrList attrs = new Pango.AttrList ();

      if (area.width < SMALL_WINDOW_SIZE) {
        GtkHelper.hide_button_label (record_button);
        GtkHelper.hide_button_label (stop_button);
        attrs.insert (Pango.attr_scale_new (Pango.Scale.SMALL));
      } else {
        GtkHelper.show_button_label (record_button);
        GtkHelper.show_button_label (stop_button);
        attrs.insert (Pango.attr_scale_new (Pango.Scale.LARGE));
      }

      shortcut_label.attributes = attrs;
    }

    [GtkCallback]
    private void on_format_selection_toggled () {
      if (gif_button.get_active ()) {
        select_format (OutputFormat.GIF);
      } else if (apng_button.get_active ()) {
        select_format (OutputFormat.APNG);
      } else if (webm_button.get_active ()) {
        select_format (OutputFormat.WEBM);
      }
    }

    [GtkCallback]
    private void on_record_button_clicked (Button source) {
      prepare_start_recording ();
    }

    [GtkCallback]
    private void on_stop_button_clicked (Button source) {
      prepare_stop_recording ();
    }

    [GtkCallback]
    private void on_new_window_button_clicked (Button source) {
      pop_menu.hide ();
      this.application.activate_action ("new-window", null);
    }

    [GtkCallback]
    private void on_set_window_size_button_clicked (Button source) {
      pop_menu.hide ();
      this.application.activate_action ("set-window-size", null);
    }

    [GtkCallback]
    private void on_preferences_button_clicked (Button source) {
      pop_menu.hide ();
      PreferencesDialog.present_single_instance (this);
    }

    [GtkCallback]
    private void on_about_button_clicked (Button source) {
      pop_menu.hide ();
      AboutDialog.present_single_instance (this);
    }

    private void prepare_start_recording () {
      if (is_recording) return;

      enter_recording_state ();
      var delay = this.recording_start_delay;

      if (delay > 0) {
        delay_indicator.set_text (delay.to_string ());
        delay_indicator.show ();
        size_indicator.hide ();
        shortcut_label.hide ();
        delay_indicator_timeout = Timeout.add_seconds (1, () => {
          delay -= 1;

          if (delay == 0) {
            delay_indicator_timeout = 0;
            ulong hide_handler = 0;
            hide_handler = delay_indicator.hide.connect (() => {
              delay_indicator.disconnect (hide_handler);
              stop_button.set_label (stop_button_label);
              delay_indicator.queue_draw ();
              start_recording ();
            });
            delay_indicator.hide ();
            return false;
          } else {
            delay_indicator.set_text (delay.to_string ());
            return true;
          }
        });
      } else {
        start_recording ();
      }
    }

    private void prepare_stop_recording () {
      if (!is_recording) return;

      if (delay_indicator_timeout != 0) {
        Source.remove (delay_indicator_timeout);
        delay_indicator_timeout = 0;
        leave_recording_state ();
      } else if (start_recording_event_source != 0) {
        Source.remove (start_recording_event_source);
        start_recording_event_source = 0;
        leave_recording_state ();
      } else if (!recorder.is_recording) {
        return;
      } else {
        stop_button.sensitive = false;
        show_spinner ();
        recorder.stop ();
      }
    }

    private void show_spinner () {
      var box = new Box (Gtk.Orientation.HORIZONTAL, 6);

      var spinner = new Spinner ();
      spinner.active = true;
      box.pack_start (spinner, false, false, 0);

      if (get_window_width () >= SMALL_WINDOW_SIZE) {
        var label = new Gtk.Label (_ ("Rendering…"));
        box.pack_start (label, false, false, 0);
      }

      box.show_all ();
      headerbar.set_custom_title (box);
    }

    private void hide_spinner () {
      headerbar.set_custom_title (null);
    }

    private void toggle_recording () {
      if (is_recording) {
        prepare_stop_recording ();
      } else {
        prepare_start_recording ();
      }
    }

    private void start_recording () {
      // Actually start the recording on next idle time, making sure
      // all queued painting happens before this.
      start_recording_event_source = Idle.add_full (Priority.HIGH_IDLE, () => {
        Source.remove (start_recording_event_source);
        start_recording_event_source = 0;
        update_time ();
        var area = get_recording_area ();
        debug ("Recording area: %i, %i, %i, %i\n",
        area.left, area.top, area.width, area.height);
        active_recording_area = area;

        try {
          recorder.record (area);
          return true;
        } catch (RecordingError e) {
          stderr.printf ("Failed to initialize recorder: %s\n", e.message);
          leave_recording_state ();
          ErrorDialog.present_single_instance (
            this,
            _ ("Recording could not be started due to an unexpected error."),
            e);
          return false;
        }
      });
    }

    private void enter_recording_state () {
      if (!is_recording) {
        is_recording = true;
        size_indicator.opacity = 0.0;
        shortcut_label.opacity = 0.0;
        pop_format_menu.hide ();
        record_button.hide ();
        pop_menu_button.set_sensitive (false);
        if (get_window_width () >= SMALL_WINDOW_SIZE) {
          stop_button.set_label (stop_button_label);
        }

        stop_button.sensitive = true;
        stop_button.show ();
        SetWindowSizeDialog.close_instance ();
        freeze_window_size ();
        set_keep_above (true);
      }
    }

    private void leave_recording_state () {
      this.out_file = null;
      delay_indicator.hide ();
      is_recording = false;
      is_postprocessing = false;
      stop_button.hide ();
      pop_format_menu.show ();
      record_button.show ();
      pop_menu_button.set_sensitive (true);
      unfreeze_window_size ();
      hide_spinner ();

      if (in_file != null) {
        debug ("Deleting temp file %s\n", in_file.get_uri ());
        in_file.delete_async.begin (Priority.DEFAULT, null, (obj, res) => {
          try {
            bool delete_success = in_file.delete_async.end (res);
            debug ("Temp file deleted: %s\n", delete_success.to_string ());
          } catch (Error e) {
            stderr.printf ("Temp file delete error: %s\n", e.message);
          } finally {
            this.in_file = null;
          }

          recording_finished ();
        });
      } else {
        recording_finished ();
      }
    }

    private void update_input_shape () {
      // Set an input shape so that the recording view is not clickable
      var window_region = GtkHelper.create_region_from_widget (recording_view.get_toplevel ());
      var recording_view_region = GtkHelper.create_region_from_widget (recording_view);
      window_region.subtract (recording_view_region);

      // Format popover
      if (pop_format.visible) {
        var pop_format_region = GtkHelper.create_region_from_widget (pop_format);
        window_region.union (pop_format_region);
      }

      // Menu popover
      if (pop_menu.visible) {
        var pop_menu_region = GtkHelper.create_region_from_widget (pop_menu);
        window_region.union (pop_menu_region);
      }

      this.input_shape_combine_region (window_region);

      if (!this.get_screen ().is_composited ()) {
        if (delay_indicator_timeout == 0 &&
          size_indicator_timeout == 0) {
          this.shape_combine_region (window_region);
        } else {
          this.shape_combine_region (null);
        }
      }
    }

    private void freeze_window_size () {
      // Workaround for https://github.com/phw/peek/issues/269
      if (DesktopIntegration.is_xfce ()) {
        debug ("Window size freezing disabled on Xfce");
        return;
      }

      var width = this.get_allocated_width ();
      var height = this.get_allocated_height ();
      debug ("freeze_window_size w: %d, h: %d", width, height);
      this.set_size_request (width, height);
      this.resizable = false;
    }

    private void unfreeze_window_size () {
      // Workaround for https://github.com/phw/peek/issues/269
      if (DesktopIntegration.is_xfce ()) {
        debug ("Window size freezing disabled on Xfce");
        return;
      }

      var width = this.get_allocated_width ();
      var height = this.get_allocated_height ();
      debug ("unfreeze_window_size w: %d, h: %d", width, height);
      this.set_size_request (0, 0);
      this.set_default_size (width, height);
      this.resizable = true;
    }

    private void show_file_chooser () {
      #if HAS_GTK_FILECHOOSERNATIVE
      var chooser = new FileChooserNative (
        _ ("Save animation"), this, FileChooserAction.SAVE,
        _ ("_Save"),
        _ ("_Cancel"));
      #else
      var chooser = new FileChooserDialog (
        _ ("Save animation"), this, FileChooserAction.SAVE,
        _ ("_Cancel"),
        ResponseType.CANCEL);
      var ok_button = chooser.add_button (_ ("_Save"), ResponseType.ACCEPT);
      ok_button.get_style_context ().add_class ("suggested-action");
      #endif

      chooser.do_overwrite_confirmation = true;

      string extension = Utils.get_file_extension_for_format (
        recorder.config.output_format);
      string filename = default_file_name_format + "." + extension;

      var filter = new FileFilter ();
      filter.add_pattern ("*." + extension);
      chooser.filter = filter;

      var folder = load_preferred_save_folder ();
      chooser.set_current_folder (folder);

      var now = new DateTime.now_local ();
      var default_name = now.format (filename);
      chooser.set_current_name (default_name);

      debug ("Showing file chooser (%s)", chooser.get_type ().name ());
      if (chooser.run () == ResponseType.ACCEPT) {
        debug ("Selected file %s", chooser.get_uri ());
        this.out_file = chooser.get_file ();
        try_save_file ();
      } else {
        recorder.cancel ();
        leave_recording_state ();
      }

      #if ! HAS_GTK_FILECHOOSERNATIVE
      // Close the FileChooserDialog:
      chooser.close ();
      #endif
    }

    private void try_save_file () {
      if (this.in_file == null || this.out_file == null) {
        return;
      }

      save_file ();
    }

    private void save_file () {
      in_file.copy_async.begin (out_file, FileCopyFlags.OVERWRITE,
        Priority.DEFAULT, null, null, (obj, res) => {
          try {
            bool copy_success = in_file.copy_async.end (res);
            debug ("File saved %s: %s",
              copy_success.to_string (),
              out_file.get_uri ());

            if (copy_success) {
              handle_saved_file (out_file);
            } else {
              var message = "Saving file %s failed.".printf (out_file.get_uri ());
              stderr.printf ("%s\n", message);
              throw new IOError.FAILED (message);
            }
          } catch (Error e) {
            stderr.printf ("File save error: %s\n", e.message);
            ErrorDialog.present_single_instance (
              this,
              _ ("The file could not be saved to the selected location."),
              e);
          }
          finally {
            leave_recording_state ();
          }
        });
    }

    private void handle_saved_file (File file) {
      save_preferred_save_folder (file);

#if ! DISABLE_OPEN_FILE_MANAGER
      if (this.visible && open_file_manager) {
        DesktopIntegration.launch_file_manager (file);
      } else {
        show_file_saved_notification (file);
      }
#else
      show_file_saved_notification (file);
#endif
    }

    private void show_file_saved_notification (File file) {
      if (this.visible && !show_notification) return;

      var message = new StringBuilder ("");
      message.printf (_ ("Animation saved as “%s”"), file.get_basename ());

      var notification = build_standard_notification (message.str);

#if ! DISABLE_OPEN_FILE_MANAGER
      var parameter = new Variant.string (file.get_uri ());

      // Unity does not allow actions on notifications, so we disable
      // notification actions there.
      if (!DesktopIntegration.is_unity ()) {
        notification.set_body (_ ("Click here to show the saved file in your file manager."));
        notification.add_button_with_target_value (
          _ ("Show in file manager"),
          "app.show-file",
          parameter);

        // Plasma and XFCE will show an empty button for the default action
        if (!DesktopIntegration.is_plasma () &&
          !DesktopIntegration.is_xfce ()) {
          notification.set_default_action_and_target_value (
            "app.show-file",
            parameter);
        }
      }
#endif

      debug ("Showing desktop notification: %s", message.str);
      this.application.send_notification ("peek-file-saved", notification);
    }

    private static Notification build_standard_notification (string message) {
      var notification = new Notification (message);

      if (!DesktopIntegration.is_cinnamon ()) {
        notification.set_icon (new ThemedIcon (APP_ID));
      } else {
        var icon_theme = IconTheme.get_default ();
        var icon_info = icon_theme.lookup_icon (APP_ID, 48, 0);
        var icon_path = icon_info.get_filename ();
        debug ("Using notification icon: %s", icon_path);
        if (icon_path != null) {
          var icon = new FileIcon (File.new_for_path (icon_path));
          notification.set_icon (icon);
        }
      }

      return notification;
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
      Variant geom = settings.get_value ("persist-window-geometry");
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
      var builder = new VariantBuilder (VariantType.TUPLE);
      int x = 0,
          y = 0,
          w = 0,
          h = 0;
      get_position (out x, out y);
      get_size (out w, out h);
      builder.add_value (new Variant.int32 (x));
      builder.add_value (new Variant.int32 (y));
      builder.add_value (new Variant.int32 (w));
      builder.add_value (new Variant.int32 (h));
      settings.set_value ("persist-window-geometry", builder.end ());
    }

    private int get_window_width () {
      int w, h;
      get_size (out w, out h);
      return w;
    }

    private void set_close_button_position () {
      var settings = Gtk.Settings.get_default ();
      string decoration_layout = settings.gtk_decoration_layout ?? "";
      debug ("Decoration layout: %s", decoration_layout);

      if (decoration_layout.contains (":")) {
        var decoration = decoration_layout.split (":", 2);
        if (decoration[0].contains ("close")) {
          this.move_close_button_left ();
        }
      }
    }

    private void move_close_button_left () {
      var decoration = this.headerbar.decoration_layout.split (":", 2);
      if (decoration.length == 2 && decoration[1].contains ("close")) {
        this.headerbar.decoration_layout = decoration[1] + ":" + decoration[0];
      }
    }
  }
}
