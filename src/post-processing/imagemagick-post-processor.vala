/*
Peek Copyright (c) 2016-2017 by Philipp Wolfer <ph.wolfer@gmail.com>

This file is part of Peek.

This software is licensed under the GNU General Public License
(version 3 or later). See the LICENSE file in this distribution.
*/

namespace Peek.PostProcessing {

  [Version (deprecated = true, replacement = "FfmpegPostProcessor")]
  public class ImagemagickPostProcessor : CliPostProcessor {
    public int framerate { get; set; default = 15; }

    private int memory_limit {
      get {
        int available_memory = Utils.get_available_system_memory ();
        int memory_limit = available_memory;
        if (available_memory > 0) {
          memory_limit = (int)(available_memory * 0.9);
        }

        return memory_limit;
      }
    }

    public ImagemagickPostProcessor (int framerate) {
      this.framerate = framerate;
    }

    public override async File[]? process_async (File[] files) {
      try {
        double delay = (100.0 / framerate);
        var output_file = Utils.create_temp_file ("gif");
        var temp_dir = Utils.get_temp_dir ();

        string? magick_debug = Environment.get_variable ("PEEK_MAGICK_DEBUG");
        if (Utils.string_is_empty (magick_debug)) {
          magick_debug = "None";
        }

        debug ("Running ImageMagick convert\n    saving to: %s\n    temporary path: %s\n    memory limit: %d kiB",
          output_file, temp_dir, memory_limit);

        string[] args = {
          "convert",
          "-debug", magick_debug,
          "-set", "delay", delay.to_string (),
          "-limit", "disk", "unlimited",
          "-limit", "memory", "%dkiB".printf(memory_limit),
          "-layers", "Optimize",
          "-define", "registry:temporary-path=" + temp_dir,
        };

        var argv = new Array<string> ();
        argv.append_vals (args, args.length);
        foreach (var file in files) {
          argv.append_val (file.get_path ());
        }
        argv.append_val (output_file);

        var status = yield spawn_command_async (argv.data);

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
