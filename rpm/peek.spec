Name:           peek
Version:        1.0.3
Release:        1%{?dist}
Summary:        Simple screen recorder with an easy to use interface

License:        GPLv3
URL:            https://github.com/phw/peek
Source0:        https://github.com/phw/peek/archive/v%{version}.tar.gz#/%{name}-%{version}.tar.gz

BuildRequires:  cmake
BuildRequires:  vala-devel
BuildRequires:  gettext
BuildRequires:  pkgconfig(gtk+-3.0) >= 3.14
BuildRequires:  pkgconfig(keybinder-3.0)
BuildRequires:  desktop-file-utils
BuildRequires:  libappstream-glib
BuildRequires:  txt2man
BuildRequires:  gzip
Requires:       ffmpeg
Requires:       ImageMagick
Requires:       gstreamer1-plugins-good
Recommends:     gstreamer1-plugins-ugly

%description
Peek makes it easy to create short screencasts of a screen area. It was built
for the specific use case of recording screen areas, e.g. for easily showing UI
features of your own apps or for showing a bug in bug reports. With Peek you
simply place the Peek window over the area you want to record and press
"Record". Peek is optimized for generating animated GIFs, but you can also
directly record to WebM or MP4 if you prefer.


%prep
%autosetup


%build
%cmake -DBUILD_TESTS=OFF .
%make_build


%install
rm -rf $RPM_BUILD_ROOT
%make_install
desktop-file-validate %{buildroot}/%{_datadir}/applications/com.uploadedlobster.%{name}.desktop
appstream-util validate-relax --nonet %{buildroot}/%{_datadir}/metainfo/*.appdata.xml
%find_lang %{name}


%files -f %{name}.lang
%license LICENSE
%{_bindir}/%{name}
%{_datadir}/applications/com.uploadedlobster.%{name}.desktop
%{_datadir}/metainfo/com.uploadedlobster.%{name}.appdata.xml
%{_datadir}/dbus-1/services/com.uploadedlobster.%{name}.service
%{_datadir}/glib-2.0/schemas/com.uploadedlobster.%{name}.gschema.xml
%{_datadir}/icons/hicolor/*/apps/com.uploadedlobster.%{name}.png

%changelog
* Tue Jun 13 2017 Philipp Wolfer <ph.wolfer@gmail.com> -1.0.3
- Fixed installing man page

* Tue Jun 13 2017 Philipp Wolfer <ph.wolfer@gmail.com> -1.0.2
- Finish saving file when closing window while rendering
- Highlight file when launching Dolphin file manager
- Use raw video for recording GIF with GNOME Shell recorder (this is identical to how FFmpeg recorder works)
- Failed to record MP4 when dimensions where not divisible by 2
- Make sure recording starts after countdown is hidden
- Closing window while recording could leave temp files behind
- KDE Plasma and XFCE were showing an empty button in notification
- Place close button on the left on all desktops configured this way
- Cinammon showing notification with icon
- Indonesian and Serbian translation
- Updated translations for Basque, Esperanto, French, Portuguese (Brazil), Russian and Ukrainian
- Added man page

* Mon Mar 26 2017 Steeven Lopes <steevenlopes@outlook.com> -1.0.1
- Use H.264 baseline profile for MP4 for increased browser compatibility
- For WebM GNOME Shell recorder use same quality settings as with Fmpeg encoder
- Show only the most recent "file saved" notification to avoid spamming the desktop with notifications.
- Set temporary directory for ImageMagick
- Always launch with GDK_BACKEND=x11 for Wayland
- Detect if global menus are disabled in Unity when running as Flatpak / Snap package
- Updated translations for Arabic, Czech, Russian and Spanish
- New translations for Basque and Esperanto
- Added Debian instructions to build custom package
- Added Snappy install instructions (development builds only)


* Sat Mar 11 2017 Steeven Lopes <steevenlopes@outlook.com> -1.0.0
- Support GNOME Shell screencast DBus service. Allows recording under GNOME Shell with XWayland.
- Support WebM and MP4 as output format.
- Added option to not record mouse cursor.
- Default frame rate is now 10fps.
- Recording can be started / stopped via configurable keyboard shortcut.
- Add --start, --stop and --toggle command line parameters to control the recording.
- Add --backend command line parameter to manually choose recording backend (gnome-shell, ffmpeg or avcodec for now).
- Hide button label on small window width. Allows for smaller recording area.
- Use org.freedesktop.FileManager1 DBus service for launching file manager.
- Fixed a possible race condition that could lead to empty or broken files.
- Moving Peek partially outside the visible area does no longer break the recording. Instead the recording area is clipped to the visible part.
- Starting recording in maximized window relocated the window on Ubuntu Unity.
- When canceling the file chooser also stop the background processing of the image.
- Many updated translations, with Czech, Dutch, German, Lithuanian,Polish and Swedish 100% completed.
- Peek is available from a Flatpak repository.
- Provide AppStream data.
- Much improved README.

* Wed Feb 22 2017 Steeven Lopes <steevenlopes@outlook.com> -0.9.1
- Fixed Czech, Croatian, Korean, Dutch and Chinese (Simplified) not getting installed

* Wed Feb 22 2017 Steeven Lopes <steevenlopes@outlook.com> -0.9.0
- Fix problem of app menu not available on certain desktop configurations
- Fix display of desktop notifications on Ubuntu Unity
- Close button is displayed left on Ubuntu Unity
- Workaround for gray borders under unity
- Smaller border around recording area
- Add resolution downsampling option
- Minimal frame rate is now 1fps
- Smaller temporary files by using libx264rgb instead of huffyuv
- Support for avconf, if ffmpeg is unavailable
- Chinese (Simplified) translation
- Croatian translation
- Czech translation
- Dutch translation
- Italian translation
- Korean translation
- Norwegian Bokmål translation
- Portuguese (Brazil) translation
- Swedish translation
- Fix possible crash when loading schema from local folder
- Fix temp file deletion warning
- Peek is installable via Ubuntu PPA
- Update installation instructions
- Added FAQs

* Wed Feb 01 2017 Steeven Lopes <steevenlopes@outlook.com> -0.8.0
- Change button text while rendering
- Add a --version command line argument
- Show file choose directly after recording stops
- Correctly scale recording area on HiDPI screens
- Fix DBUS service file if installed to location other than /usr
- Fix locales not loaded if not installed to /usr due to missing locale path
- Add Translation: Arabic, Catalan, French, Lithuanian, Polish, Portuguese (Pt), Russian, Spanish, Ukrainian

* Sun Sep 04 2016 Roseanne Levert <dinnae@yandex.com> - 0.7.2-1
- First package
