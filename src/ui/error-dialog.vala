/*
Peek Copyright (c) 2017 by Philipp Wolfer <ph.wolfer@gmail.com>

This file is part of Peek.

This software is licensed under the GNU General Public License
(version 3 or later). See the LICENSE file in this distribution.
*/

using Gtk;

namespace Peek.Ui {

  [GtkTemplate (ui = "/com/uploadedlobster/peek/error-dialog.ui")]
  class ErrorDialog : Gtk.Dialog {

    private static ErrorDialog? instance;

    public static Dialog present_single_instance (Gtk.Window main_window, Error error) {
      if (instance == null) {
        instance = new ErrorDialog ();
        instance.delete_event.connect ((event) => {
          instance = null;
          main_window.set_keep_above (true);
          return false;
        });
      }

      instance.show_error (error);
      instance.transient_for = main_window;
      main_window.set_keep_above (false);
      instance.present ();
      return instance;
    }

    [GtkChild]
    private TextBuffer error_details;

    public void show_error (Error error) {
      error_details.text = error.message;
    }

    [GtkCallback]
    private void on_close_button_clicked (Button source) {
      close ();
    }

    [GtkCallback]
    private void on_report_issue_button_clicked (Button source) {
      try {
        show_uri_on_window (
          this, ISSUE_TRACKER_URL, Gdk.CURRENT_TIME);
      } catch (Error e) {
        stdout.printf ("Error opening issue tracker URL: %s", e.message);
      }
    }
  }

}
