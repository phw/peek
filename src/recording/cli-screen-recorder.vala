/*
Peek Copyright (c) 2015-2017 by Philipp Wolfer <ph.wolfer@gmail.com>

This file is part of Peek.

This software is licensed under the GNU General Public License
(version 3 or later). See the LICENSE file in this distribution.
*/

using Peek.PostProcessing;

namespace Peek.Recording {

  public abstract class CliScreenRecorder : BaseScreenRecorder {
    protected Subprocess subprocess;
    protected OutputStream input;

    protected bool spawn_record_command (string[] argv) {
      try {
        string[] my_args = argv[0:argv.length];
        subprocess = new Subprocess.newv (argv, SubprocessFlags.STDIN_PIPE);
        input = subprocess.get_stdin_pipe ();
        subprocess.wait_async.begin (null, (obj, res) => {
          bool success = false;
          int status = 0;
          int term_sig = 0;
          try {
            subprocess.wait_async.end (res);
            success = subprocess.get_successful ();
            status = subprocess.get_exit_status ();
            if (subprocess.get_if_signaled ()) {
              term_sig = subprocess.get_term_sig ();
            }

            debug ("recording process exited, term_sig: %d, exit_status: %d, success: %s",
              term_sig, status, success.to_string ());
          } catch (Error e) {
            stderr.printf ("Error: %s\n", e.message);
            status = -1;
            success = false;
          }

          if (temp_file != null) {
            var file = File.new_for_path (temp_file);
            try {
              var file_info = file.query_info ("*", FileQueryInfoFlags.NONE);
              debug ("Temporary file %s, %" + int64.FORMAT + " bytes",
              temp_file, file_info.get_size ());
            } catch (Error e) {
              stderr.printf ("Error: %s\n", e.message);
            }
          }

          // If the recorder was cancelled no further action is required
          if (is_cancelling) {
            return;
          }

          if (!success) {
            string message = Utils.get_command_failed_message (my_args, subprocess);
            var reason = new RecordingError.RECORDING_ABORTED (message);
            recording_aborted (reason);
          } else {
            finalize_recording ();
          }

          subprocess = null;
          input = null;
        });


        is_recording = true;
        recording_started ();
        return true;
      } catch (Error e) {
        stderr.printf ("Error: %s\n", e.message);
        return false;
      }
    }

    protected override void stop_recording () {
      if (subprocess != null) {
        subprocess.force_exit ();
      }
    }

    protected virtual bool is_exit_status_success (int status) {
      return Utils.is_exit_status_success (status);
    }
  }

}
