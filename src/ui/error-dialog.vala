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

    public static Dialog present_single_instance (
      Gtk.Window main_window, string summary, Error? error = null) {
      if (instance == null) {
        instance = new ErrorDialog ();
        instance.delete_event.connect ((event) => {
          instance = null;
          main_window.set_keep_above (true);
          return false;
        });
      }

      instance.summary = summary;
      instance.show_error (error);
      instance.transient_for = main_window;
      main_window.set_keep_above (false);
      instance.present ();
      return instance;
    }

    [GtkChild]
    private unowned Label error_summary;

    [GtkChild]
    private unowned TextBuffer error_details;

    [GtkChild]
    private unowned Expander error_details_container;

    private Error? error = null;

    public string summary {
      get {
        return error_summary.label;
      }
      set {
        error_summary.label = value;
      }
    }

    public void show_error (Error? error) {
      this.error = error;

      if (error != null) {
        error_details.text = error.message;
        error_details_container.show ();
      } else {
        error_details.text = "";
        error_details_container.hide ();
      }
    }

    [GtkCallback]
    private void on_close_button_clicked (Button source) {
      close ();
    }
  }

}
