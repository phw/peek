/*
Peek Copyright (c) 2016-2017 by Philipp Wolfer <ph.wolfer@gmail.com>

This file is part of Peek.

This software is licensed under the GNU General Public License
(version 3 or later). See the LICENSE file in this distribution.
*/

namespace Peek.Recording {
  public class RecordingConfig : Object {
    public string output_format { get; set; default = OUTPUT_FORMAT_GIF; }
    public int framerate { get; set; default = DEFAULT_FRAMERATE; }
    public int downsample { get; set; default = DEFAULT_DOWNSAMPLE; }
    public bool capture_mouse { get; set; default = true; }
  }
}
