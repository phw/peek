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
  public class ExtractFramesPostProcessor : Object, PostProcessor {
    private Pid? pid = null;

    // public ExtractFramesPostProcessor () {
    // }

    public async File[]? process_async (File[] files) {
      var input_file = files[0];
      string[] args = {
        "ffmpeg", "-y",
        "-i", files[0].get_path (),
        get_png_filename_pattern (input_file, "%04d")
      };

      int status = yield spawn_command_async (args);

      var png_file_pattern = get_png_filename_pattern (input_file, "*");
      var glob = Posix.Glob ();
      glob.glob (png_file_pattern);

      if (!Utils.is_exit_status_success (status)) {
        foreach (string png_file_path in glob.pathv) {
          FileUtils.remove (png_file_path);
        }

        return null;
      }

      var output = new Array<File> ();
      foreach (string png_file_path in glob.pathv) {
        var file = File.new_for_path (png_file_path);
        output.append_val (file);
      }

      return output.data;
    }

    public void cancel () {
      if (pid != null) {
        Posix.kill (pid, Posix.SIGINT);
      }
    }

    private async int spawn_command_async (string[] argv) {
      try {
        SourceFunc callback = spawn_command_async.callback;

        this.spawn (argv);
        int return_status = -1;

        ChildWatch.add (pid, (pid, status) => {
          // Triggered when the child indicated by pid exits
          Process.close_pid (pid);
          Idle.add ((owned) callback);
          this.pid = null;
          return_status = status;
        });

        yield;
        return return_status;
      } catch (SpawnError e) {
        stderr.printf ("Error: %s\n", e.message);
        return -1;
      }
    }

    private void spawn (string[] argv) throws SpawnError {
      Process.spawn_async (null, argv, null,
        SpawnFlags.SEARCH_PATH | SpawnFlags.DO_NOT_REAP_CHILD, null, out pid);
    }

    private static string get_png_filename_pattern (File input_file, string replacement) {
      return input_file.get_path () + "." + replacement + ".png";
    }
  }
}
