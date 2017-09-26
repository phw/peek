/*
Peek Copyright (c) 2016-2017 by Philipp Wolfer <ph.wolfer@gmail.com>

This file is part of Peek.

This software is licensed under the GNU General Public License
(version 3 or later). See the LICENSE file in this distribution.
*/

namespace Peek.PostProcessing {

  public class ImagemagickPostProcessor : Object, PostProcessor {
    public int framerate { get; set; default = 15; }

    private Pid? pid = null;

    private int memory_limit = -1;

    public ImagemagickPostProcessor (int framerate) {
      this.framerate = framerate;
      int system_memory = Utils.get_system_memory ();
      if (system_memory > 0) {
        memory_limit = (int)(system_memory * 0.8);
      }
    }

    public async File? process_async (File file) {
      try {
        SourceFunc callback = process_async.callback;

        double delay = (100.0 / framerate);
        var output_file = Utils.create_temp_file ("gif");
        var temp_dir = Utils.get_temp_dir ();

        string? magick_debug = Environment.get_variable ("PEEK_MAGICK_DEBUG");
        if (Utils.string_is_empty (magick_debug)) {
          magick_debug = "None";
        }

        debug ("Running ImageMagick convert\n    saving to: %s\n    temporary path: %s\n    memory limit: %d kiB",
          output_file, temp_dir, memory_limit);

        string[] argv = {
          "convert",
          "-debug", magick_debug,
          "-set", "delay", delay.to_string (),
          "-limit", "disk", "unlimited",
          "-limit", "memory", "%dkiB".printf(memory_limit),
          "-layers", "Optimize",
          "-define", "registry:temporary-path=" + temp_dir,
          file.get_path (),
          output_file
        };

        Process.spawn_async (null, argv, null,
          SpawnFlags.SEARCH_PATH | SpawnFlags.DO_NOT_REAP_CHILD, null, out pid);

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

    public void cancel () {
      if (pid != null) {
        Posix.kill (pid, Posix.SIGINT);
      }
    }
  }

}
