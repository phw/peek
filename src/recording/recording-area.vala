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

      var area = RecordingArea() {
        widget = recording_view,
        width = recording_view.get_allocated_width (),
        height = recording_view.get_allocated_height ()
      };

      // Get absolute window coordinates
      recording_view_window.get_origin (out area.left, out area.top);

      // Add relative widget coordinates
      int relative_left, relative_top;
      recording_view.translate_coordinates (recording_view.get_toplevel(), 0, 0,
        out relative_left, out relative_top);

      area.left = (area.left + relative_left);
      area.top = (area.top + relative_top);

      debug ("Absolute recording area x: %d, y: %d, w: %d, h: %d",
        area.left, area.top, area.width, area.height);

      // Clip recording area to visible screen area
      var screen = recording_view.get_screen ();
      var screen_width = screen.get_width ();
      var screen_height = screen.get_height ();
      debug ("Screen w: %d, h: %d", screen_width, screen_height);

      area.left = int.min (int.max (0, area.left), screen_width);
      area.top = int.min (int.max (0, area.top), screen_height);

      if (area.left + area.width > screen_width) {
        area.width = screen_width - area.left;
      }

      if (area.top + area.height > screen_height) {
        area.height = screen_height - area.top;
      }

      debug ("Clipped recording area x: %d, y: %d, w: %d, h: %d",
        area.left, area.top, area.width, area.height);

      // Scale recording area on HiDPI screens
      var scale_factor = recording_view_window.get_scale_factor ();

      area.left *= scale_factor;
      area.top *= scale_factor;
      area.width *= scale_factor;
      area.height *= scale_factor;

      debug ("Scaled recording area x: %d, y: %d, w: %d, h: %d",
        area.left, area.top, area.width, area.height);

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
