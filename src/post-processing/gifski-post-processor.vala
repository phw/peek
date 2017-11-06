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
  public class GifskiPostProcessor : CliPostProcessor {
    public static int DEFAULT_QUALITY = 60;
    public int framerate { get; set; default = 15; }
    public int quality { get; set; default = DEFAULT_QUALITY; }

    public GifskiPostProcessor (int framerate, int quality = DEFAULT_QUALITY) {
      this.framerate = framerate;
      this.quality = quality;
    }

    public override async File[]? process_async (File[] files) {
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

        int status = yield spawn_command_async (argv.data);

        if (!Utils.is_exit_status_success (status)) {
          FileUtils.remove (output_file);
          return null;
        }

        return { File.new_for_path (output_file) };
      } catch (FileError e) {
        stderr.printf ("Error: %s\n", e.message);
        return null;
      }
    }
  }
}
