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
        subprocess = new Subprocess.newv (argv, SubprocessFlags.STDIN_PIPE);
        input = subprocess.get_stdin_pipe ();
        subprocess.wait_async.begin (null, (obj, res) => {
          int status;
          bool success = false;
          try {
            subprocess.wait_async.end (res);
            status = subprocess.get_exit_status ();
            success = subprocess.get_successful ();
            debug ("recording process exited, term_sig: %d, exit_status: %d, success: %s",
              subprocess.get_term_sig (), subprocess.get_exit_status (),
              subprocess.get_successful ().to_string ());
          } catch (Error e) {
            stderr.printf ("Error: %s\n", e.message);
            status = -1;
            success = false;
          }

          subprocess = null;
          input = null;

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
            recording_aborted (status);
          } else {
            finalize_recording ();
          }
        });


        is_recording = true;
        recording_started ();
        return true;
      } catch (Error e) {
        stderr.printf ("Error: %s\n", e.message);
        return false;
      }
    }

    protected virtual bool is_exit_status_success (int status) {
      return Utils.is_exit_status_success (status);
    }
  }

}
