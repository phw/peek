/*
Peek Copyright (c) 2017 by Philipp Wolfer <ph.wolfer@gmail.com>

This file is part of Peek.

This software is licensed under the GNU General Public License
(version 3 or later). See the LICENSE file in this distribution.
*/

using Peek.PostProcessing;

namespace Peek.Recording {

  public abstract class BaseScreenRecorder : Object, ScreenRecorder {
    protected string temp_file;

    public bool is_recording { get; protected set; default = false; }

    public string output_format { get; set; default = OUTPUT_FORMAT_GIF; }

    public int framerate { get; set; default = DEFAULT_FRAMERATE; }

    public int downsample { get; set; default = DEFAULT_DOWNSAMPLE; }

    public bool capture_mouse { get; set; default = true; }

    public abstract bool record (RecordingArea area);

    private PostProcessor? active_post_processor = null;

    private bool _is_cancelling;
    protected bool is_cancelling {
      get {
        return _is_cancelling && !is_recording;
      }
    }

    public void stop () {
      debug ("Recording stopped");
      _is_cancelling = false;
      is_recording = false;
      stop_recording ();
    }

    protected void finalize_recording () {
      debug ("Started post processing");
      run_post_processors_async.begin ((obj, res) => {
        var file = run_post_processors_async.end (res);
        FileUtils.chmod (file.get_path (), 0644);
        debug ("Finished post processing");
        recording_finished (file);
      });
      recording_postprocess_started ();
    }

    public void cancel () {
      if (is_recording) {
        _is_cancelling = true;
        is_recording = false;
        stop_recording ();
        remove_temp_file ();
        recording_aborted (0);
      } else if (active_post_processor != null) {
        active_post_processor.cancel ();
        active_post_processor = null;
        recording_aborted (0);
      }
    }

    protected abstract void stop_recording ();

    private async File? run_post_processors_async () {
      var file = File.new_for_path (temp_file);

      if (output_format == OUTPUT_FORMAT_GIF) {
        PostProcessor post_processor;
        if (Environment.get_variable ("PEEK_POSTPROCESSOR") == "ffmpeg") {
          post_processor = new FfmpegGifPostProcessor (framerate);
        } else {
          post_processor = new ImagemagickPostProcessor (framerate);
        }

        active_post_processor = post_processor;
        file = yield post_processor.process_async (file);
        active_post_processor = null;
        remove_temp_file ();
      }

      temp_file = null;

      return file;
    }

    private void remove_temp_file () {
      if (temp_file != null) {
        FileUtils.remove (temp_file);
        temp_file = null;
      }
    }
  }

}
