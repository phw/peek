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
    public static int DEFAULT_QUALITY = 60;
    public int framerate { get; set; default = 15; }
    public int quality { get; set; default = DEFAULT_QUALITY; }

    private Pid? pid = null;

    public GifskiPostProcessor (int framerate, int quality = DEFAULT_QUALITY) {
      this.framerate = framerate;
      this.quality = quality;
    }

    public async File[]? process_async (File[] files) {
      try {
        var extension = Utils.get_file_extension_for_format (OUTPUT_FORMAT_GIF);
        var output_file = Utils.create_temp_file (extension);

        string[] args = {
          "gifski",
          "--fps", framerate.to_string (),
          "--quality", quality.to_string (),
          "-o", output_file
        };

        var argv = new Array<string> ();
        argv.append_vals (args, args.length);
        foreach (var file in files) {
          argv.append_val (file.get_path ());
        }

        int status = yield spawn_file_conversion_async (argv.data);

        if (!Utils.is_exit_status_success (status)) {
          FileUtils.remove (output_file);
        }

        return { File.new_for_path (output_file) };
      } catch (FileError e) {
        stderr.printf ("Error: %s\n", e.message);
        return null;
      }
    }

    public void cancel () {
      if (pid != null) {
        Posix.kill (pid, Posix.SIGINT);
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
  }
}
