/*
Peek Copyright (c) 2015-2017 by Philipp Wolfer <ph.wolfer@gmail.com>

This file is part of Peek.

This software is licensed under the GNU General Public License
(version 3 or later). See the LICENSE file in this distribution.
*/

namespace Peek {

  public class Utils {
    public static string get_temp_dir () {
      string cache_dir_path = Path.build_filename (
        GLib.Environment.get_user_cache_dir (), "peek"
      );
      var cache_dir = File.new_for_path (cache_dir_path);

      try {
        cache_dir.make_directory_with_parents (null);
      } catch (Error e) {
        if (e is IOError.EXISTS) {
          debug ("Cache directory does already exist %s\n", cache_dir_path);
        } else {
          stderr.printf ("Error: %s\n", e.message);
          return Environment.get_tmp_dir ();
        }
      }

      return cache_dir.get_path ();
    }

    public static string create_temp_file (string extension) throws FileError {
      var temp_dir = get_temp_dir ();
      var file_name = Path.build_filename (temp_dir, "peekXXXXXX." + extension);
      debug ("Temp file: %s\n", file_name);
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

    public static string get_file_extension_for_format (string output_format) {
      switch (output_format) {
        case OUTPUT_FORMAT_WEBM:
          return "webm";
        case OUTPUT_FORMAT_MP4:
          return "mp4";
        case OUTPUT_FORMAT_GIF:
          return "gif";
        default:
          return "";
      }
    }

    public static bool string_is_empty (string? str) {
      if (str == null) return true;

      unichar c;
      for (int i = 0; str.get_next_char (ref i, out c);) {
        if (!c.isspace () && !c.iscntrl ()) return false;
      }

      return true;
    }

    public static int make_even (int i) {
      return (i / 2) * 2;
    }

    /**
    * Returns available system memory in kiB.
    *
    * Returns -1 if memory could not be read.
    */
    public static int get_system_memory () {
      var stream = FileStream.open ("/proc/meminfo", "r");
      assert (stream != null);

      int memory = -1;
      stream.scanf ("MemTotal: %d kB", &memory);
      return memory;
    }
  }

}
