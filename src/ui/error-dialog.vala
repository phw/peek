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
    private Label error_summary;

    [GtkChild]
    private TextBuffer error_details;

    [GtkChild]
    private Expander error_details_container;

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

    [GtkCallback]
    private void on_report_issue_button_clicked (Button source) {
      var url = build_issue_tracker_url ();

      try {
#if HAS_GTK_SHOW_URI_ON_WINDOW
        show_uri_on_window (this, url, Gdk.CURRENT_TIME);
#else
        show_uri (this.get_screen (), url, Gdk.CURRENT_TIME);
#endif
      } catch (Error e) {
        stdout.printf ("Error opening issue tracker URL: %s", e.message);
      }
    }

    private string build_issue_tracker_url () {
      var url = new StringBuilder ();
      url.append (ISSUE_TRACKER_URL);

      string body = get_issue_body ();
      url.append_printf ("?body=%s",  Uri.escape_string (body));

      return url.str;
    }

    private string get_issue_body () {
      var body = new StringBuilder ();
      body.append_printf ("Peek: %s\n", Config.VERSION);
      body.append_printf ("GTK: %i.%i.%i\n", Gtk.MAJOR_VERSION, Gtk.MINOR_VERSION, Gtk.MICRO_VERSION);
      body.append_printf ("GLib: %u.%u.%u\n", GLib.Version.MAJOR, GLib.Version.MINOR, GLib.Version.MICRO);

      if (error != null) {
        body.append_printf ("\nDetails:\n```\n%s\n```", error_details.text);
      }

      return body.str;
    }
  }

}
