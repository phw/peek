/*
Peek Copyright (c) 2017 by Philipp Wolfer <ph.wolfer@gmail.com>

This file is part of Peek.

This software is licensed under the GNU General Public License
(version 3 or later). See the LICENSE file in this distribution.
*/

using Gtk;

namespace Peek.Ui { 
  [GtkTemplate (ui = "/com/uploadedlobster/peek/set-window-size-dialog.ui")]
  class SetWindowSizeDialog : Gtk.Dialog {

    private static SetWindowSizeDialog? instance;

    public static Dialog present_single_instance (Gtk.Window main_window) {
      if (instance == null) {
        instance = new SetWindowSizeDialog (main_window);
        instance.delete_event.connect ((event) => {
          instance = null;
          return false;
        });
      }

      int new_width, new_height;
      main_window.get_size (out new_width, out new_height);
      instance.width = new_width - 2;
      instance.height = new_height - 2;

      instance.transient_for = main_window;
      instance.present ();
      return instance;
    }

    [GtkChild]
    private Adjustment width_adjustment;

    [GtkChild]
    private Adjustment height_adjustment;

    private Window window;

    private SetWindowSizeDialog (Window window) {
      this.window = window;
    }

    private int width {
      get {
        return (int) width_adjustment.value;
      }

      set {
        width_adjustment.value = value;
      }
    }

    private int height {
      get {
        return (int) height_adjustment.value;
      }

      set {
        height_adjustment.value = value;
      }
    }

    [GtkCallback]
    private void on_set_size_button_clicked (Button source) {
      window.resize (width + 2, height + 2);
    }
  }
}