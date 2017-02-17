/*
Peek Copyright (c) 2015-2017 by Philipp Wolfer <ph.wolfer@gmail.com>

This file is part of Peek.

This software is licensed under the GNU General Public License
(version 3 or later). See the LICENSE file in this distribution.
*/

using Peek.PostProcessing;

namespace Peek.Recording {

  public abstract class CommandLineScreenRecorder : Object, ScreenRecorder {
    protected Pid pid;
    protected IOChannel input;
    protected string temp_file;

    public bool is_recording { get; protected set; default = false; }

    public int framerate { get; set; default = 15; }

    public int downsample { get; set; default = 1; }

    public abstract bool record (RecordingArea area);

    protected bool spawn_record_command (string[] args) {
      try {
        int standard_input;
        Process.spawn_async_with_pipes (null, args, null,
          SpawnFlags.SEARCH_PATH | SpawnFlags.DO_NOT_REAP_CHILD,
          null, out pid, out standard_input);

        input = new IOChannel.unix_new (standard_input);

        ChildWatch.add (pid, (pid, status) => {
          // Triggered when the child indicated by pid exits
          Process.close_pid (pid);

          if (!is_exit_status_success (status)) {
            recording_aborted (status);
          }
        });

        is_recording = true;
        recording_started ();
        return true;
      } catch (SpawnError e) {
        stderr.printf ("Error: %s\n", e.message);
        return false;
      }
    }

    public void stop () {
      stdout.printf ("Recording stopped\n");
      stop_command ();
      is_recording = false;

      // postProcessor.process_async.begin ((obj, res) => {
      run_post_processors_async.begin ((obj, res) => {
        var file = run_post_processors_async.end (res);
        remove_temp_file ();
        recording_finished (file);
      });
    }

    public void cancel () {
      if (is_recording) {
        stop_command ();
        remove_temp_file ();
        is_recording = false;
        recording_aborted (0);
      }
    }

    private async File? run_post_processors_async () {
      var file = File.new_for_path (temp_file);
      var postProcessor = new ImagemagickPostProcessor (framerate);
      file = yield postProcessor.process_async (file);
      return file;
    }

    protected virtual bool is_exit_status_success (int status) {
      try {
        if (Process.check_exit_status (status)) {
          return true;
        }
      }
      catch (Error e) {
        stderr.printf ("Error: %s\n", e.message);
      }

      return false;
    }

    protected abstract void stop_command ();

    private void remove_temp_file () {
      if (temp_file != null) {
        FileUtils.remove (temp_file);
        temp_file = null;
      }
    }
  }

}
