/*
Peek Copyright (c) 2017 by Philipp Wolfer <ph.wolfer@gmail.com>

This file is part of Peek.

This software is licensed under the GNU General Public License
(version 3 or later). See the LICENSE file in this distribution.
*/

using Peek.Recording;

namespace Peek.PostProcessing {

  /**
  * Use FFmpeg to generate an optimized GIF from a video input
  */
  public class FfmpegPostProcessor : CliPostProcessor {
    private RecordingConfig config;

    public FfmpegPostProcessor (RecordingConfig config) {
      this.config = config;
    }

    public override async Array<File>? process_async (Array<File> files) {
      var input_file = files.index (0);
      var palette_file = yield generate_palette_async (input_file);

      if (palette_file == null) {
        return null;
      }

      var output_file = yield generate_animation_async (input_file, palette_file);
      try {
        yield palette_file.delete_async ();
      } catch (Error e) {
        stderr.printf ("Error deleting palette file: %s\n", e.message);
      }

      if (output_file == null) {
        return null;
      }

      var result = new Array<File> ();
      result.append_val (output_file);
      return result;
    }

    public static bool is_available () {
      return Utils.check_for_executable ("ffmpeg");
    }

    private async File? generate_palette_async (File file) {
      try {
        var palette_file = Utils.create_temp_file ("png");

        string[] args = {
          "ffmpeg", "-y",
          "-i", file.get_path (),
          "-vf", "fps=%d,palettegen".printf (config.framerate),
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
        var extension = Utils.get_file_extension_for_format (config.output_format);
        var output_file = Utils.create_temp_file (extension);

        string[] args = {
          "ffmpeg", "-y",
          "-i", input_file.get_path (),
          "-i", palette_file.get_path (),
          "-filter_complex", "fps=%d,paletteuse".printf (config.framerate)
        };

        var argv = new Array<string> ();
        argv.append_vals (args, args.length);

        if (config.output_format == OUTPUT_FORMAT_APNG) {
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
