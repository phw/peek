/*
Peek Copyright (c) 2015-2017 by Philipp Wolfer <ph.wolfer@gmail.com>

This file is part of Peek.

This software is licensed under the GNU General Public License
(version 3 or later). See the LICENSE file in this distribution.
*/

namespace Peek {

  public class Utils {
    public static string create_temp_file (string extension) throws FileError {
      string file_name;
      var fd = FileUtils.open_tmp ("peekXXXXXX." + extension, out file_name);
      FileUtils.close (fd);
      return file_name;
    }

    public static bool is_exit_status_success (int status) {
      try {
        if (Process.check_exit_status (status)) {
          return true;
        }
      }
      catch (Error e) {
        stderr.printf ("Error: %s\n", e.message);
      }

      return false;
    }

    public static bool check_for_executable (string executable) {
      string[] args = {
        "which", executable
      };

      int status;
      string output;
      string errorout;

      try {
        Process.spawn_sync (null, args, null,
          SpawnFlags.SEARCH_PATH,
          null, out output, out errorout, out status);
        debug ("Looking for executable %s (%i): %s%s",
          executable, status, output, errorout);
        return Utils.is_exit_status_success (status);
      } catch (SpawnError e) {
        debug ("Error: %s", e.message);
      }

      return false;
    }
  }

}
