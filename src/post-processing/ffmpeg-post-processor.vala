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
  public class FfmpegPostProcessor : CliPostProcessor {
    public int framerate { get; set; default = 15; }

    private string output_format;

    public FfmpegPostProcessor (int framerate, string output_format) {
      this.framerate = framerate;
      this.output_format = output_format;
    }

    public override async File[]? process_async (File[] files) {
      var palette_file = yield generate_palette_async (files[0]);

      if (palette_file == null) {
        return null;
      }

      var output_file = yield generate_animation_async (files[0], palette_file);
      try {
        yield palette_file.delete_async ();
      } catch (Error e) {
        stderr.printf ("Error deleting palette file: %s\n", e.message);
      }

      return { output_file };
    }

    private async File? generate_palette_async (File file) {
      try {
        var palette_file = Utils.create_temp_file ("png");

        string[] args = {
          "ffmpeg", "-y",
          "-i", file.get_path (),
          "-vf", "fps=%d,palettegen".printf(framerate),
          palette_file
        };

        var status = yield spawn_command_async (args);

        if (!Utils.is_exit_status_success (status)) {
          FileUtils.remove (palette_file);
          return null;
        }

        return File.new_for_path (palette_file);
      } catch (FileError e) {
        stderr.printf ("Error: %s\n", e.message);
        return null;
      }
    }

    private async File? generate_animation_async (File input_file, File palette_file) {
      try {
        var extension = Utils.get_file_extension_for_format (output_format);
        var output_file = Utils.create_temp_file (extension);

        string[] args = {
          "ffmpeg", "-y",
          "-i", input_file.get_path (),
          "-i", palette_file.get_path (),
          "-filter_complex", "fps=%d,paletteuse".printf(framerate)
        };

        var argv = new Array<string> ();
        argv.append_vals (args, args.length);

        if (output_format == OUTPUT_FORMAT_APNG) {
          argv.append_val ("-plays");
          argv.append_val ("0");
        }

        argv.append_val (output_file);

        var status = yield spawn_command_async (argv.data);

        if (!Utils.is_exit_status_success (status)) {
          FileUtils.remove (output_file);
          return null;
        }

        return File.new_for_path (output_file);
      } catch (FileError e) {
        stderr.printf ("Error: %s\n", e.message);
        return null;
      }
    }
  }
}
