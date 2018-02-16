/*
Peek Copyright (c) 2015-2018 by Philipp Wolfer <ph.wolfer@gmail.com>

This file is part of Peek.

This software is licensed under the GNU General Public License
(version 3 or later). See the LICENSE file in this distribution.
*/

namespace Peek.Recording {

  public class FfmpegScreenRecorder : CliScreenRecorder {
    ~FfmpegScreenRecorder () {
      cancel ();
    }

    public override void start_recording (RecordingArea area) throws RecordingError {
      try {
        string display = Environment.get_variable ("DISPLAY");
        if (display == null) {
          display = ":0";
        }

        var args = new Array<string> ();
        args.append_val ("ffmpeg");
        // args.append_val ("-loglevel");
        // args.append_val ("debug");
        args.append_val ("-f");
        args.append_val ("x11grab");
        args.append_val ("-show_region");
        args.append_val ("0");
        args.append_val ("-framerate");
        args.append_val (int.max (config.framerate, 6).to_string ());
        args.append_val ("-video_size");
        args.append_val (area.width.to_string () + "x" + area.height.to_string ());

        if (!config.capture_mouse) {
          args.append_val ("-draw_mouse");
          args.append_val ("0");
        }

        args.append_val ("-i");
        args.append_val (display + "+" + area.left.to_string () + "," + area.top.to_string ());

        args.append_val ("-filter:v");
        var filter = "scale=iw/" + config.downsample.to_string () + ":-1";
        if (config.output_format == OutputFormat.MP4) {
          filter += ", crop=iw-mod(iw\\,2):ih-mod(ih\\,2)";
        }

        args.append_val (filter);

        string extension;
        Ffmpeg.add_output_parameters (args, config, out extension);

        temp_file = Utils.create_temp_file (extension);
        args.append_val ("-y");
        args.append_val (temp_file);

        spawn_record_command (args.data);
      } catch (FileError e) {
        throw new RecordingError.INITIALIZING_RECORDING_FAILED (e.message);
      }
    }

    public static bool is_available () throws PeekError {
      return Utils.check_for_executable ("ffmpeg");
    }

    protected override void stop_recording () {
      if (subprocess != null && input != null) {
        try {
          uint8[] command = { 'q' };
          input.write (command);
          input.flush ();
        } catch (Error e) {
          stderr.printf ("Error: %s\n", e.message);
          recording_aborted (new RecordingError.RECORDING_ABORTED (e.message));
        }
      }
    }
  }

}
