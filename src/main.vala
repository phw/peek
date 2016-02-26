/*
Peek Copyright (c) 2015 by Philipp Wolfer <ph.wolfer@gmail.com>

This file is part of Peek.

This software is licensed under the GNU General Public License
(version 3 or later). See the LICENSE file in this distribution.
*/

[CCode(cname="GETTEXT_PACKAGE")] extern const string GETTEXT_PACKAGE;

int main (string[] args) {
  // Setup gettext
  GLib.Intl.setlocale(GLib.LocaleCategory.ALL, "");
  GLib.Intl.bindtextdomain (GETTEXT_PACKAGE, null);
  GLib.Intl.bind_textdomain_codeset (GETTEXT_PACKAGE, "UTF-8");
  GLib.Intl.textdomain (GETTEXT_PACKAGE);

  var app = new Peek.Application ();
  return app.run (args);
}
