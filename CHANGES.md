# Version 0.8.0 - 2016-1?-??
 * ui: Change button text while rendering (#24)
 * ui: Add a `--version` command line argument
 * recording: Correctly scale recording area on HiDPI screens (#20)
 * i18n: Arabic translation
 * i18n: Catalan translation
 * i18n: French translation
 * i18n: Lithuanian translation
 * i18n: Polish translation
 * i18n: Portuguese (Portugal) translation
 * i18n: Russian translation
 * i18n: Spanish translation
 * i18n: Ukrainian translation
 * misc: Added generic name and sub category to desktop file
 * misc: Added uninstall target, so source installations can be uninstalled
   with `make uninstall` (#28)
 * fix: Fix DBUS service file if installed to location other than `/usr` (#13)
 * fix: Locales not loaded if not installed to /usr due to missing locale path

# Version 0.7.2 - 2016-07-07
 * ui: Fixed window size not saved properly in Gtk 3.20 (#5)

# Version 0.7.1 - 2016-02-28
 * build: Fixed building with Gtk 3.14
 * build: Allow building with Gettext < 0.19 (disables localized .desktop file)

# Version 0.7.0 - 2016-02-26
 * ui: Moved record / stop button to header
 * ui: Show desktop notification after saving, with ability
   to open the file manager from there
 * ui: Use custom styling for recording area overlay
 * i18n: .desktop file gets translated

# Version 0.6.0 - 2016-01-28
 * ui: Removed unused auto save option from preferences dialog
 * fix: Try to always open the file manager, not the image viewer
 * general: Changed app id to com.uploadedlobster.peek due to the
   previous using the wrong domain name by default. This also resets
   existing settings.
 * i18n: Updated German translation

# Version 0.5.0 - 2016.01.09
 * ui: Remember last used save folder
 * ui: The default file name used is now a localized hidden setting
 * ui: If dark theme is preferred is now a hidden setting

# Version 0.4.0 - 2016.01.09
 * ui: Prefer dark theme, removed custom window background hack
 * ui: Persist window position and size
 * recording: Do not block UI during GIF post processing

# Version 0.3.0 - 2016.01.08
 * ui: Added a "New window" action to app menu
 * fix: If fallback app menu was used it was not clickable
 * fix: Fixed warning and crash if indicators where shown when closing a window
 * fix: Delay indicator no longer resizes small windows
 * fix: Leave recording state if ffmpeg cannot be started
 * fix: App menu on Unity showed "Unknown application name"
 * i18n: App menu and preferences title are now localized

# Version 0.2.1 - 2016.01.07
 * i18n: Setup gettext
 * fix: Fixed installation directory for locale files

# Version 0.2.0 - 2016.01.07
 * ui: Application logo
 * ui: Size indicator is shown longer after resizing stops
 * fix: Fixed window transparency not properly set on some systems
 * fix: About dialog could not be closed with close button
 * i18n: Integrated translation extraction into build
 * i18n: German translation

# Version 0.1.0 - 2016.01.05
 * Initial public release with basic functionality working
