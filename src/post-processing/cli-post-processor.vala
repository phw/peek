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
    // private Pid? pid = null;
    private Subprocess subprocess;

    public abstract async Array<File>? process_async (Array<File> files);

    public void cancel () {
      if (subprocess != null) {
        subprocess.force_exit ();
      }
    }

    protected async int spawn_command_async (string[] argv) {
      try {
        subprocess = new Subprocess.newv (argv, SubprocessFlags.NONE);
        yield subprocess.wait_async ();
        int status = subprocess.get_status ();
        subprocess = null;
        return status;
      } catch (Error e) {
        stderr.printf ("Error: %s\n", e.message);
        return -1;
      }
    }
  }
}
