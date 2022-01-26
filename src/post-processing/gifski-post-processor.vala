/*
Peek Copyright (c) 2017-2018 by Philipp Wolfer <ph.wolfer@gmail.com>

This file is part of Peek.

This software is licensed under the GNU General Public License
(version 3 or later). See the LICENSE file in this distribution.
*/

using Peek.Recording;

namespace Peek.PostProcessing {

  /**
  * Use gifski (https://gif.ski/) to generate an optimized GIF from a video input
  */
  public class GifskiPostProcessor : CliPostProcessor {
    private RecordingConfig config;

    public GifskiPostProcessor (RecordingConfig config) {
      this.config = config;
    }

    public override async Array<File>? process_async (Array<File> files) throws RecordingError {
      try {
        var extension = Utils.get_file_extension_for_format (OutputFormat.GIF);
        var output_file = Utils.create_temp_file (extension);

        debug ("Running gifski\n    saving to: %s\n    quality: %d\n",
          output_file, config.gifski_quality);

        var argv = new Array<string> ();

        argv.append_val ("gifski");

        argv.append_val ("--fps");
        argv.append_val (config.framerate.to_string ());

        argv.append_val ("--quality");
        argv.append_val (config.gifski_quality.to_string ());

        argv.append_val ("-o");
        argv.append_val (output_file);

        foreach (var file in files.data) {
          argv.append_val (file.get_path ());
        }

        try {
          yield spawn_command_async (argv.data);
        } catch (RecordingError e) {
          FileUtils.remove (output_file);
          throw e;
        }

        var result = new Array<File> ();
        result.append_val (File.new_for_path (output_file));
        return result;
      } catch (FileError e) {
        stderr.printf ("Error: %s\n", e.message);
        throw new RecordingError.POSTPROCESSING_ABORTED (e.message);
      }
    }

    public static bool is_available () {
      return Utils.check_for_executable ("gifski");
    }
  }
}
