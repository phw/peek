/*
Peek Copyright (c) 2017 by Philipp Wolfer <ph.wolfer@gmail.com>

This file is part of Peek.

This software is licensed under the GNU General Public License
(version 3 or later). See the LICENSE file in this distribution.
*/

namespace Peek.PostProcessing {

  /**
  * Common base class for post processors calling external CLI tools.
  */
  public abstract class CliPostProcessor : Object, PostProcessor {
    private Pid? pid = null;

    public abstract async Array<File>? process_async (Array<File> files);

    public void cancel () {
      if (pid != null) {
        Posix.kill (pid, Posix.SIGINT);
      }
    }

    protected async int spawn_command_async (string[] argv) {
      try {
        SourceFunc callback = spawn_command_async.callback;

        spawn_async (argv);
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

    private void spawn_async (string[] argv) throws SpawnError {
      Process.spawn_async (null, argv, null,
        SpawnFlags.SEARCH_PATH | SpawnFlags.DO_NOT_REAP_CHILD, null, out pid);
    }
  }
}
