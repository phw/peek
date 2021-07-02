/*
Peek Copyright (c) 2017-2018 by Philipp Wolfer <ph.wolfer@gmail.com>

This file is part of Peek.

This software is licensed under the GNU General Public License
(version 3 or later). See the LICENSE file in this distribution.
*/

namespace Peek.Recording {
  public class RecordingConfig : Object {
    public OutputFormat output_format { get; set; default = OutputFormat.GIF; }
    public int framerate { get; set; default = DEFAULT_FRAMERATE; }
    public int downsample { get; set; default = DEFAULT_DOWNSAMPLE; }
    public bool capture_mouse { get; set; default = true; }
    public bool capture_sound { get; set; default = true; }
    public bool gifski_enabled { get; set; default = false; }
    public int gifski_quality { get; set; default = DEFAULT_GIFSKI_QUALITY; }
  }
}
