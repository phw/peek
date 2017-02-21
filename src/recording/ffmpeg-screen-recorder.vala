/*
Peek Copyright (c) 2015-2017 by Philipp Wolfer <ph.wolfer@gmail.com>

This file is part of Peek.

This software is licensed under the GNU General Public License
(version 3 or later). See the LICENSE file in this distribution.
*/

namespace Peek.Recording {

  public class FfmpegScreenRecorder : CommandLineScreenRecorder {
    ~FfmpegScreenRecorder () {
      cancel ();
    }

    public override bool record (RecordingArea area) {
      try {
        // Cancel running recording
        cancel ();

        temp_file = Utils.create_temp_file ("avi");
        string display = Environment.get_variable ("DISPLAY");
        if (display == null) {
          display = ":0";
        }

        string[] args = {
          "ffmpeg", "-y",
          // "-loglevel", "debug",
          "-f", "x11grab",
          "-show_region", "0",
          "-framerate", framerate.to_string (),
          "-video_size", area.width.to_string () + "x" + area.height.to_string (),
          // "-use_shm", "0",
          // "-draw_mouse", "0",
          "-i", display + "+" + area.left.to_string () + "," + area.top.to_string (),
          "-codec:v", "libx264rgb",
          "-preset:v", "ultrafast",
          "-filter:v", "crop=iw-mod(iw\\,2):ih-mod(ih\\,2), scale=iw/" + downsample.to_string () + ":-1",
          temp_file
        };

        return spawn_record_command (args);
      } catch (FileError e) {
        stderr.printf ("Error: %s\n", e.message);
        return false;
      }
    }

    public static bool is_available () throws PeekError {
      return Utils.check_for_executable ("ffmpeg");
    }

    protected override void stop_command () {
      try {
        char[] command = { 'q' };
        size_t bytes_written;
        input.write_chars (command, out bytes_written);
        input.flush ();
      } catch (ConvertError e) {
        stderr.printf ("Error: %s\n", e.message);
      } catch (IOChannelError e) {
        stderr.printf ("Error: %s\n", e.message);
      }
    }
  }

}
