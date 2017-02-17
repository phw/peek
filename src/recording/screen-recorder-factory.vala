/*
Peek Copyright (c) 2017 by Philipp Wolfer <ph.wolfer@gmail.com>

This file is part of Peek.

This software is licensed under the GNU General Public License
(version 3 or later). See the LICENSE file in this distribution.
*/

namespace Peek.Recording {

  public class ScreenRecorderFactory {

    public static ScreenRecorder create_default_screen_recorder () throws PeekError {
      string recorder;

      if (check_for_executable ("ffmpeg")) {
        recorder = "ffmpeg";
      } else if (check_for_executable ("avconv")) {
        recorder = "avconv";
      } else {
        throw new PeekError.NO_SUITABLE_SCREEN_RECORDER (
          "No suitable screen recorder found");
      }

      debug ("Using screen recorder %s", recorder);
      return create_screen_recorder (recorder);
    }

    public static ScreenRecorder create_screen_recorder (string name) throws PeekError {
      switch (name) {
        case "ffmpeg":
          return new FfmpegScreenRecorder ();
        case "avconv":
          return new AvconvScreenRecorder ();
        default:
          throw new PeekError.UNKNOWN_SCREEN_RECORDER (
            "Unknown screen recorder " + name);
      }
    }

    private static bool check_for_executable (string executable) {
      string[] args = {
        "which", executable
      };

      int status;
      string output;
      string errorout;

      try {
        Process.spawn_sync (null, args, null,
          SpawnFlags.SEARCH_PATH,
          null, out output, out errorout, out status);
        debug ("Looking for executable %s (%i): %s%s",
          executable, status, output, errorout);
        return Utils.is_exit_status_success (status);
      } catch (SpawnError e) {
        debug ("Error: %s", e.message);
      }

      return false;
    }
  }

}
