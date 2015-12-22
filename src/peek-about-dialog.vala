/*
Peek Copyright (c) 2015 by Philipp Wolfer <ph.wolfer@gmail.com>

This file is part of Peek.

This software is licensed under the GNU General Public License
(version 3 or later). See the LICENSE file in this distribution.
*/

using Gtk;

[GtkTemplate (ui = "/de/uploadedlobster/peek/about.ui")]
class PeekAboutDialog : AboutDialog {

  public PeekAboutDialog (Gtk.Window main_window) {
    Object ();
    this.transient_for = main_window;
    main_window.set_keep_above (false);
  }

  public override bool delete_event (Gdk.EventAny event) {
    this.transient_for.set_keep_above (true);
    return false;
  }
}
