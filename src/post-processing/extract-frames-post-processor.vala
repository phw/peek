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
    private static Posix.Glob glob = Posix.Glob ();

    public override async Array<File>? process_async (Array<File> files) throws RecordingError {
      var input_file = files.index (0);
      string[] args = {
        find_executable (), "-y",
        "-i", input_file.get_path (),
        get_png_filename_pattern (input_file, "%04d")
      };

      try {
        yield spawn_command_async (args);
      } catch (RecordingError e) {
        yield remove_output_files (input_file);
        throw e;
      }

      var output = get_png_output_files (input_file);
      return output;
    }

    private static string get_png_filename_pattern (File input_file, string replacement) {
      return input_file.get_path () + "." + replacement + ".png";
    }

    public static Array<File> get_png_output_files (File input_file) {
      var png_file_pattern = get_png_filename_pattern (input_file, "*");
      glob.glob (png_file_pattern);
      var output = new Array<File> ();
      foreach (string png_file_path in glob.pathv) {
        var file = File.new_for_path (png_file_path);
        output.append_val (file);
      }

      return output;
    }

    private static async void remove_output_files (File input_file) {
      var output = get_png_output_files (input_file);
      foreach (File file in output.data) {
        try {
          yield file.delete_async ();
        } catch (Error e) {
          stderr.printf ("Error deleting temporary file %s: %s\n", file.get_path (), e.message);
        }
      }
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
