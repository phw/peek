/*
Peek Copyright (c) 2017 by Philipp Wolfer <ph.wolfer@gmail.com>

This file is part of Peek.

This software is licensed under the GNU General Public License
(version 3 or later). See the LICENSE file in this distribution.
*/

namespace Peek.PostProcessing {

  /**
  * Use FFmpeg to generate an optimized GIF from a video input
  */
  public class FfmpegGifPostProcessor : Object, PostProcessor {
    public int framerate { get; set; default = 15; }

    private Pid? pid = null;

    public FfmpegGifPostProcessor (int framerate) {
      this.framerate = framerate;
    }

    public async File? process_async (File file) {
        var palette_file = yield generate_palette_async (file);

        if (palette_file == null) {
          return null;
        }

        var output_file = yield generate_gif_async (file, palette_file);
        try {
          yield palette_file.delete_async ();
        } catch (Error e) {
          stderr.printf ("Error deleting palette file: %s\n", e.message);
        }

        return output_file;
    }

    public void cancel () {
      if (pid != null) {
        Posix.kill (pid, Posix.SIGINT);
      }
    }

    private async File? generate_palette_async (File file) {
      string[] args = {
        "ffmpeg", "-y",
        "-i", file.get_path (),
        "-vf", "fps=%d,palettegen".printf(framerate)
      };

      var argv = new Array<string> ();
      argv.append_vals (args, args.length);

      return yield spawn_file_conversion_async (argv, "png");
    }

    private async File? generate_gif_async (File input_file, File palette_file) {
      string[] args = {
        "ffmpeg", "-y",
        "-i", input_file.get_path (),
        "-i", palette_file.get_path (),
        "-filter_complex", "fps=%d,paletteuse".printf(framerate)
      };

      var argv = new Array<string> ();
      argv.append_vals (args, args.length);

      return yield spawn_file_conversion_async (argv, "gif");
    }

    private async File? spawn_file_conversion_async (Array<string> argv, string output_extension) {
      try {
        SourceFunc callback = spawn_file_conversion_async.callback;

        var output_file = Utils.create_temp_file (output_extension);
        argv.append_val (output_file);

        this.spawn (argv.data);

        ChildWatch.add (pid, (pid, status) => {
          // Triggered when the child indicated by pid exits
          Process.close_pid (pid);
          Idle.add ((owned) callback);
          this.pid = null;

          if (!Utils.is_exit_status_success (status)) {
            FileUtils.remove (output_file);
          }
        });

        yield;
        return File.new_for_path (output_file);
      } catch (SpawnError e) {
        stderr.printf ("Error: %s\n", e.message);
        return null;
      } catch (FileError e) {
        stderr.printf ("Error: %s\n", e.message);
        return null;
      }
    }

    private void spawn (string[] argv) {
      Process.spawn_async (null, argv, null,
        SpawnFlags.SEARCH_PATH | SpawnFlags.DO_NOT_REAP_CHILD, null, out pid);
    }
  }
}
