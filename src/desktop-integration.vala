/*
Peek Copyright (c) 2015-2016 by Philipp Wolfer <ph.wolfer@gmail.com>

This file is part of Peek.

This software is licensed under the GNU General Public License
(version 3 or later). See the LICENSE file in this distribution.
*/

namespace Peek {

  public class DesktopIntegration {
    public static bool launch_file_manager (File file) {
      try {
        var uri = file.get_uri ();
        var parent = file.get_parent ();
        debug ("File URI: %s\n", uri);

        AppInfo app_info = null;
        if (file.has_uri_scheme ("file")) {
          app_info = AppInfo.get_default_for_type (
            "inode/directory", true);
        }

        if (app_info == null && parent != null) {
          try {
            app_info = parent.query_default_handler ();
          }
          catch (Error e) {
            stderr.printf ("Unable to get AppInfo for parent folder: %s\n", parent.get_uri ());
          }
        }

        if (app_info != null) {
          if (parent != null && !file_manager_highlights_file (app_info)) {
            uri = parent.get_uri ();
          }

          debug("Launching \"%s\" for URI: %s\n", app_info.get_display_name (), uri);
          var uri_list = new List<string> ();
          uri_list.append (uri);
          app_info.launch_uris (uri_list, null);
          return true;
        }

        if (parent != null) {
          uri = parent.get_uri ();
        }

        debug("Launching default for URI: %s\n", uri);
        AppInfo.launch_default_for_uri (uri, null);
        return true;
      }
      catch (Error e) {
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
      string desktop = GLib.Environment.get_variable ("XDG_CURRENT_DESKTOP") ?? "";
      debug ("Desktop: %s", desktop);
      return desktop.contains ("Unity");
    }

    private static bool file_manager_highlights_file (AppInfo app_info) {
      var exe = app_info.get_executable ();
      return exe == "nautilus" || exe == "nemo";
    }
  }

}
