/*
Peek Copyright (c) 2015 by Philipp Wolfer <ph.wolfer@gmail.com>

This file is part of Peek.

This software is licensed under the GNU General Public License
(version 3 or later). See the LICENSE file in this distribution.
*/

[CCode(cname="GETTEXT_PACKAGE")] extern const string GETTEXT_PACKAGE;
[CCode(cname="LOCALEDIR")] extern const string LOCALEDIR;

int main (string[] args) {
  // If not explicitly set otherwise, set GDK_BACKEND to x11.
  // Native Wayland is not yet supported, that means on Wayland
  // the use of XWayland is mandatory. See also
  // https://github.com/phw/peek#why-no-native-wayland-support
  Environment.set_variable ("GDK_BACKEND", "x11", false);

  // Setup gettext
  Intl.setlocale (LocaleCategory.ALL, "");
  Intl.bindtextdomain (GETTEXT_PACKAGE, LOCALEDIR);
  Intl.bind_textdomain_codeset (GETTEXT_PACKAGE, "UTF-8");
  Intl.textdomain (GETTEXT_PACKAGE);

  var app = new Peek.Application ();
  return app.run (args);
}
