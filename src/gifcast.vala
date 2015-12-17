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

using Gtk;
using Gdk;
using Cairo;

Widget castView;
bool supportsAlpha = true;

public void on_application_window_screen_changed (Widget widget, Screen oldScreen) {
  var screen = widget.get_screen ();
  var visual = screen.get_rgba_visual ();

  if (visual == null) {
    stderr.printf ("Screen does not support alpha channels!");
    visual = screen.get_system_visual ();
    supportsAlpha = false;
  }
  else {
    supportsAlpha = true;
  }

  widget.set_visual (visual);
}

public bool on_cast_view_draw (Widget widget, Context ctx) {
  if (supportsAlpha) {
    ctx.set_source_rgba (0.0, 0.0, 0.0, 0.0);
  }
  else {
    ctx.set_source_rgb (0.0, 0.0, 0.0);
  }

  // Stance out the transparent inner part
  ctx.set_operator (Operator.CLEAR);
  ctx.paint ();
  ctx.fill ();

  return false;
}

public void on_application_window_delete_event (string[] args) {
  Gtk.main_quit ();
}

public void on_cancel_button_clicked (Button source) {
  Gtk.main_quit ();
}

public void on_record_button_clicked (Button source) {
  var castViewWindow = castView.get_window ();
  int left, top;
  castViewWindow.get_origin (out left, out top);
  var width = castView.get_allocated_width ();
  var height = castView.get_allocated_height ();
  stdout.printf ("Recording area: %i, %i, %i, %i\n", left, top, width, height);
}

int main (string[] args) {
  Gtk.init (ref args);

  try {
    var builder = new Builder ();
    builder.add_from_resource("/de/uploadedlobster/gifcast/ui/gifcast.ui");
    builder.connect_signals (null);

    var window = builder.get_object ("application_window") as Gtk.Window;
    window.set_keep_above (true);

    castView = builder.get_object("cast_view") as Widget;

    window.show_all ();
    Gtk.main ();
  } catch (Error e) {
    stderr.printf ("Could not load UI: %s\n", e.message);
    return 1;
  }

  return 0;
}
