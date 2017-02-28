/*
Peek Copyright (c) 2015-2017 by Philipp Wolfer <ph.wolfer@gmail.com>

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

    #if HAS_GTK_SHORTCUT_LABEL
    private Gtk.ShortcutLabel keybinding_toggle_recording_accelerator;
    #else
    private Gtk.Label keybinding_toggle_recording_accelerator;
    #endif

    [GtkChild]
    private Gtk.Box keybinding_toggle_recording_editor;

    private Gtk.ToggleButton keybinding_toggle_recording_button;

    [GtkChild]
    private Gtk.ComboBoxText recording_output_format_combo_box;

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

      settings.bind ("recording-output-format",
        recording_output_format_combo_box, "active_id",
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

      init_keybinding_editor ();
    }

    private void init_keybinding_editor () {
      var editor_box = keybinding_toggle_recording_editor;

      #if HAS_GTK_SHORTCUT_LABEL
      // Gtk >= 3.22 does have GtkShortcutLabel, which is easier to use
      // and displays the shortcuts more nicely to the user.
      keybinding_toggle_recording_accelerator = new Gtk.ShortcutLabel ("");
      keybinding_toggle_recording_accelerator.disabled_text = _ ("deactivated");
      editor_box.pack_start (keybinding_toggle_recording_accelerator,
        false, true, 0);
      settings.bind ("keybinding-toggle-recording",
        keybinding_toggle_recording_accelerator, "accelerator",
        SettingsBindFlags.DEFAULT);
      #else
      // Fallback to a normal GtkLabel with custom code for displaying the
      // shortcut keys.
      keybinding_toggle_recording_accelerator = new Gtk.Label ("");
      keybinding_toggle_recording_accelerator.halign = Gtk.Align.START;
      #if HAS_GTK_LABEL_XALIGN
      keybinding_toggle_recording_accelerator.xalign = 0;
      #endif
      editor_box.pack_start (keybinding_toggle_recording_accelerator,
        false, true, 0);
      settings.changed.connect ((key) => {
        if (key == "keybinding-toggle-recording") {
          set_accelerator_label (
            keybinding_toggle_recording_accelerator,
            settings.get_string (key));
        }
      });
      set_accelerator_label (
        keybinding_toggle_recording_accelerator,
        settings.get_string ("keybinding-toggle-recording"));
      #endif

      keybinding_toggle_recording_accelerator.width_request = 175;

      // Add a button to change the keyboard shortcut
      keybinding_toggle_recording_button = new Gtk.ToggleButton.with_label (
        _ ("Change"));
      keybinding_toggle_recording_button.toggled.connect (
        on_keybinding_toggle_recording_button_toggled);
      keybinding_toggle_recording_button.focus_out_event.connect (
        on_keybinding_toggle_recording_button_focus_out);
      keybinding_toggle_recording_button.key_release_event.connect (
        on_keybinding_toggle_recording_button_keypress);
      editor_box.pack_start (keybinding_toggle_recording_button, false, true, 0);

      editor_box.show_all ();
    }

    private void on_keybinding_toggle_recording_button_toggled (Button source) {
      if (keybinding_toggle_recording_button.active) {
        keybinding_toggle_recording_button.label = _ ("Press keys…");
      } else {
        keybinding_toggle_recording_button.label = _ ("Change");
      }
    }

    private bool on_keybinding_toggle_recording_button_focus_out (Gdk.EventFocus event) {
      keybinding_toggle_recording_button.active = false;
      return false;
    }

    private bool on_keybinding_toggle_recording_button_keypress (Gdk.EventKey event) {
      if (keybinding_toggle_recording_button.active) {
        if (event.keyval == Gdk.Key.Escape &&
          no_modifier_set (event.state)) {
          settings.set_string ("keybinding-toggle-recording", "");
        } else if (event.is_modifier == 0) {
          var mods = event.state & Gtk.accelerator_get_default_mod_mask ();
          string accelerator = Gtk.accelerator_name (event.keyval, mods);
          settings.set_string ("keybinding-toggle-recording", accelerator);
        }

        keybinding_toggle_recording_button.active = false;
        return true;
      }

      return false;
    }

    #if ! HAS_GTK_SHORTCUT_LABEL
    private void set_accelerator_label (Gtk.Label accel_label, string accelerator) {
      uint accelerator_key;
      Gdk.ModifierType accelerator_mods;
      Gtk.accelerator_parse (accelerator, out accelerator_key, out accelerator_mods);
      var label = Gtk.accelerator_get_label (accelerator_key, accelerator_mods);

      if (label == "") {
        label = _ ("deactivated");
      }

      accel_label.label = label;
    }
    #endif

    private static bool no_modifier_set (Gdk.ModifierType mods) {
      return (mods & Gtk.accelerator_get_default_mod_mask ()) == 0;
    }
  }

}
