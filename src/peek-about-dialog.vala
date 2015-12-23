/*
Peek Copyright (c) 2015 by Philipp Wolfer <ph.wolfer@gmail.com>

This file is part of Peek.

This software is licensed under the GNU General Public License
(version 3 or later). See the LICENSE file in this distribution.
*/

using Gtk;

[GtkTemplate (ui = "/de/uploadedlobster/peek/about.ui")]
class PeekAboutDialog : AboutDialog {

  private static Gtk.Dialog? instance;

  public static Gtk.Dialog present_single_instance (Gtk.Window main_window) {
    if (instance == null) {
      instance = new PeekAboutDialog ();
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
}
