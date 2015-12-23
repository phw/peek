/*
Peek Copyright (c) 2015 by Philipp Wolfer <ph.wolfer@gmail.com>

This file is part of Peek.

This software is licensed under the GNU General Public License
(version 3 or later). See the LICENSE file in this distribution.
*/

using Gtk;

[GtkTemplate (ui = "/de/uploadedlobster/peek/preferences.ui")]
class PeekPreferencesDialog : Dialog {

  private static Gtk.Dialog? instance;

  public static Gtk.Dialog present_single_instance (Gtk.Window main_window) {
    if (instance == null) {
      instance = new PeekPreferencesDialog ();
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
  private Gtk.CheckButton interface_auto_save;

  [GtkChild]
  private Gtk.Adjustment recording_start_delay;

  [GtkChild]
  private Gtk.Adjustment recording_framerate;

  [GtkChild]
  private Gtk.CheckButton recording_loop;

  public PeekPreferencesDialog () {
    Object (use_header_bar: 1);

    settings = PeekApplication.get_app_settings ();

    settings.bind ("interface-open-file-manager",
      interface_open_file_manager, "active",
      SettingsBindFlags.DEFAULT);

    settings.bind ("interface-auto-save",
      interface_auto_save, "active",
      SettingsBindFlags.DEFAULT);

    settings.bind ("recording-start-delay",
      recording_start_delay, "value",
      SettingsBindFlags.DEFAULT);

    settings.bind ("recording-framerate",
      recording_framerate, "value",
      SettingsBindFlags.DEFAULT);

    settings.bind ("recording-loop",
      recording_loop, "active",
      SettingsBindFlags.DEFAULT);
  }
}
