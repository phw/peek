/*
Peek Copyright (c) 2015-2018 by Philipp Wolfer <ph.wolfer@gmail.com>

This file is part of Peek.

This software is licensed under the GNU General Public License
(version 3 or later). See the LICENSE file in this distribution.
*/

namespace Peek.Recording {

  public class SwayScreenRecorder : CliScreenRecorder {
    ~SwayScreenRecorder () {
      cancel ();
    }

    protected override void start_recording (RecordingArea area) throws RecordingError {
      try {
        string extension;
        extension = "webm";
        var ffmpeg_args = new Array<string> ();
        // ffmpeg_args.append_val ("-filter:v");
        // var filter = "crop=%i,%i,%i,%i".printf (
        //   area.width, area.height, area.left, area.top
        // );
        // filter += "scale=iw/%i:-1".printf (config.downsample);
        // ffmpeg_args.append_val (filter);
        ffmpeg_args.append_val ("-y");
        // Ffmpeg.add_output_parameters (ffmpeg_args, config, out extension);
        var ffmpeg_opts = string.joinv (" ", ffmpeg_args.data);

        var env = new HashTable<string, string> (str_hash, str_equal);
        env.insert ("SWAYGRAB_FFMPEG_OPTS", ffmpeg_opts);
        // env.insert ("SWAYSOCK", Environment.get_variable ("SWAYSOCK"));
        // env.insert ("I3SOCK", Environment.get_variable ("I3SOCK"));

        var args = new Array<string> ();
        args.append_val ("swaygrab");
        args.append_val ("--capture");
        args.append_val ("--rate");
        args.append_val (config.framerate.to_string ());
        args.append_val ("--socket");
        args.append_val (Environment.get_variable ("SWAYSOCK"));

        temp_file = Utils.create_temp_file (extension);
        args.append_val (temp_file);

        spawn_record_command (args.data, env);

        // string display = Environment.get_variable ("DISPLAY");
        // if (display == null) {
        //   display = ":0";
        // }
        //
        // var args = new Array<string> ();
        // args.append_val ("ffmpeg");
        // // args.append_val ("-loglevel");
        // // args.append_val ("debug");
        // args.append_val ("-f");
        // args.append_val ("x11grab");
        // args.append_val ("-show_region");
        // args.append_val ("0");
        // args.append_val ("-framerate");
        // args.append_val (int.max (config.framerate, 6).to_string ());
        // args.append_val ("-video_size");
        // args.append_val (area.width.to_string () + "x" + area.height.to_string ());
        //
        // if (!config.capture_mouse) {
        //   args.append_val ("-draw_mouse");
        //   args.append_val ("0");
        // }
        //
        // args.append_val ("-i");
        // args.append_val (display + "+" + area.left.to_string () + "," + area.top.to_string ());
        //
        // args.append_val ("-filter:v");
        // var filter = "scale=iw/" + config.downsample.to_string () + ":-1";
        // if (config.output_format == OutputFormat.MP4) {
        //   filter += ", crop=iw-mod(iw\\,2):ih-mod(ih\\,2)";
        // }
        //
        // args.append_val (filter);
        //
        // string extension;
        // Ffmpeg.add_output_parameters (args, config, out extension);
        //
        // temp_file = Utils.create_temp_file (extension);
        // args.append_val ("-y");
        // args.append_val (temp_file);
        //
        // spawn_record_command (args.data);
      } catch (FileError e) {
        throw new RecordingError.INITIALIZING_RECORDING_FAILED (e.message);
      }
    }

    public static bool is_available () throws PeekError {
      return DesktopIntegration.is_sway ()
        && Utils.check_for_executable ("swaygrab");
    }

    protected override void stop_recording () {
      if (subprocess != null) {
        subprocess.send_signal (ProcessSignal.TERM);
      }
    }

    protected override bool is_exit_status_success (int status) {
      // FIXME: Check status
      stdout.printf ("swaygrab exited with %i\n", status);
      return true;
    }
  }

}
