/*
Peek Copyright (c) 2015-2020 by Philipp Wolfer <ph.wolfer@gmail.com>

This file is part of Peek.

This software is licensed under the GNU General Public License
(version 3 or later). See the LICENSE file in this distribution.
*/

using Peek.Recording;
using Peek.Ui;

namespace Peek {

  public class Application : Gtk.Application {

    const uint GTK_STYLE_PROVIDER_PRIORITY_APPLICATION = 600;

    private ApplicationWindow main_window;

    private static Settings? settings = null;

    public signal void toggle_recording ();
    public signal void start_recording ();
    public signal void stop_recording ();

    public static Settings get_app_settings () {
      if (settings != null) {
        return settings;
      }

#if DEBUG
      try {
        var settings_dir = "./data/";
        var schema_source = new SettingsSchemaSource.from_directory (settings_dir, null, false);
        SettingsSchema? schema = schema_source.lookup (APP_ID, false);
        if (schema != null) {
          settings = new Settings.full (schema, null, null);
        }
      }
      catch (Error e) {
        debug ("Loading local settings failed: %s", e.message);
      }
#endif

      if (settings == null) {
        settings = new Settings (APP_ID);
      }

      return settings;
    }

#if HAS_KEYBINDER
    public static bool keybindings_paused { get; set; default = false; }
#endif

    public Application () {
      Object (application_id: APP_ID,
        flags: ApplicationFlags.HANDLES_COMMAND_LINE);

      add_main_option ("version", 'v',
        OptionFlags.IN_MAIN, OptionArg.NONE,
        _ ("Show the version of the program and exit"), null);

      add_main_option ("backend", 'b',
        OptionFlags.IN_MAIN, OptionArg.STRING,
        _ ("Select the recording backend (gnome-shell, ffmpeg)"),
        _ ("BACKEND"));

      add_main_option ("start", 's',
        OptionFlags.IN_MAIN, OptionArg.NONE,
        _ ("Start recording in all running Peek instances"), null);

      add_main_option ("stop", 'p',
        OptionFlags.IN_MAIN, OptionArg.NONE,
        _ ("Stop recording in all running Peek instances"), null);

      add_main_option ("toggle", 't',
        OptionFlags.IN_MAIN, OptionArg.NONE,
        _ ("Toggle recording in all running Peek instances"), null);

      add_main_option ("no-headerbar", 0,
        OptionFlags.IN_MAIN, OptionArg.NONE,
        _ ("Start Peek without the header bar"), null);
    }

    public override void activate () {
      this.new_window ();
    }

    public override void startup () {
      base.startup ();
      load_stylesheets ();
      Environment.set_application_name (_ ("Peek"));
      register_actions ();

#if HAS_KEYBINDER
      if (DesktopIntegration.is_x11_backend ()) {
        register_key_bindings ();
      }
#endif
    }

    public void request_quit () {
      debug ("Application was requested to quit");
      foreach (var window in this.get_windows ()) {
        window.close ();
      }
    }

    public override void shutdown () {
      debug ("Application got shutdown signal");
      foreach (var window in this.get_windows ()) {
        var app_window = (window as ApplicationWindow);
        if (app_window != null) {
          app_window.recorder.cancel ();
        }
      }

#if HAS_KEYBINDER
      unregister_key_bindings ();
#endif

      base.shutdown ();
    }

    protected override int handle_local_options (VariantDict options) {
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

      if (options.contains ("no-headerbar") && main_window != null) {
        main_window.hide_headerbar ();
      }

      return Posix.EXIT_SUCCESS;
    }

    private void register_actions () {
      // Application actions
      SimpleAction action;

      action = new SimpleAction ("new-window", null);
      action.activate.connect (new_window);
      add_action (action);

      action = new SimpleAction ("new-window-with-backend", VariantType.STRING);
      action.activate.connect (new_window_with_backend);
      add_action (action);

      action = new SimpleAction ("set-window-size", null);
      action.activate.connect (set_window_size);
      add_action (action);

      action = new SimpleAction ("preferences", null);
      action.activate.connect (show_preferences);
      add_action (action);

      action = new SimpleAction ("about", null);
      action.activate.connect (show_about);
      add_action (action);

      action = new SimpleAction ("quit", null);
      action.activate.connect (request_quit);
      add_action (action);

#if ! DISABLE_OPEN_FILE_MANAGER
      action = new SimpleAction ("show-file", VariantType.STRING);
      action.activate.connect (show_file);
      add_action (action);
#endif
    }

#if HAS_KEYBINDER
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
#endif

