/*
Peek Copyright (c) 2016 by Philipp Wolfer <ph.wolfer@gmail.com>

This file is part of Peek.

This software is licensed under the GNU General Public License
(version 3 or later). See the LICENSE file in this distribution.
*/

public struct RecordingArea {
  public int left;
  public int top;
  public int width;
  public int height;

  public bool equals (RecordingArea? other) {
    if (other == null) {
      return false;
    }

    return this.left == other.left
      && this.top == other.top
      && this.width == other.width
      && this.height == other.height;
  }
}
