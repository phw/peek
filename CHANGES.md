# Version 1.6.0 - unreleased
- feat: Add support for GNOME 40+ (#910)
- feat: Add sound capture settings
- feat: Removed issue submission from error dialog
- feat: Removed MP4 recording option due to maintenance and performance issues
- fix: Fix desktop integration for GNOME Flashback (#1202)
- fix: Fix format selection popover updating on format change
- i18n: New translations for Hungarian, Malayalam, Portuguese and Slovak
- i18n: Updated translations for Basque, Chinese (Traditional), Croatian,
  Czech, Dutch, Esperanto, Finnish, French, German, Hebrew, Indonesian, Italian,
  Lithuanian, Norwegian Bokmål, Polish, Portuguese (Brazil), Portuguese
  (Portugal), Russian, Serbian, Spanish, Swedish, Turkish and Ukrainian
- build: cmake builds are no longer supported, use meson

# Version 1.5.1 - 2020-02-19
- build: Fixed building with CMake

# Version 1.5.0 - 2020-02-18
- feat: Dialog to set recording area size (#246, #519)
- feat: Use radio buttons for format selection to easily show selected format
- fix: Show error dialog on startup if recording backend is unavailable (#539)
- fix: Fix missing title in taskbar on KDE Plasma (#349)
- fix: Changing output format in small UI mode resizes the window
- fix: Disable menu during recording
- i18n: New translations for Finnish and Hebrew
- i18n: Updated translations for Basque, Chinese (Simplified),
  Chinese (Traditional), Croatian, Czech, Dutch, French, German, Indonesian,
  Lithuanian, Norwegian Bokmål, Portuguese (Brazil), Spanish and Swedish

# Version 1.4.0 - 2019-09-24
- feat: Move app menu into application Window (#391, #438)
- feat: New application icon following new GNOME icon guidelines (#114, #390)
- feat: Set window type hint to UTILITY (ensures window gets opened as floating
  on tiling window managers)
- feat: Show shortcut hint in main window (#234, #285)
- feat: Added Recorder, Video and AudioVideo to desktop files categories (#340)
- feat: Improved the error message shown on GNOME Shell recording issues
- feat: Provide more details in error reports
- fix: Fixed double free error after ffmpeg recording (#419)
- fix: Fixed building with Vala 0.46.1 (#501)
- misc: Raised minimum Gtk version to 3.20
- i18n: Updated translations for Basque, Chinese (simplified),
  Chinese (traditional), Czech, Dutch, Esperanto, French, German, Italian,
  Japanese, Lithuanian, Norwegian Bokmål, Polish, Portuguese (Brazil),
  Portuguese (Portugal), Russian, Serbian, Spanish, Swedish, Turkish, Ukrainian
- i18n: New translations for Japanese and Turkish
- build: New Meson based build (old CMake build is deprecated and will be
  removed in release 1.5)
- build: Autogenerate po/LINGUAS

# Version 1.3.1 - 2018-03-29
- fix: Use yuv420p for VP9 encoding (#299)
- fix: Disable animations and transitions on recording view overlays (#208)
- i18n: Updated French and Russian translations
- packaging: Build ffmpeg with vp9_superframe for Flatpak and AppImage

# Version 1.3.0 - 2018-03-25
- feat: Use VP9 instead of VP8 for WebM recording (#293)
- feat: libx264 is no longer required when just recording GIF / APNG with
  FFmpeg back end
- feat: Removed avconv / libav backend and ImageMagick post processor
- misc: Added sources for DBus interfaces (#296)
- fix: Fixed lossy artifacts increasing GIF size when using gnome-shell
  recorder (#288)
- fix: Fixed countdown sometimes appearing in recording (#208)
- fix: Do not freeze window size on Xfce (#269)
- i18n: Fixed names of Chinese localization files (#294)
- i18n: Updated translations for Basque, Chinese (Simplified), Lithuanian,
  Norwegian Bokmål, Russian, Serbian, Ukrainian
- packaging: Removed Snapcraft build and Snap packages (#245, #270)

# Version 1.2.2 - 2018-01-28
- feat: Option to enable/disable desktop notifications after saving (#21)
- fix: Do not use H.264 baseline profile if libx264 was compiled with 10bit (#248)
- fix: Recording 1fps with FFmpeg does not fail anymore (#249)
- i18n: Updated translations for Arabic, Basque, Chinese (Simplified), Czech,
  Dutch, Esperanto, German, Norwegian Bokmål, Polish, Portuguese (Brazil),
  Russian, Swedish

# Version 1.2.1 - 2017-12-03
- i18n: Updated translations for Arabic, Czech, Esperanto, French, Lithuanian,
  Norwegian Bokmål, Polish, Serbian

# Version 1.2.0 - 2017-11-25
- feat: Quick format selection in headerbar (#174)
- feat: GIF conversion with gifski if installed for improved quality (#212, #179)
- feat: GIF quality level can be set in preferences, if gifski is available (#212)
- feat: GIF conversion with FFmpeg as default instead of ImageMagick (#125)
- feat: Display elapsed time in headerbar (#214)
- feat: Display an animated spinner while post processing (#58)
- feat: Support APNG as output format (#108)
- feat: Command line parameter `--no-headerbar` (#203)
- feat: Show dialog with error details on recording errors (#49)
- fix: Temporary files get unique name again (was broken in #161)
- fix: Quitting application does not interrupt rendering (#189)
- fix: Much smaller temporary file sizes
- fix: Recording could be stopped before it had actually started
- fix: Do not load local settings schema in release builds
- fix: On Plasma with Breeze theme Peek window was hard to resize (#199)
- i18n: Added Chinese (Traditional), Neapolitan
- i18n: Updated translations for Czech, Dutch, Esperanto, German, Italian,
  Lithuanian, Norwegian Bokmål, Polish, Serbian, Swedish
- build: libkeybinder is now optional
- package: Reduced file size for Snap packages

# Version 1.1.0 - 2017-10-05
- feat: Transparent recording area without compositor (#147, #7)
- fix: Unusual default permissions (#161)
- fix: Explicitly set ImageMagick resource limits (#112, #125)
- i18n: Updated translations for Basque, Chinese (Simplified), Czech, Dutch,
  French, German, Lithuanian, Russian, Serbian, Spanish, Swedish, Polish,
  Portuguese (Brazil)
- build: New flag `DISABLE_GNOME_SHELL` to disable gnome-shell recorder
- build: New flag `DISABLE_OPEN_FILE_MANAGER` to disable file manager integration
- build: Use CMake GNUInstallDirs variables
- package: Updated dependencies for Flatpak and Snap packages
- package: Stable Snap package depending on gnome-platform 3.26

# Version 1.0.3 - 2017-06-13
- package: fixed installing man page
- package: fixed Debian packaging

# Version 1.0.2 - 2017-06-13
- feat: Finish saving file when closing window while rendering (#142)
- feat: Highlight file when launching Dolphin file manager
- recording: Use raw video for recording GIF with GNOME Shell recorder (this
  is identical to how FFmpeg recorder works) (#116)
- fix: Failed to record MP4 when dimensions where not divisible by 2 (#141)
- fix: Make sure recording starts after countdown is hidden (#146)
- fix: Closing window while recording could leave temp files behind
- fix: KDE Plasma and XFCE were showing an empty button in notification
- fix: Place close button on the left on all desktops configured this way (#129)
- fix: Cinnamon showing notification with icon
- i18n: Indonesian and Serbian translation
- i18n: Updated translations for Basque, Esperanto, French, Portuguese (Brazil),
  Russian and Ukrainian
- docs: Added man page (#136)
- package: Removed dark theme hack for Flatpak (proper theme support is part of
  Flatpak now)
- package: Updated dependencies for Flatpak and Snap packages

# Version 1.0.1 - 2017-03-26
- recording: Use H.264 baseline profile for MP4 for increased browser
  compatibility (#111)
- recording: For WebM GNOME Shell recorder use same quality settings as with
  FFmpeg encoder
- ui: Show only the most recent "file saved" notification to avoid spamming
  the desktop with notifications.
- fix: Set temporary directory for ImageMagick
- fix: Always launch with `GDK_BACKEND=x11` for Wayland
- fix: Detect if global menus are disabled in Unity when running as
  Flatpak / Snap package
- i18n: Updated translations for Arabic, Czech, Russian and Spanish
- i18n: New translations for Basque and Esperanto
- docs: Added Debian instructions to build custom package
- docs: Added Snappy install instructions (development builds only)

# Version 1.0.0 - 2017-03-11
- recording: Support GNOME Shell screencast DBus service. Allows recording
   under GNOME Shell with XWayland (#33)
- recording: Support WebM and MP4 as output format (#73)
- recording: Added option to not record mouse cursor
- recording: Default frame rate is now 10fps
- ui: Recording can be started / stopped via configurable keyboard shortcut (#23)
- ui: Add `--start`, `--stop` and `--toggle` command line parameters to control
  the recording
- ui: Add `--backend` command line parameter to manually choose recording
  back end (`gnome-shell`, `ffmpeg` or `avconv` for now)
- ui: Hide button label on small window width. Allows for smaller recording area.
- misc: Use org.freedesktop.FileManager1 DBus service for launching file manager.
- fix: Fixed a possible race condition that could lead to empty or broken files (#1)
- fix: Moving Peek partially outside the visible area does no longer break the
  recording. Instead the recording area is clipped to the visible part (#64)
- fix: Starting recording in maximized window relocated the window on Ubuntu
  Unity (#74)
- fix: When canceling the file chooser also stop the background processing
  of the image (#96)
- i18n: Many updated translations, with Czech, Dutch, German, Lithuanian,
  Polish and Swedish 100% completed
- package: Peek is available from a Flatpak repository (#85)
- package: Provide AppStream data
- docs: Much improved README

# Version 0.9.1 - 2017-02-21
- i18n: Fixed Czech, Croatian, Korean, Dutch and Chinese (Simplified) not getting installed

# Version 0.9.0 - 2017-02-20
- ui: Fix problem of app menu not available on certain desktop configurations (#6)
- ui: Fix display of desktop notifications on Ubuntu Unity (#55)
- ui: Close button is displayed left on Ubuntu Unity (#67)
- ui: Workaround for gray borders under unity (#11)
- ui: Smaller border around recording area
- recording: Add resolution downsampling option (#32)
- recording: Minimal frame rate is now 1fps
- recording: Smaller temporary files by using libx264rgb instead of huffyuv (#2)
- recording: Support for avconv, if ffmpeg is unavailable (#56)
- i18n: Chinese (Simplified) translation
- i18n: Croatian translation
- i18n: Czech translation
- i18n: Dutch translation
- i18n: Italian translation
- i18n: Korean translation
- i18n: Norwegian Bokmål translation
- i18n: Portuguese (Brazil) translation
- i18n: Swedish translation
- fix: Fix possible crash when loading schema from local folder
- fix: Fix temp file deletion warning
- package: Peek is installable via [Ubuntu PPA](https://code.launchpad.net/%7Epeek-developers/+archive/ubuntu/stable)
- docs: Update installation instructions
- docs: Added FAQs

# Version 0.8.0 - 2016-10-25
- ui: Change button text while rendering (#24)
- ui: Add a `--version` command line argument
- ui: Show file choose directly after recording stops. This way
  rendering and choosing the file take place in parallel (#30)
- recording: Correctly scale recording area on HiDPI screens (#20)
- i18n: Arabic translation
- i18n: Catalan translation
- i18n: French translation
- i18n: Lithuanian translation
- i18n: Polish translation
- i18n: Portuguese (Portugal) translation
- i18n: Russian translation
- i18n: Spanish translation
- i18n: Ukrainian translation
- misc: Added generic name and sub category to desktop file
- misc: Added uninstall target, so source installations can be uninstalled
  with `make uninstall` (#28)
- fix: Fix DBus service file if installed to location other than `/usr` (#13)
- fix: Locales not loaded if not installed to /usr due to missing locale path

# Version 0.7.2 - 2016-07-07
- ui: Fixed window size not saved properly in Gtk 3.20 (#5)

# Version 0.7.1 - 2016-02-28
- build: Fixed building with Gtk 3.14
- build: Allow building with Gettext < 0.19 (disables localized .desktop file)

# Version 0.7.0 - 2016-02-26
- ui: Moved record / stop button to header
- ui: Show desktop notification after saving, with ability
  to open the file manager from there
- ui: Use custom styling for recording area overlay
- i18n: .desktop file gets translated

# Version 0.6.0 - 2016-01-28
- ui: Removed unused auto save option from preferences dialog
- fix: Try to always open the file manager, not the image viewer
- general: Changed app id to com.uploadedlobster.peek due to the previous using
  the wrong domain name by default. This also resets existing settings.
- i18n: Updated German translation

# Version 0.5.0 - 2016-01-09
- ui: Remember last used save folder
- ui: The default file name used is now a localized hidden setting
- ui: If dark theme is preferred is now a hidden setting

# Version 0.4.0 - 2016-01-08
- ui: Prefer dark theme, removed custom window background hack
- ui: Persist window position and size
- recording: Do not block UI during GIF post processing

# Version 0.3.0 - 2016-01-08
- ui: Added a "New window" action to app menu
- fix: If fallback app menu was used it was not clickable
- fix: Fixed warning and crash if indicators where shown when closing a window
- fix: Delay indicator no longer resizes small windows
- fix: Leave recording state if ffmpeg cannot be started
- fix: App menu on Unity showed "Unknown application name"
- i18n: App menu and preferences title are now localized

# Version 0.2.1 - 2016-01-07
- i18n: Setup gettext
- fix: Fixed installation directory for locale files

# Version 0.2.0 - 2016-01-07
- ui: Application logo
- ui: Size indicator is shown longer after resizing stops
- fix: Fixed window transparency not properly set on some systems
- fix: About dialog could not be closed with close button
- i18n: Integrated translation extraction into build
- i18n: German translation

# Version 0.1.0 - 2016-01-05
- Initial public release with basic functionality working
