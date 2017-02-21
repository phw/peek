/*
Peek Copyright (c) 2015-2017 by Philipp Wolfer <ph.wolfer@gmail.com>

This file is part of Peek.

This software is licensed under the GNU General Public License
(version 3 or later). See the LICENSE file in this distribution.
*/

namespace Peek.Recording {
  public class AvconvScreenRecorder : CommandLineScreenRecorder {
    ~AvconvScreenRecorder () {
      cancel ();
    }

    public override bool record (RecordingArea area) {
      try {
        // Cancel running recording
        cancel ();

        // FIXME: Implement WebM output
        this.output_format = OUTPUT_FORMAT_GIF;

        temp_file =  Utils.create_temp_file ("avi");
        string display = Environment.get_variable ("DISPLAY");
        if (display == null) {
          display = ":0";
        }

        string[] args = {
          "avconv", "-y",
          "-f", "x11grab",
          "-show_region", "0",
          "-framerate", framerate.to_string (),
          "-video_size", area.width.to_string () + "x" + area.height.to_string (),
          "-i", display + "+" + area.left.to_string () + "," + area.top.to_string (),
          "-codec:v", "libx264",
          "-preset", "ultrafast",
          "-vf", "crop=iw-mod(iw\\,2):ih-mod(ih\\,2), scale=iw/" + downsample.to_string () + ":-1",
          temp_file
        };

        return spawn_record_command (args);
      } catch (FileError e) {
        stderr.printf ("Error: %s\n", e.message);
        return false;
      }
    }

    public static bool is_available () throws PeekError {
      return Utils.check_for_executable ("avconv");
    }

    protected override bool is_exit_status_success (int status) {
      return Process.term_sig (status) == ProcessSignal.INT ||
        Process.exit_status (status) == 0 ||
        Process.exit_status (status) == 255;
    }

    protected override void stop_recording () {
      Posix.kill (pid, Posix.SIGINT);
    }
  }

}
