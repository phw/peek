/*
Peek Copyright (c) 2017 by Philipp Wolfer <ph.wolfer@gmail.com>

This file is part of Peek.

This software is licensed under the GNU General Public License
(version 3 or later). See the LICENSE file in this distribution.
*/

namespace Peek.PostProcessing {

  /**
  * Uses ffmpeg to generate PNG images for each frame.
  */
  public class ExtractFramesPostProcessor : CliPostProcessor {
    private string executable = null;

    public override async Array<File>? process_async (Array<File> files) {
      var input_file = files.index (0);
      string[] args = {
        find_executable (), "-y",
        "-i", input_file.get_path (),
        get_png_filename_pattern (input_file, "%04d")
      };

      int status = yield spawn_command_async (args);

      var output = yield get_png_output_files_async (input_file);

      if (!Utils.is_exit_status_success (status)) {
        foreach (File file in output.data) {
          try {
            yield file.delete_async ();
          } catch (Error e) {
            stderr.printf ("Error deleting temporary file %s: %s\n", file.get_path (), e.message);
          }
        }

        return null;
      }

      return output;
    }

    private static string get_png_filename_pattern (File input_file, string replacement) {
      return input_file.get_path () + "." + replacement + ".png";
    }

    private async Array<File> get_png_output_files_async (File input_file) {
      var dir = input_file.get_parent ();
      var output = new Array<File> ();

      try {
        FileEnumerator enumerator = yield dir.enumerate_children_async ("",
          FileQueryInfoFlags.NOFOLLOW_SYMLINKS,
          Priority.DEFAULT, null);

        FileInfo info;
        var basename = input_file.get_basename ();
        while ((info = enumerator.next_file (null)) != null) {
          var name = info.get_name ();
          if (info.get_file_type () == FileType.REGULAR
              && name.has_prefix (basename + ".")
              && name.has_suffix (".png")) {
            var file = dir.resolve_relative_path (info.get_name ());
            output.append_val (file);
          }
        }
      } catch (Error e) {
        stdout.printf ("Error: %s\n", e.message);
      }

      return output;
    }

    private string find_executable () {
      if (executable == null) {
        string[] tools = { "ffmpeg", "avconv" };
        foreach (string tool in tools) {
          if (Utils.check_for_executable (tool)) {
            executable = tool;
            break;
          }
        }
      }

      debug ("ExtractFramesPostProcessor uses %s", executable);
      return executable;
    }
  }
}
