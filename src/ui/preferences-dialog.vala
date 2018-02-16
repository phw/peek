/*
Peek Copyright (c) 2015-2018 by Philipp Wolfer <ph.wolfer@gmail.com>

This file is part of Peek.

This software is licensed under the GNU General Public License
(version 3 or later). See the LICENSE file in this distribution.
*/

using Gtk;

namespace Peek.Ui {

  [GtkTemplate (ui = "/com/uploadedlobster/peek/preferences.ui")]
  class PreferencesDialog : Window {

    private static Gtk.Window? instance;

    public static Gtk.Window present_single_instance (Gtk.Window main_window) {
      if (instance == null) {
        instance = new PreferencesDialog ();
        instance.delete_event.connect ((event) => {
          instance = null;
          main_window.set_keep_above (true);
          return false;
        });
      }

      instance.transient_for = main_window;
      main_window.set_keep_above (false);
      instance.present ();
      return instance;
    }

    private GLib.Settings settings;

    [GtkChild]
    private Gtk.CheckButton interface_open_file_manager;

    [GtkChild]
    private Gtk.CheckButton interface_show_notification;

    [GtkChild]
    private Gtk.Box keybinding_toggle_recording_box;

#if HAS_KEYBINDER
    private ShortcutLabel keybinding_toggle_recording_accelerator;

    [GtkChild]
    private Gtk.Box keybinding_toggle_recording_editor;

    private Gtk.ToggleButton keybinding_toggle_recording_button;
#endif

    [GtkChild]
    private Gtk.ComboBoxText recording_output_format_combo_box;

    [GtkChild]
    private Gtk.Box recording_gifski_settings;

    [GtkChild]
    private Gtk.CheckButton recording_gifski_enabled;

    [GtkChild]
    private Gtk.Box recording_gifski_quality_box;

    [GtkChild]
    private Gtk.Adjustment recording_gifski_quality;

    [GtkChild]
    private Gtk.Scale recording_gifski_quality_scale;

    [GtkChild]
    private Gtk.Adjustment recording_start_delay;

    [GtkChild]
    private Gtk.Adjustment recording_framerate;

    [GtkChild]
    private Gtk.Adjustment recording_downsample;

    [GtkChild]
    private Gtk.CheckButton recording_capture_mouse;


    public PreferencesDialog () {
      Object ();

      settings = Application.get_app_settings ();

      settings.bind ("interface-open-file-manager",
        interface_open_file_manager, "active",
        SettingsBindFlags.DEFAULT);

      settings.bind ("interface-show-notification",
        interface_show_notification, "active",
        SettingsBindFlags.DEFAULT);

      settings.bind ("recording-output-format",
        recording_output_format_combo_box, "active_id",
        SettingsBindFlags.DEFAULT);

      settings.bind ("recording-gifski-enabled",
        recording_gifski_enabled, "active",
        SettingsBindFlags.DEFAULT);

      settings.bind ("recording-gifski-quality",
        recording_gifski_quality, "value",
        SettingsBindFlags.DEFAULT);

      settings.bind ("recording-start-delay",
        recording_start_delay, "value",
        SettingsBindFlags.DEFAULT);

      settings.bind ("recording-framerate",
        recording_framerate, "value",
        SettingsBindFlags.DEFAULT);

      settings.bind ("recording-downsample",
        recording_downsample, "value",
        SettingsBindFlags.DEFAULT);

      settings.bind ("recording-capture-mouse",
        recording_capture_mouse, "active",
        SettingsBindFlags.DEFAULT);

      on_interface_open_file_manager_toggled (interface_open_file_manager);
      on_gifski_toggled (recording_gifski_enabled);

      for (int i = 20; i <= 100; i += 20) {
        recording_gifski_quality_scale.add_mark (i, PositionType.BOTTOM, null);
      }

      if (!PostProcessing.GifskiPostProcessor.is_available ()) {
        recording_gifski_settings.hide ();
      }

#if HAS_KEYBINDER
      if (DesktopIntegration.is_x11_backend ()) {
        init_keybinding_editor ();
      } else {
        keybinding_toggle_recording_box.hide ();
      }
#else
      keybinding_toggle_recording_box.hide ();
#endif

#if DISABLE_OPEN_FILE_MANAGER
      interface_open_file_manager.hide ();
#endif
    }

    [GtkCallback]
    private void on_interface_open_file_manager_toggled (ToggleButton source) {
#if ! DISABLE_OPEN_FILE_MANAGER
      interface_show_notification.sensitive = !source.active;
#endif
    }

    [GtkCallback]
    private void on_output_format_changed () {
      recording_gifski_settings.sensitive =
        (recording_output_format_combo_box.active_id == OutputFormat.GIF.to_string ());
    }

    [GtkCallback]
    private void on_gifski_toggled (ToggleButton source) {
      recording_gifski_quality_box.sensitive = source.active;
    }

#if HAS_KEYBINDER
    public override bool delete_event (Gdk.EventAny event) {
      Application.keybindings_paused = false;
      return false;
    }

    private void init_keybinding_editor () {
      var editor_box = keybinding_toggle_recording_editor;

      // Display the configured shortcut to the user
      keybinding_toggle_recording_accelerator = new ShortcutLabel ("");
      keybinding_toggle_recording_accelerator.disabled_text = _ ("deactivated");
      editor_box.pack_start (keybinding_toggle_recording_accelerator,
        false, true, 0);
      settings.bind ("keybinding-toggle-recording",
        keybinding_toggle_recording_accelerator, "accelerator",
        SettingsBindFlags.DEFAULT);

      keybinding_toggle_recording_accelerator.width_request = 175;

      // Add a button to change the keyboard shortcut
      keybinding_toggle_recording_button = new Gtk.ToggleButton.with_label (
        _ ("Change"));
      keybinding_toggle_recording_button.toggled.connect (
        on_keybinding_toggle_recording_button_toggled);
      editor_box.pack_start (keybinding_toggle_recording_button, false, true, 0);

      // Listen to key events on the window for setting keyboard shortcuts
      this.key_release_event.connect (on_key_release);

      editor_box.show_all ();
    }

    private void on_keybinding_toggle_recording_button_toggled (Button source) {
      if (keybinding_toggle_recording_button.active) {
        keybinding_toggle_recording_button.label = _ ("Press keys…");
        Application.keybindings_paused = true;
      } else {
        keybinding_toggle_recording_button.label = _ ("Change");
        Application.keybindings_paused = false;
      }
    }

    private bool on_key_release (Gdk.EventKey event) {
      if (keybinding_toggle_recording_button.active) {
        keybinding_toggle_recording_button.active = false;

        if (event.keyval == Gdk.Key.Escape && no_modifier_set (event.state)) {
          return true;
        } else if (event.keyval == Gdk.Key.BackSpace &&
          no_modifier_set (event.state)) {
          settings.set_string ("keybinding-toggle-recording", "");
        } else if (event.is_modifier == 0) {
          var mods = event.state & Gtk.accelerator_get_default_mod_mask ();
          string accelerator = Gtk.accelerator_name (event.keyval, mods);
          settings.set_string ("keybinding-toggle-recording", accelerator);
        }

        return true;
      }

      return false;
    }

    private static bool no_modifier_set (Gdk.ModifierType mods) {
      return (mods & Gtk.accelerator_get_default_mod_mask ()) == 0;
    }
#endif
  }

}
