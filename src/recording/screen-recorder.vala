/*
Peek Copyright (c) 2016-2017 by Philipp Wolfer <ph.wolfer@gmail.com>

This file is part of Peek.

This software is licensed under the GNU General Public License
(version 3 or later). See the LICENSE file in this distribution.
*/

namespace Peek.Recording {

  public interface ScreenRecorder : Object {
    public abstract bool is_recording { get; protected set; }

    public abstract string output_format { get; set; }

    public abstract int framerate { get; set; }

    public abstract int downsample { get; set; }

    public abstract bool capture_mouse { get; set; }

    public signal void recording_started ();

    public signal void recording_postprocess_started ();

    public signal void recording_finished (File file);

    public signal void recording_aborted (int status);

    public abstract bool record (RecordingArea area);

    public abstract void stop ();

    public abstract void cancel ();
  }

}