    private void new_window () {
      try {
        var recorder = ScreenRecorderFactory.create_default_screen_recorder ();
        show_window (recorder);
      } catch (PeekError e) {
        var msg = _ ("Unable to initialize default recording backend: %s").printf (
          e.message);
        stderr.printf ("%s\n", msg);
        show_recording_backend_warning (msg);
      }
    }

    private void new_window_with_backend (Variant? backend) {
      size_t length;
      string backend_name = backend.get_string (out length);
      stdout.printf ("Requested screen recording backend %s\n", backend_name);

      try {
        var recorder = ScreenRecorderFactory.create_screen_recorder (backend_name);
        show_window (recorder);
      } catch (PeekError e) {
        var msg = _ ("Unable to initialize recording backend %s: %s").printf (
          backend_name, e.message);
        stderr.printf ("%s\n", msg);
        show_recording_backend_warning (msg);
      }
    }

    private void set_window_size () {
      SetWindowSizeDialog.present_single_instance(main_window);
    }

    private void show_window (ScreenRecorder recorder) {
      if (DesktopIntegration.is_wayland_backend ()) {
        show_wayland_warning ();
        return;
      }

      main_window = new ApplicationWindow (this, recorder);
      main_window.present ();
    }

    private void show_preferences () {
      PreferencesDialog.present_single_instance (main_window);
    }

    private void show_about () {
      AboutDialog.present_single_instance (main_window);
    }

    private static void load_stylesheets () {
      load_stylesheet_by_name ("peek");
      string theme = DesktopIntegration.get_theme_name ();
      debug ("GTK theme: %s", theme);
      if (theme == "Ambiance" || theme == "Breeze" || theme == "Breeze-Dark") {
        load_stylesheet_by_name (theme.down ());
      }

      if (DesktopIntegration.is_unity ()) {
        load_stylesheet_by_name ("unity");
      }
    }

    private static void load_stylesheet_by_name (string name) {
      var uri = "resource:///com/uploadedlobster/peek/css/%s.css".printf (name);
      load_stylesheet_from_uri (uri);
    }

    private static void load_stylesheet_from_uri (string uri) {
      var provider = new Gtk.CssProvider ();
      try {
        var file = File.new_for_uri (uri);
        provider.load_from_file (file);
        var screen = Gdk.Screen.get_default ();
        Gtk.StyleContext.add_provider_for_screen (screen, provider,
          GTK_STYLE_PROVIDER_PRIORITY_APPLICATION);
      }
      catch (Error e) {
        stderr.printf ("Loading application stylesheet %s failed: %s", uri, e.message);
      }
    }

#if ! DISABLE_OPEN_FILE_MANAGER
    private void show_file (Variant? uri) {
      var uri_str = uri.get_string ();
      debug ("Action show-file called with URI %s", uri_str);
      var file = File.new_for_uri (uri_str);
      DesktopIntegration.launch_file_manager (file);
    }
#endif

    private void show_recording_backend_warning (string msg) {
      show_startup_warning (_ ("Recording backend unavailable"), msg);
    }

    private void show_wayland_warning () {
      var title = _ ("Native Wayland backend is unsupported");
      var text = _ ("You are running Peek natively on Wayland, this is currently unsupported. Please start Peek using XWayland by setting <tt>GDK_BACKEND=x11</tt>.\n\nFor Details see the Peek <a href='https://github.com/phw/peek#why-no-native-wayland-support'>FAQ about Wayland support</a>.");
      show_startup_warning (title, text);
    }

    private void show_startup_warning (string title, string text) {
      // FIXME: Calling this with "%s", "" avoids C compilation warning.
      // Passing null would be cleaner, but currently not possible
      // (https://bugzilla.gnome.org/show_bug.cgi?id=791570)
      var msg = new Gtk.MessageDialog (null, Gtk.DialogFlags.MODAL,
        Gtk.MessageType.WARNING, Gtk.ButtonsType.OK, "%s", "");
      msg.text = title;
      msg.secondary_use_markup = true;
      msg.secondary_text = text;
      msg.run ();
    }
  }

}
