/*
Peek Copyright (c) 2015-2016 by Philipp Wolfer <ph.wolfer@gmail.com>

This file is part of Peek.

This software is licensed under the GNU General Public License
(version 3 or later). See the LICENSE file in this distribution.
*/

using Peek.Recording;

namespace Peek {

  public class Application : Gtk.Application {

    const string APP_ID = "com.uploadedlobster.peek";

    const uint GTK_STYLE_PROVIDER_PRIORITY_APPLICATION = 600;

    private Gtk.Window main_window;

    private static Settings? settings = null;

    public static Settings get_app_settings () {
      if (settings != null) {
        return settings;
      }

      try {
        var settings_dir = "./data/schemas/";
        var schema_source = new SettingsSchemaSource.from_directory (settings_dir, null, false);
        SettingsSchema? schema = schema_source.lookup (APP_ID, false);
        if (schema != null) {
          settings = new Settings.full (schema, null, null);
        }
      }
      catch (GLib.Error e) {
        debug ("Loading local settings failed: %s", e.message);
      }

      if (settings == null) {
        settings = new Settings (APP_ID);
      }

      return settings;
    }

    public Application () {
      Object (application_id: APP_ID,
        flags: ApplicationFlags.FLAGS_NONE);

      #if GIO_HAS_MAIN_OPTION_ENTRIES
      add_main_option ("version", 'v',
        OptionFlags.IN_MAIN, OptionArg.NONE,
        _ ("Show the version of the program and exit"), null);
      #endif
    }

    public override void activate () {
      var recorder = new FfmpegScreenRecorder ();
      main_window = new ApplicationWindow (this, recorder);
      main_window.present ();
    }

    public override void startup () {
      base.startup ();

      load_stylesheets ();

      GLib.Environment.set_application_name (_ ("Peek"));

      // Setup app menu
      force_app_menu ();
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

      action = new GLib.SimpleAction ("show-file", VariantType.STRING);
      action.activate.connect (show_file);
      add_action (action);
    }

    public override void shutdown () {
      foreach (var window in this.get_windows ()) {
        var recorder = (window as ApplicationWindow).recorder;
        recorder.cancel ();
      }

      base.shutdown ();
    }

    #if GIO_HAS_MAIN_OPTION_ENTRIES
    protected override int handle_local_options (GLib.VariantDict options) {
      if (options.contains ("version")) {
        stderr.printf ("%1$s %2$s\n", "Peek", Config.VERSION);
        return Posix.EXIT_SUCCESS;
      }

      return -1;
    }
    #endif

    private void new_window () {
      this.activate ();
    }

    private void show_preferences () {
      PreferencesDialog.present_single_instance (main_window);
    }

    private void show_about () {
      AboutDialog.present_single_instance (main_window);
    }

    private void load_stylesheets () {
      load_stylesheet_from_uri ("resource:///com/uploadedlobster/peek/css/peek.css");

      if (DesktopIntegration.is_unity ()) {
        load_stylesheet_from_uri ("resource:///com/uploadedlobster/peek/css/unity.css");
      }
    }

    private void load_stylesheet_from_uri (string uri) {
      var provider = new Gtk.CssProvider ();
      try {
        var file = File.new_for_uri (uri);
        provider.load_from_file (file);
        var screen = Gdk.Screen.get_default ();
        Gtk.StyleContext.add_provider_for_screen (screen, provider,
          GTK_STYLE_PROVIDER_PRIORITY_APPLICATION);
      }
      catch (GLib.Error e) {
        stderr.printf ("Loading application stylesheet %s failed: %s", uri, e.message);
      }
    }

    private void show_file (Variant? uri) {
      var uri_str = uri.get_string ();
      debug ("Action show-file called with URI %s", uri_str);
      var file = File.new_for_uri (uri_str);
      DesktopIntegration.launch_file_manager (file);
    }

    /**
    * Forces the app menu in the decoration layouts so in environments without an app-menu
    * it will be rendered by GTK as part of the window.
    *
    * Applies if:
    *  - disabled Gtk/ShellShowsAppMenu setting
    *  - no 'menu' setting in Gtk/DecorationLayout
    */
    private void force_app_menu () {
      var settings = Gtk.Settings.get_default ();

      if (settings == null) {
          warning ("Could not fetch Gtk default settings");
          return ;
      }

      #if GTK_HAS_DECORATION_LAYOUT
      string decoration_layout = settings.gtk_decoration_layout ?? "";
      debug ("Decoration layout: %s", decoration_layout);

      // Make sure the menu is part of the decoration
      if (!decoration_layout.contains ("menu")) {
          string prefix = "menu:";
          if (decoration_layout.contains (":")) {
              prefix = decoration_layout.has_prefix (":") ? "menu" : "menu,";
          }

          settings.gtk_decoration_layout = prefix + decoration_layout;
      }
      #endif

      // Unity specific workaround, force app menu in window when
      // setting to display menus in titlebar in Unity is active
      if (DesktopIntegration.is_unity ()) {
        var schema_source = SettingsSchemaSource.get_default ();
        SettingsSchema? schema = schema_source.lookup ("com.canonical.Unity", false);
        if (schema != null && schema.has_key ("integrated-menus")) {
          var unity = new Settings.full (schema, null, null);
          if (unity.get_boolean ("integrated-menus")) {
            settings.gtk_shell_shows_app_menu = false;
          }
        }
      }
    }
  }

}
