/*
Peek Copyright (c) 2015-2016 by Philipp Wolfer <ph.wolfer@gmail.com>

This file is part of Peek.

This software is licensed under the GNU General Public License
(version 3 or later). See the LICENSE file in this distribution.
*/

public class PeekApplication : Gtk.Application {

  const string APP_ID = "de.uploadedlobster.peek";

  private Gtk.Window main_window;

  public static Settings get_app_settings () {
    Settings settings;

    try {
      var settings_dir = "./schemas/";
      var schema_source = new SettingsSchemaSource.from_directory (settings_dir, null, false);
      SettingsSchema schema = schema_source.lookup (APP_ID, false);
      settings = new Settings.full (schema, null, null);
    }
    catch (GLib.Error e) {
      debug ("Loading local settings failed: %s", e.message);
      settings = new Settings (APP_ID);
    }

    return settings;
  }

  public PeekApplication () {
    Object (application_id: APP_ID,
      flags: ApplicationFlags.FLAGS_NONE);
  }

  public override void activate () {
    var recorder = new FfmpegScreenRecorder ();
    main_window = new PeekApplicationWindow (this, recorder);
    main_window.present ();
  }

  public override void startup () {
    base.startup ();

    GLib.Environment.set_application_name (_ ("Peek"));

    // Setup app menu
    GLib.SimpleAction action;

    action = new GLib.SimpleAction ("new-window", null);
    action.activate.connect (new_window);
    add_action (action);

    action = new GLib.SimpleAction ("preferences", null);
    action.activate.connect (show_preferences);
    add_action (action);

    action = new GLib.SimpleAction ("about", null);
    action.activate.connect (show_about);
    add_action (action);

    action = new GLib.SimpleAction ("quit", null);
    action.activate.connect (quit);
    add_action (action);
  }

  public override void shutdown () {
    foreach (var window in this.get_windows ()) {
      var recorder = (window as PeekApplicationWindow).recorder;
      recorder.cancel ();
    }

    base.shutdown ();
  }

  private void new_window () {
    this.activate ();
  }

  private void show_preferences () {
    PeekPreferencesDialog.present_single_instance (main_window);
  }

  private void show_about () {
    PeekAboutDialog.present_single_instance (main_window);
  }
}
