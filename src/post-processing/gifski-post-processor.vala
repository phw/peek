/*
Peek Copyright (c) 2017 by Philipp Wolfer <ph.wolfer@gmail.com>

This file is part of Peek.

This software is licensed under the GNU General Public License
(version 3 or later). See the LICENSE file in this distribution.
*/

namespace Peek.PostProcessing {

  /**
  * Use gifski (https://gif.ski/) to generate an optimized GIF from a video input
  */
  public class GifskiPostProcessor : Object, PostProcessor {
    public int framerate { get; set; default = 15; }

    private Pid? pid = null;

    public GifskiPostProcessor (int framerate) {
      this.framerate = framerate;
    }

    public async File? process_async (File file) {
        var status = yield generate_pngs_async (file);

        if (!Utils.is_exit_status_success (status)) {
          return null;
        }

        var output_file = yield generate_animation_async (file);
        return output_file;
    }

    public void cancel () {
      if (pid != null) {
        Posix.kill (pid, Posix.SIGINT);
      }
    }

    private async int generate_pngs_async (File file) {
      string[] args = {
        "ffmpeg", "-y",
        "-i", file.get_path (),
        get_png_filename_pattern (file, "%04d")
      };

      return yield spawn_file_conversion_async (args);
    }

    private async File? generate_animation_async (File input_file) {
      try {
        var extension = Utils.get_file_extension_for_format (OUTPUT_FORMAT_GIF);
        var output_file = Utils.create_temp_file (extension);

        var png_file_pattern = get_png_filename_pattern (input_file, "*");
        var glob = Posix.Glob ();
        glob.glob (png_file_pattern);

        string[] args = {
          "gifski",
          "--fps", framerate.to_string (),
          "-o", output_file
        };

        var argv = new Array<string> ();
        argv.append_vals (args, args.length);
        argv.append_vals (glob.pathv, (uint)glob.pathc);

        int status = yield spawn_file_conversion_async (argv.data);

        if (!Utils.is_exit_status_success (status)) {
          FileUtils.remove (output_file);
        }

        foreach (string temp_file_path in glob.pathv) {
          FileUtils.remove (temp_file_path);
        }

        return File.new_for_path (output_file);
      } catch (FileError e) {
        stderr.printf ("Error: %s\n", e.message);
        return null;
      }
    }

    private async int spawn_file_conversion_async (string[] argv) {
      try {
        SourceFunc callback = spawn_file_conversion_async.callback;

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
