/*
Peek Copyright (c) 2017 by Philipp Wolfer <ph.wolfer@gmail.com>

This file is part of Peek.

This software is licensed under the GNU General Public License
(version 3 or later). See the LICENSE file in this distribution.
*/


namespace Peek.Ui {

#if ! HAS_GTK_SHORTCUT_LABEL

  // Gtk >= 3.22 does have GtkShortcutLabel, which is easier to use and
  // displays the shortcuts more nicely to the user. For older versions this
  // implements a fallback based on a normal GtkLabel with custom code for
  // displaying the shortcut keys.
  // The interface is for our purpose identical to the one of Gtk.ShortcutLabel
  class ShortcutLabel : Gtk.Label {

    private string _accelerator;
    public string accelerator {
      get {
        return _accelerator;
      }
      set {
        _accelerator = value;
        uint accelerator_key;
        Gdk.ModifierType accelerator_mods;
        Gtk.accelerator_parse (accelerator, out accelerator_key, out accelerator_mods);
        var label = Gtk.accelerator_get_label (accelerator_key, accelerator_mods);

        if (label == "") {
          label = disabled_text;
        }

        this.label = label;
      }
    }

    public string disabled_text { get; set; default = ""; }

    public ShortcutLabel (string accelerator) {
      Object ();
      this.accelerator = accelerator;

      halign = Gtk.Align.START;
      xalign = 0;
    }
  }

#endif

}
