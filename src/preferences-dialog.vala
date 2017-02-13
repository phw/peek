/*
Peek Copyright (c) 2015-2016 by Philipp Wolfer <ph.wolfer@gmail.com>

This file is part of Peek.

This software is licensed under the GNU General Public License
(version 3 or later). See the LICENSE file in this distribution.
*/

using Gtk;

namespace Peek {

  [GtkTemplate (ui = "/com/uploadedlobster/peek/preferences.ui")]
  class PreferencesDialog : Dialog {

    private static Gtk.Dialog? instance;

    public static Gtk.Dialog present_single_instance (Gtk.Window main_window) {
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
    private Gtk.Switch recording_alternative_tmpdir;

    [GtkChild]
    private Gtk.Adjustment recording_start_delay;

    [GtkChild]
    private Gtk.Adjustment recording_framerate;

    [GtkChild]
    private Gtk.Adjustment recording_downsample;

    public PreferencesDialog () {
      Object (use_header_bar: 1);

      settings = Application.get_app_settings ();

      settings.bind ("interface-open-file-manager",
        interface_open_file_manager, "active",
        SettingsBindFlags.DEFAULT);

      settings.bind ("recording-alternative-tmpdir",
        recording_alternative_tmpdir, "state",
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
    }
  }

}
