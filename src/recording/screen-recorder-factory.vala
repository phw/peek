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

#if ! DISABLE_GNOME_SHELL
      if (GnomeShellDbusRecorder.is_available ()) {
        recorder = "gnome-shell";
      } else
#endif
      if (FfmpegScreenRecorder.is_available ()) {
        recorder = "ffmpeg";
      } else {
        throw new PeekError.NO_SUITABLE_SCREEN_RECORDER (
          "No suitable screen recorder found");
      }

      stdout.printf ("Using screen recorder backend %s\n", recorder);
      return create_screen_recorder (recorder);
    }

    public static ScreenRecorder create_screen_recorder (string name) throws PeekError {
      switch (name) {
#if ! DISABLE_GNOME_SHELL
        case "gnome-shell":
          try {
            return new GnomeShellDbusRecorder ();
          } catch (IOError e) {
            throw new PeekError.SCREEN_RECORDER_ERROR (
              e.message);
          }
#endif
        case "ffmpeg":
          return new FfmpegScreenRecorder ();
        default:
          throw new PeekError.UNKNOWN_SCREEN_RECORDER (
            "Unknown screen recorder " + name);
      }
    }
  }

}
