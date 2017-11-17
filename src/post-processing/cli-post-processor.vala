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

    public abstract async Array<File>? process_async (Array<File> files) throws RecordingError;

    public void cancel () {
      if (subprocess != null) {
        subprocess.force_exit ();
      }
    }

    protected async int spawn_command_async (string[] argv) throws RecordingError {
      try {
        subprocess = new Subprocess.newv (argv, SubprocessFlags.STDOUT_PIPE | SubprocessFlags.STDERR_MERGE);
        yield subprocess.wait_async ();
      } catch (Error e) {
        stderr.printf ("Error: %s\n", e.message);
        string message = Utils.get_command_failed_message (argv, subprocess);
        throw new RecordingError.POSTPROCESSING_ABORTED (message);
      }


      int status = subprocess.get_status ();
      if (!Utils.is_exit_status_success (status)) {
        string message = Utils.get_command_failed_message (argv, subprocess);
        subprocess = null;
        throw new RecordingError.POSTPROCESSING_ABORTED (message);
      }

      subprocess = null;
      return status;
    }
  }
}
