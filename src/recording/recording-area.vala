/*
Peek Copyright (c) 2016-2017 by Philipp Wolfer <ph.wolfer@gmail.com>

This file is part of Peek.

This software is licensed under the GNU General Public License
(version 3 or later). See the LICENSE file in this distribution.
*/

namespace Peek.Recording {
  public struct RecordingArea {
    public int left;
    public int top;
    public int width;
    public int height;
    public Gtk.Widget? widget;

    public static RecordingArea create_for_widget (Gtk.Widget recording_view) {
      var recording_view_window = recording_view.get_window ();
      var scale_factor = recording_view_window.get_scale_factor ();

      var area = RecordingArea() {
        widget = recording_view,
        width = recording_view.get_allocated_width () * scale_factor,
        height = recording_view.get_allocated_height () * scale_factor
      };

      // Get absolute window coordinates
      recording_view_window.get_origin (out area.left, out area.top);

      // Add relative widget coordinates
      int relative_left, relative_top;
      recording_view.translate_coordinates (recording_view.get_toplevel(), 0, 0,
        out relative_left, out relative_top);

      area.left = (area.left + relative_left) * scale_factor;
      area.top = (area.top + relative_top) * scale_factor;

      return area;
    }

    public bool equals (RecordingArea? other) {
      if (other == null) {
        return false;
      }

      return this.left == other.left
        && this.top == other.top
        && this.width == other.width
        && this.height == other.height
        && this.widget == other.widget;
    }
  }

}
