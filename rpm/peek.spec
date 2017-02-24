Name:           peek
Version:        0.9.1
Release:        1%{?dist}
Summary:        Simple animated GIF screen recorder with an easy to use interface

License:        GPLv3
URL:            https://github.com/phw/peek
Source0:        https://github.com/phw/peek/archive/v%{version}.tar.gz#/%{name}-%{version}.tar.gz

BuildRequires:  cmake
BuildRequires:  vala-devel
BuildRequires:  gettext
BuildRequires:  pkgconfig(gtk+-3.0) >= 3.14
BuildRequires:  pkgconfig(keybinder-3.0)
Requires:       ffmpeg
Requires:       ImageMagick

%description
A simple tool that allows you to record short animated GIF images
from your screen.


%prep
%autosetup


%build
%cmake -DBUILD_TESTS=OFF .
%make_build


%install
rm -rf $RPM_BUILD_ROOT
%make_install
%find_lang %{name}


%files -f %{name}.lang
%license LICENSE
%{_bindir}/%{name}
%{_datadir}/applications/com.uploadedlobster.%{name}.desktop
%{_datadir}/dbus-1/services/com.uploadedlobster.%{name}.service
%{_datadir}/glib-2.0/schemas/com.uploadedlobster.%{name}.gschema.xml
%{_datadir}/icons/hicolor/*/apps/%{name}.png


%changelog
* Wed Feb 22 2017 Steeven Lopes <steevenlopes@outllok.com> -0.9.1
- Fixed Czech, Croatian, Korean, Dutch and Chinese (Simplified) not getting installed

* Wed Feb 22 2017 Steeven Lopes <steevenlopes@outllok.com> -0.9.0
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
