/*
GifCast Copyright (c) 2015 by Philipp Wolfer <ph.wolfer@gmail.com>

This file is part of GifCast.

GifCast is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

GifCast is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with GifCast.  If not, see <http://www.gnu.org/licenses/>.
*/

using GLib;

public class ScreenRecorder {
  private IOChannel input;
  private string temp_file;

  public bool record (int left, int top, int width, int height) {
    try {
      temp_file = create_temp_file ("avi");

      string[] args = {
        "ffmpeg", "-y",
        "-f", "x11grab",
        "-show_region", "0",
        "-framerate", "15",
        "-video_size", width.to_string () + "x" + height.to_string (),
        "-i", ":0+" + left.to_string () + "," + top.to_string (),
        "-codec:v", "huffyuv",
        "-vf", "crop=iw-mod(iw\\,2):ih-mod(ih\\,2)",
        temp_file
      };

      stdout.printf("crop=\"iw-mod(iw,2):ih-mod(ih,2)\"\n");

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
    try {
      char[] command = { 'q' };
      size_t bytes_written;
      input.write_chars (command, out bytes_written);
      input.flush ();
      return convert_to_gif();
    } catch (ConvertError e) {
      stderr.printf ("Error: %s\n", e.message);
      return "";
    } catch (IOChannelError e) {
      stderr.printf ("Error: %s\n", e.message);
      return "";
    }
  }

  private static string create_temp_file (string extension) throws FileError {
    string file_name;
    var fd = FileUtils.open_tmp ("gifcastXXXXXX." + extension, out file_name);
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
      FileUtils.remove (temp_file);
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
