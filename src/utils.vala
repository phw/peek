/*
Peek Copyright (c) 2015-2018 by Philipp Wolfer <ph.wolfer@gmail.com>

This file is part of Peek.

This software is licensed under the GNU General Public License
(version 3 or later). See the LICENSE file in this distribution.
*/

namespace Peek {

  public class Utils {
    public static string get_temp_dir () {
      string cache_dir_path = Path.build_filename (
        Environment.get_user_cache_dir (), "peek"
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
      var fd = FileUtils.mkstemp (file_name);
      FileUtils.close (fd);
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
      var path = Environment.find_program_in_path (executable);
      return path != null;
    }

    public static string get_file_extension_for_format (OutputFormat output_format) {
      return output_format.to_string ();
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
    * Returns -1 if memory could not be read
    */
    public static int get_available_system_memory () {
      var stream = FileStream.open ("/proc/meminfo", "r");
      assert (stream != null);

      string line;
      while ((line = stream.read_line ()) != null) {
        if (line.has_prefix ("MemAvailable")) {
          int memory = 0;
          line.scanf ("MemAvailable: %d kB", &memory);
          return memory;
        }
      }

      return -1;
    }

    public static string get_command_failed_message (string[] argv, Subprocess? subprocess = null) {
      int status = -1;
      int term_sig = 0;
      string? output = null;

      if (subprocess != null) {
        status = subprocess.get_status ();
        if (subprocess.get_if_signaled ()) {
          term_sig = subprocess.get_term_sig ();
        }

        var stdout_pipe = subprocess.get_stdout_pipe ();
        if (stdout_pipe != null) {
          output = read_instream_as_utf8 (stdout_pipe);
        }
      }

      string message = "Command \"%s\" failed with status %i (received signal %i).".printf (
        string.joinv (" ", argv), status, term_sig);

      if (output != null) {
        message += "\n\nOutput:\n%s".printf (output);
      }

      return message;
    }

    private static string? read_instream_as_utf8 (InputStream stream) {
      var output = new StringBuilder ();
      var dis = new DataInputStream (stream);
      string line;

      try {
        while ((line = dis.read_line_utf8 (null)) != null) {
          output.append (line);
        }
      } catch (IOError e) {
        stderr.printf ("Error: %s\n", e.message);
        return null;
      }

      return output.str;
    }

    private const string NUMBER_FORMAT = "%02" + int64.FORMAT_MODIFIER + "d";
    private const string TIME_FORMAT = NUMBER_FORMAT + ":" + NUMBER_FORMAT;
    public static string format_time (int64 seconds) {
      return TIME_FORMAT.printf (seconds / 60, seconds % 60);
    }
  }

}
