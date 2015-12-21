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
using Cairo;

Window window;
Widget recordingView;
Button recordButton;
Button stopButton;
bool supportsAlpha = true;
ScreenRecorder recorder;

public void on_application_window_screen_changed (Widget widget, Gdk.Screen oldScreen) {
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

public bool on_recording_view_draw (Widget widget, Context ctx) {
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

  // Set an input shape so that the recording view is not clickable
  var windowRegion = create_region_from_widget (widget.get_toplevel());
  var recordingViewRegion = create_region_from_widget (widget);
  windowRegion.subtract (recordingViewRegion);
  window.input_shape_combine_region (windowRegion);

  return false;
}

public void on_application_window_delete_event (string[] args) {
  Gtk.main_quit ();
}

public void on_cancel_button_clicked (Button source) {
  Gtk.main_quit ();
}

public void on_record_button_clicked (Button source) {
  recordButton.hide ();
  stopButton.show ();
  freeze_window_size ();

  var recordingViewWindow = recordingView.get_window ();
  int left, top;
  recordingViewWindow.get_origin (out left, out top);
  var width = recordingView.get_allocated_width ();
  var height = recordingView.get_allocated_height ();
  stdout.printf ("Recording area: %i, %i, %i, %i\n", left, top, width, height);
  recorder.record(left, top, width, height);
}

public void on_stop_button_clicked (Button source) {
  recorder.stop();
  stopButton.hide();
  recordButton.show();
  window.resizable = true;
  stdout.printf ("Recording stopped\n");
}

private void freeze_window_size () {
  var width = window.get_allocated_width ();
  var height = window.get_allocated_height ();
  window.set_size_request (width, height);
  window.resizable = false;
}

private Region create_region_from_widget(Widget widget) {
  var rectangle = Cairo.RectangleInt () {
    width = widget.get_allocated_width (),
    height = widget.get_allocated_height ()
  };

  widget.translate_coordinates (widget.get_toplevel(), 0, 0, out rectangle.x, out rectangle.y);
  var region = new Region.rectangle (rectangle);

  return region;
}

int main (string[] args) {
  Gtk.init (ref args);

  try {
    var builder = new Builder ();
    builder.add_from_resource ("/de/uploadedlobster/gifcast/ui/gifcast.ui");
    builder.connect_signals (null);

    window = builder.get_object ("application_window") as Gtk.Window;
    window.set_keep_above (true);

    recordingView = builder.get_object ("recording_view") as Widget;
    recordButton = builder.get_object ("record_button") as Button;
    stopButton = builder.get_object ("stop_button") as Button;

    recorder = new ScreenRecorder();

    window.show_all ();
    Gtk.main ();
  } catch (Error e) {
    stderr.printf ("Could not load UI: %s\n", e.message);
    return 1;
  }

  return 0;
}
