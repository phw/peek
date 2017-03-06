/*
Peek Copyright (c) 2015-2017 by Philipp Wolfer <ph.wolfer@gmail.com>

This file is part of Peek.

This software is licensed under the GNU General Public License
(version 3 or later). See the LICENSE file in this distribution.
*/

using Peek.Recording;
using Peek.Ui;

namespace Peek {

  public class Application : Gtk.Application {

    const string APP_ID = "com.uploadedlobster.peek";

    const uint GTK_STYLE_PROVIDER_PRIORITY_APPLICATION = 600;

    private Gtk.Window main_window;

    private static Settings? settings = null;

    public signal void toggle_recording ();
    public signal void start_recording ();
    public signal void stop_recording ();

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

    public static bool keybindings_paused { get; set; default = false; }

    public Application () {
      Object (application_id: APP_ID,
        flags: ApplicationFlags.HANDLES_COMMAND_LINE);

      add_main_option ("version", 'v',
        OptionFlags.IN_MAIN, OptionArg.NONE,
        _ ("Show the version of the program and exit"), null);

      add_main_option ("backend", 'b',
        OptionFlags.IN_MAIN, OptionArg.STRING,
        _ ("Select the recording backend to use (gnome-shell, ffmpeg or avconv). If not set Peek will automatically select a backend."),
        _ ("BACKEND"));

      add_main_option ("start", 's',
        OptionFlags.IN_MAIN, OptionArg.NONE,
        _ ("Start recording in all running Peek instances."), null);

      add_main_option ("stop", 'p',
        OptionFlags.IN_MAIN, OptionArg.NONE,
        _ ("Stop recording in all running Peek instances."), null);

      add_main_option ("toggle", 't',
        OptionFlags.IN_MAIN, OptionArg.NONE,
        _ ("Toggle recording in all running Peek instances."), null);
    }

    public override void activate () {
      this.new_window ();
    }

    public override void startup () {
      base.startup ();

      load_stylesheets ();

      GLib.Environment.set_application_name (_ ("Peek"));

      force_app_menu ();
      register_actions ();

      if (DesktopIntegration.is_x11_backend ()) {
        register_key_bindings ();
      }
    }

    public override void shutdown () {
      foreach (var window in this.get_windows ()) {
        var recorder = (window as ApplicationWindow).recorder;
        recorder.cancel ();
      }

      unregister_key_bindings ();

      base.shutdown ();
    }

    protected override int handle_local_options (GLib.VariantDict options) {
      if (options.contains ("version")) {
        stderr.printf ("%1$s %2$s\n", "Peek", Config.VERSION);
        return Posix.EXIT_SUCCESS;
      }

      return -1;
    }

    public override int command_line (ApplicationCommandLine command_line) {
      var options = command_line.get_options_dict ();
      if (options.contains ("start")) {
        this.start_recording ();
        return Posix.EXIT_SUCCESS;
      }

      if (options.contains ("stop")) {
        this.stop_recording ();
        return Posix.EXIT_SUCCESS;
      }

      if (options.contains ("toggle")) {
        this.toggle_recording ();
        return Posix.EXIT_SUCCESS;
      }

      if (options.contains ("backend")) {
        var backend = options.lookup_value ("backend", VariantType.STRING);
        this.activate_action ("new-window-with-backend", backend);
      } else {
        this.activate_action ("new-window", null);
      }

      return Posix.EXIT_SUCCESS;
    }

    private void register_actions () {
      // Application actions
      GLib.SimpleAction action;

      action = new GLib.SimpleAction ("new-window", null);
      action.activate.connect (new_window);
      add_action (action);

      action = new GLib.SimpleAction ("new-window-with-backend", VariantType.STRING);
      action.activate.connect (new_window_with_backend);
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

    private void register_key_bindings () {
      var settings = get_app_settings ();

      // Global key bindings
      Keybinder.init ();
      Keybinder.set_use_cooked_accelerators (false);

      settings.bind ("keybinding-toggle-recording",
        this, "keybinding_toggle_recording",
        SettingsBindFlags.DEFAULT);
    }

    private void unregister_key_bindings () {
      Keybinder.unbind_all (keybinding_toggle_recording);
    }

    private string _keybinding_toggle_recording = "";
    public string keybinding_toggle_recording {
        get { return _keybinding_toggle_recording; }
        set {
          debug ("Changed keybinding_toggle_recording %s => %s\n",
            _keybinding_toggle_recording, value);
          if (_keybinding_toggle_recording != "") {
            Keybinder.unbind_all (_keybinding_toggle_recording);
          }

          if (value != "") {
            Keybinder.bind_full (value, handle_keybinding_toggle_recording);
          }

          _keybinding_toggle_recording = value;
        }
    }

    private void handle_keybinding_toggle_recording (string keystring) {
      if (!keybindings_paused) {
        debug ("Global keybinding %s\n", keystring);
        toggle_recording ();
      }
    }

    private void new_window () {
      try {
        var recorder = ScreenRecorderFactory.create_default_screen_recorder ();
        show_window (recorder);
      } catch (PeekError e) {
        stderr.printf (_ ("Unable to create default screen recorder.\n"));
      }
    }

    private void new_window_with_backend (Variant? backend) {
      size_t length;
      string backend_name = backend.get_string (out length);
      stdout.printf ("Requested screen recorder backend %s\n", backend_name);

      try {
        var recorder = ScreenRecorderFactory.create_screen_recorder (backend_name);
        show_window (recorder);
      } catch (PeekError e) {
        stderr.printf (_ ("Unable to initialize backend %s.\n"), backend_name);
        stderr.printf (e.message);
      }
    }

    private void show_window (ScreenRecorder recorder) {
      main_window = new ApplicationWindow (this, recorder);
      main_window.present ();

      if (DesktopIntegration.is_wayland_backend ()) {
        show_wayland_warning (main_window);
      }
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

    private void show_wayland_warning (Gtk.Window parent) {
      var msg = new Gtk.MessageDialog (parent, Gtk.DialogFlags.MODAL,
        Gtk.MessageType.WARNING, Gtk.ButtonsType.OK,
        _ ("Native Wayland backend is unsupported"));
      msg.secondary_use_markup = true;
      msg.secondary_text = _ ("You are running Peek natively on Wayland, this is currently unsupported. Please start Peek using XWayland by setting <tt>GDK_BACKEND=x11</tt>.\n\nFor Details see the Peek <a href='https://github.com/phw/peek#why-no-native-wayland-support'>FAQ about Wayland support</a>.");
      msg.response.connect ((response_id) => {
        parent.destroy ();
      });
      msg.show ();
    }
  }

}
