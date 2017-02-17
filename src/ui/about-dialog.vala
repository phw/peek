/*
Peek Copyright (c) 2015-2017 by Philipp Wolfer <ph.wolfer@gmail.com>

This file is part of Peek.

This software is licensed under the GNU General Public License
(version 3 or later). See the LICENSE file in this distribution.
*/

namespace Peek.Ui {

  [GtkTemplate (ui = "/com/uploadedlobster/peek/about.ui")]
  class AboutDialog : Gtk.AboutDialog {

    private static Gtk.Dialog? instance;

    public static Gtk.Dialog present_single_instance (Gtk.Window main_window) {
      if (instance == null) {
        var aboutDialog = new AboutDialog ();
        instance = aboutDialog;
        instance.delete_event.connect ((event) => {
          instance = null;
          main_window.set_keep_above (true);
          return false;
        });
      }

      instance.transient_for = main_window;
      main_window.set_keep_above (false);
      instance.present ();
      return instance;
    }

    [GtkCallback]
    private void on_response (int response_id) {
      if (response_id == Gtk.ResponseType.CANCEL
        || response_id == Gtk.ResponseType.DELETE_EVENT) {
        this.hide_on_delete ();
      }
    }
  }

}
