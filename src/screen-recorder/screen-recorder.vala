/*
Peek Copyright (c) 2016 by Philipp Wolfer <ph.wolfer@gmail.com>

This file is part of Peek.

This software is licensed under the GNU General Public License
(version 3 or later). See the LICENSE file in this distribution.
*/

public interface ScreenRecorder : Object {
  public abstract bool is_recording { get; protected set; }

  public signal void recording_started ();

  public signal void recording_finished (File file);

  public signal void recording_aborted (int status);

  public abstract bool record (RecordingArea area);

  public abstract File? stop ();

  public abstract void cancel ();
}
