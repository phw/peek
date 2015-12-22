/*
Peek Copyright (c) 2015 by Philipp Wolfer <ph.wolfer@gmail.com>

This file is part of Peek.

This software is licensed under the GNU General Public License
(version 3 or later). See the LICENSE file in this distribution.
*/

using GLib;

public struct RecordingArea {
  public int left;
  public int top;
  public int width;
  public int height;
}

public class ScreenRecorder : Object {
  private IOChannel input;
  private string temp_file;

  public bool is_recording { get; private set; default = false; }

  ~ScreenRecorder () {
    cancel ();
  }

  public bool record (RecordingArea area) {
    try {
      // Cancel running recording
      cancel ();

      temp_file = create_temp_file ("avi");

      string[] args = {
        "ffmpeg", "-y",
        "-f", "x11grab",
        "-show_region", "0",
        "-framerate", "15",
        "-video_size", area.width.to_string () + "x" + area.height.to_string (),
        "-i", ":0+" + area.left.to_string () + "," + area.top.to_string (),
        "-codec:v", "huffyuv",
        "-vf", "crop=iw-mod(iw\\,2):ih-mod(ih\\,2)",
        temp_file
      };

      Pid pid;
      int standard_input;
      Process.spawn_async_with_pipes (null, args, null,
        SpawnFlags.SEARCH_PATH | SpawnFlags.DO_NOT_REAP_CHILD,
        null, out pid, out standard_input);

      input = new IOChannel.unix_new (standard_input);

      ChildWatch.add (pid, (pid, status) => {
        // Triggered when the child indicated by pid exits
        Process.close_pid (pid);
      });

      is_recording = true;
      return true;
    } catch (SpawnError e) {
      stderr.printf ("Error: %s\n", e.message);
      return false;
    } catch (FileError e) {
      stderr.printf ("Error: %s\n", e.message);
      return false;
    }
  }

  public string stop () {
    stdout.printf ("Recording stopped\n");
    stop_command ();
    var file = convert_to_gif();
    FileUtils.remove (temp_file);
    is_recording = false;
    return file;
  }

  public void cancel () {
    if (is_recording) {
      stop_command ();
      FileUtils.remove (temp_file);
      is_recording = false;
    }
  }

  private void stop_command () {
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

  private static string create_temp_file (string extension) throws FileError {
    string file_name;
    var fd = FileUtils.open_tmp ("peekXXXXXX." + extension, out file_name);
    FileUtils.close (fd);
    return file_name;
  }

  private string convert_to_gif () {
    try {
      var output_file = create_temp_file ("gif");
      string[] argv = {
        "convert",
        "-set", "delay", "10",
        "-layers", "Optimize",
        temp_file,
        output_file
      };

      Process.spawn_sync (null, argv, null,
        SpawnFlags.SEARCH_PATH, null);
      return output_file;
    } catch (SpawnError e) {
     stdout.printf ("Error: %s\n", e.message);
     return "";
    } catch (FileError e) {
     stdout.printf ("Error: %s\n", e.message);
     return "";
    }
  }
}
