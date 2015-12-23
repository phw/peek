/*
Peek Copyright (c) 2015 by Philipp Wolfer <ph.wolfer@gmail.com>

This file is part of Peek.

This software is licensed under the GNU General Public License
(version 3 or later). See the LICENSE file in this distribution.
*/

public class DesktopIntegration {
  public static bool launch_file_manager (File file) {
    try {
      var uri = file.get_uri ();
      stdout.printf("URI: %s\n", uri);

      if (file.has_uri_scheme ("file")) {
        AppInfo app_info = AppInfo.get_default_for_type (
          "inode/directory", true);
        if (app_info != null) {
          var uri_list = new List<string> ();
          uri_list.append (uri);
          app_info.launch_uris (uri_list, null);
          return true;
        }
      }

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
}
