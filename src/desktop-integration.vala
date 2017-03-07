/*
Peek Copyright (c) 2015-2017 by Philipp Wolfer <ph.wolfer@gmail.com>

This file is part of Peek.

This software is licensed under the GNU General Public License
(version 3 or later). See the LICENSE file in this distribution.
*/

namespace Peek {

  public class DesktopIntegration {
    private static Freedesktop.FileManager1? _file_manager = null;
    private static Freedesktop.FileManager1 file_manager {
      get {
        if (_file_manager == null) {
          _file_manager = Bus.get_proxy_sync (
            BusType.SESSION,
            "org.freedesktop.FileManager1",
            "/org/freedesktop/FileManager1");
        }

        return _file_manager;
      }
    }

    public static bool launch_file_manager (File file) {
      var uri = file.get_uri ();
      debug ("File URI: %s\n", uri);

      // First try using standardized DBus service
      try {
        debug ("Launching org.freedesktop.FileManager1 for URI: %s\n", uri);
        file_manager.show_items ({uri}, "");
        return true;
      } catch (Error e) {
        stderr.printf ("Unable to call org.freedesktop.FileManager1: %s\n", e.message);
      }

      // If this does not work try getting the default app for handling
      // directories and launch that.
      try {
        var parent = file.get_parent ();

        AppInfo app_info = null;
        if (file.has_uri_scheme ("file")) {
          app_info = AppInfo.get_default_for_type (
            "inode/directory", true);
        }

        if (app_info == null && parent != null) {
          try {
            app_info = parent.query_default_handler ();
          } catch (Error e) {
            stderr.printf ("Unable to get AppInfo for parent folder: %s\n", parent.get_uri ());
          }
        }

        if (app_info != null) {
          if (parent != null && !file_manager_highlights_file (app_info)) {
            uri = parent.get_uri ();
          }

          debug ("Launching \"%s\" for URI: %s\n", app_info.get_display_name (), uri);
          var uri_list = new List<string> ();
          uri_list.append (uri);
          app_info.launch_uris (uri_list, null);
          return true;
        }

        if (parent != null) {
          uri = parent.get_uri ();
        }

        debug ("Launching default for URI: %s\n", uri);
        AppInfo.launch_default_for_uri (uri, null);
        return true;
      } catch (Error e) {
        stderr.printf ("Launching file manager failed: %s\n", e.message);
        return false;
      }
    }

    public static string get_video_folder () {
      string folder;
      folder = GLib.Environment.get_user_special_dir (GLib.UserDirectory.VIDEOS);

      if (folder == null) {
        folder = GLib.Environment.get_user_special_dir (GLib.UserDirectory.PICTURES);
      }

      if (folder == null) {
        folder = GLib.Environment.get_home_dir ();
      }

      return folder;
    }

    public static bool is_unity () {
      return xdg_current_desktop_contains ("Unity");
    }

    public static bool is_gnome () {
      return xdg_current_desktop_contains ("GNOME");
    }

    public static bool is_wayland () {
      string? wayland_display = GLib.Environment.get_variable ("WAYLAND_DISPLAY");
      return wayland_display != null && wayland_display != "";
    }

    public static bool is_x11_backend () {
      var window_type = Gdk.DisplayManager.get ().default_display.get_type ();
      return window_type.name () == "GdkX11Display";
    }

    public static bool is_wayland_backend () {
      var window_type = Gdk.DisplayManager.get ().default_display.get_type ();
      return window_type.name () == "GdkWaylandDisplay";
    }

    private static bool xdg_current_desktop_contains (string text) {
      string desktop = GLib.Environment.get_variable ("XDG_CURRENT_DESKTOP") ?? "";
      debug ("Desktop: %s", desktop);
      return desktop.contains (text);
    }

    private static bool file_manager_highlights_file (AppInfo app_info) {
      var exe = app_info.get_executable ();
      return exe == "nautilus" || exe == "nemo";
    }
  }

}
