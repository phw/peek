# Version 0.7.1 - 2016-02-26
 * buil: Fixed building with Gtk 3.14

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
