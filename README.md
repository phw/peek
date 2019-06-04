# Peek - an animated GIF recorder
[![GitHub release](https://img.shields.io/github/release/phw/peek.svg)](https://github.com/phw/peek/releases)
[![License: GPL v3+](https://img.shields.io/badge/license-GPL%20v3%2B-blue.svg)](http://www.gnu.org/licenses/gpl-3.0)
[![Packaging status](https://repology.org/badge/tiny-repos/peek.svg)](https://repology.org/metapackage/peek/packages)
[![Build Status](https://travis-ci.org/phw/peek.svg?branch=master)](https://travis-ci.org/phw/peek)
[![Translation Status](https://hosted.weblate.org/widgets/peek/-/svg-badge.svg)](https://hosted.weblate.org/engage/peek/?utm_source=widget)

![Peek recording itself](https://raw.githubusercontent.com/phw/peek/master/data/screenshots/peek-recording-itself.gif)

Simple screen recorder with an easy to use interface

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
## Contents

- [About](#about)
- [Requirements](#requirements)
  - [Runtime](#runtime)
  - [Development](#development)
- [Installation](#installation)
  - [Official distribution packages](#official-distribution-packages)
  - [Flatpak](#flatpak)
  - [Snappy](#snappy)
  - [AppImage](#appimage)
  - [Ubuntu](#ubuntu)
  - [ElementaryOS](#elementaryos)
  - [Debian](#debian)
  - [Fedora](#fedora)
  - [Solus](#solus)
  - [Arch Linux](#arch-linux)
  - [Other distributions](#other-distributions)
  - [From source](#from-source)
- [Frequently Asked Questions](#frequently-asked-questions)
  - [How can I capture mouse clicks and/or keystrokes?](#how-can-i-capture-mouse-clicks-andor-keystrokes)
  - [How can I improve the quality of recorded GIF files](#how-can-i-improve-the-quality-of-recorded-gif-files)
  - [Why are the GIF files so big?](#why-are-the-gif-files-so-big)
  - [If GIF is so bad why use it at all?](#if-gif-is-so-bad-why-use-it-at-all)
  - [What about WebM or MP4? Those are well supported on the web.](#what-about-webm-or-mp4-those-are-well-supported-on-the-web)
  - [Why can't I interact with the UI elements inside the recording area?](#why-cant-i-interact-with-the-ui-elements-inside-the-recording-area)
  - [My recorded GIFs flicker, what is wrong?](#my-recorded-gifs-flicker-what-is-wrong)
  - [On i3 the recording area is all black, how can I record anything?](#on-i3-the-recording-area-is-all-black-how-can-i-record-anything)
  - [Why no native Wayland support?](#why-no-native-wayland-support)
- [Contribute](#contribute)
  - [Development](#development-1)
  - [Translations](#translations)
- [License](#license)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## About
Peek makes it easy to create short screencasts of a screen area. It was built
for the specific use case of recording screen areas, e.g. for easily showing UI
features of your own apps or for showing a bug in bug reports. With Peek, you
simply place the Peek window over the area you want to record and press
"Record". Peek is optimized for generating animated GIFs, but you can also
directly record to WebM or MP4 if you prefer.

Peek is not a general purpose screencast app with extended features but
rather focuses on the single task of creating small, silent screencasts of
an area of the screen for creating GIF animations or silent WebM or MP4
videos.

Peek runs on X11 or inside a GNOME Shell Wayland session using XWayland.
Support for more Wayland desktops might be added in the future (see FAQs below).


## Requirements
### Runtime

- GTK+ >= 3.20
- GLib >= 2.38
- [libkeybinder3](https://github.com/kupferlauncher/keybinder)
- FFmpeg >= 3
- GStreamer 'Good' plugins (for recording on GNOME Shell)
- GStreamer 'Ugly' plugins (for MP4 recording on GNOME Shell)
- [gifski](https://gif.ski/) (optional but recommended for improved GIF quality)

### Development

- Vala compiler >= 0.22
- Meson >= 0.37.0
- Gettext (>= 0.19 for localized .desktop entry)
- txt2man (optional for building man page)


## Installation
### Official distribution packages
Peek is available in official package repositories for the following
distributions:

- [Arch Linux](https://www.archlinux.org/packages/community/x86_64/peek/)
- [Gentoo](https://packages.gentoo.org/packages/media-video/peek)
- [OpenSUSE Tumbleweed](https://software.opensuse.org/package/peek)
- [Parabola](https://www.parabola.nu/packages/?q=peek)
- [Solus](https://dev.getsol.us/source/peek/)

### Flatpak
Peek can be installed on all distributions supporting [Flatpak](http://flatpak.org/) from [Flathub](https://flathub.org/apps/details/com.uploadedlobster.peek).
To install, either download
[com.uploadedlobster.peek.flatpakref](https://flathub.org/repo/appstream/com.uploadedlobster.peek.flatpakref)
and open it with GNOME Software or install via command line:

    flatpak install flathub com.uploadedlobster.peek

For full functionality you should also install
[xdg-desktop-portal-gtk](https://github.com/flatpak/xdg-desktop-portal-gtk).
It is available for most current distributions. Once installed you can run Peek
via its application icon in your desktop environment or from the command line:

    flatpak run com.uploadedlobster.peek

To update to the latest version run:

    flatpak update --user com.uploadedlobster.peek

To test the latest development version you can install
[peek-master.flatpakref](http://flatpak.uploadedlobster.com/peek-master.flatpakref)

### Snappy
Peek no longer has officially supported Snap packages, see
[the announcement](https://www.reddit.com/r/Ubuntu/comments/870bcn/snap_support_for_peek_screen_recorder_discontinued/).
Please consider using the Flatpak or AppImage versions or use the Ubuntu PPA
if you are using Ubuntu.

### AppImage
Peek [AppImage](https://appimage.org/) packages are available on the
[release page](https://github.com/phw/peek/releases). To run download the
`.AppImage` file and set it executable, then just run it. You can name the file
however you want, e.g. you can name it just `peek` and place it in `$HOME/bin`
for easy access. See the [AppImage wiki](https://github.com/AppImage/AppImageKit/wiki)
for more information on how to use AppImages and integrate them with your system.

### Ubuntu
You can install the latest versions of Peek from the
[Ubuntu PPA](https://code.launchpad.net/~peek-developers/+archive/ubuntu/stable).

    sudo add-apt-repository ppa:peek-developers/stable
    sudo apt update
    sudo apt install peek

If you want to use the latest development version there is also a
[PPA with daily builds](https://code.launchpad.net/~peek-developers/+archive/ubuntu/daily)
available. Use the repository `ppa:peek-developers/daily` in the above commands.

### ElementaryOS
Adding PPA repositories requires the package `software-properties-common`

    sudo apt install software-properties-common
    sudo add-apt-repository ppa:peek-developers/stable
    sudo apt update
    sudo apt install peek

If you want to use the latest development version there is also a
[PPA with daily builds](https://code.launchpad.net/~peek-developers/+archive/ubuntu/daily)
available. Use the repository `ppa:peek-developers/daily` in the above commands.

### Debian
There are official Debian packages for Debian 10 ("Buster") via main repository
and packages for Debian 9 ("Stretch") via
[`stretch-backports`](https://packages.debian.org/stretch-backports/peek) repository.
Please refer to [Debian Backports Website](https://backports.debian.org/)
for detailed usage of `stretch-backports` repository.

After enabling `stretch-backports` for Debian 9 (Debian 10 or `Sid` doesn't need
any tweaks at all), installation can be done by simply typing:

    sudo apt install peek

Besides, you can also create your own `.deb` package for Peek easily.
First, install the build dependencies:

    sudo apt install cmake valac libgtk-3-dev libkeybinder-3.0-dev libxml2-utils gettext txt2man

Then build Peek and package it:

    git clone https://github.com/phw/peek.git
    mkdir peek/build
    cd peek/build
    cmake -DCMAKE_INSTALL_PREFIX=/usr -DGSETTINGS_COMPILE=OFF ..
    make package

This will create the package `peek-x.y.z-Linux.deb` (where `x.y.z` is the
current version). You can install it with `apt`:

    sudo apt install ./peek-*-Linux.deb

### Fedora
For Fedora 25 add this repository:

    sudo dnf config-manager --add-repo https://download.opensuse.org/repositories/home:/phiwo:/peek/Fedora_25/home:phiwo:peek.repo

For Fedora 26 and later, add this repository:

    sudo dnf config-manager --add-repo https://download.opensuse.org/repositories/home:/phiwo:/peek/Fedora_26/home:phiwo:peek.repo

Then install Peek with:

    sudo dnf install peek

To install the required `ffmpeg` package you can use the RPM Fusion free
repository, see the
[setup instructions for RPM Fusion](https://rpmfusion.org/Configuration).
Once the repository is enabled install FFmpeg with:

    sudo dnf install ffmpeg

For MP4 recording on GNOME Shell you also need the `gstreamer1-plugins-ugly`
package also available from RPM Fusion free:

    sudo dnf install gstreamer1-plugins-ugly

### Solus
Solus users can simply install with:

	sudo eopkg it peek

### Arch Linux
Arch Linux users can simply install with:

	sudo pacman -S peek
	
For GNOME Shell recording there are some optional packages you can choose from:
   
       gst-plugins-good: Recording under Gnome Shell
       gst-plugins-ugly: MP4 output under Gnome Shell
       gifski: High quality GIF animations with thousands of colors
       
If you have a package manager for AUR (or fetch from AUR manually) the git version is available [here](https://aur.archlinux.org/packages/peek-git)


### Other distributions
See the [Repology package list](https://repology.org/metapackage/peek/packages)
for a list of Peek packages for various distributions.

### From source
You can build and install Peek using Meson with Ninja:

    git clone https://github.com/phw/peek.git
    cd peek
    meson --prefix=/usr/local builddir
    cd builddir
    ninja

    # Run directly from source
    ./peek

    # Install system-wide
    sudo ninja install

*Note: `ninja` might be called `ninja-build` on some distributions.*

## Frequently Asked Questions
### How can I capture mouse clicks and/or keystrokes?
Peek does not support this natively. But you could install an external tool
like [key-mon](https://github.com/critiqjo/key-mon) which is usually included
in most distributions, so you can easily install with your package manager.
Then start key-mon with `key-mon --visible_click`. The `--visible_click` option
is for drawing small circles around mouse clicks.

### How can I improve the quality of recorded GIF files
To get the best possible quality you should install the [gifski](https://gif.ski/)
GIF encoder. If available Peek will automatically use gifski and will provide
a quality slider in the preferences dialog. The default value will give a
balanced result between quality and file size. Set the quality to maximum if you
want to get the highest possible quality even with thousands of colors. The file
size will increase significantly, though (see below).

### Why are the GIF files so big?
The GIF format is highly inefficient and not well suited for doing large
animations with a lot of changes and colors. Peek tries its best to reduce the
file size by using FFmpeg or [gifski](https://gif.ski/) to generate optimized
GIF files. For best results:

- Use a lower frame rate. 10fps is the default and works well, but in many
  cases you can even get good results with lower framerates.
- If you have [gifski](https://gif.ski/) installed you can adjust the GIF
  quality in the preferences. A lower quality gives a smaller file size at the
  expense of visual quality (see above).  
- Avoid too much change. If there is heavy animation the frames will differ
  a lot.
- Record small areas or use the downsample option to scale the image. The GIF
  file format is not well suited for high resolution or full-screen recording.
- Avoid too many colors, since GIF is limited to a 256 color palette per frame.
  This one is not so much about file size but more about visual quality.
- If the above suggestions are not suitable for your use case, consider using
  WebM or MP4 format (see below).

### If GIF is so bad why use it at all?
While GIF is a very old format, it has seen some rise in usage again in recent
years. One reason is its easy usage in the Web. GIF files are supported nearly
everywhere, which means you can add animations easily to everywhere where you
can upload images. With real video files you are still more limited. Typical use
cases for Peek are recording small user interactions for showing UI features
of an app you developed, for making short tutorials or for reporting bugs.

### What about WebM or MP4? Those are well supported on the web.
Peek allows you to record in both WebM and MP4 format, just choose your
preferred output format in the preferences. Both are well supported by modern
browsers, even though they are still not as universally supported by tools and
online services as GIFs.

### Why can't I interact with the UI elements inside the recording area?
You absolutely should be able to click the UI elements inside the area you are
recording. If you use i3 you should stack Peek with the window you intend to record
or make sure all windows are floating and uncheck "Always on top" from the Peek settings.  
If you want to be able to control the area when recording in i3 you can move Peek
to the Scratchpad it will keep recording the area once you hide the window.
If this does not work for you on any other window manager please open an [issue on GitHub](https://github.com/phw/peek/issues).

### My recorded GIFs flicker, what is wrong?
Some users have experienced recorded windows flicker or other strange visual
artifacts only visible in the recorded GIF. This is most likely a video driver
issue. If you are using Intel video drivers switching between the SNA and UXA
acceleration methods can help. For NVIDIA drivers changing the "Allow Flipping"
setting in the NVIDIA control panel
[was reported to help](https://github.com/phw/peek/issues/86).

### On i3 the recording area is all black, how can I record anything?
i3 does not support the X shape extension. In order to get a transparent
recording area, you have to run a compositor such as Compton.

### Why no native Wayland support?
Wayland has two restrictions that make it hard for Peek to support Wayland
natively:

1. The Wayland protocol does not define a standard way for applications to
   obtain a screenshot. That is intentional, as taking an arbitrary screenshot
   essentially means any application can read the contents of the whole display,
   and Wayland strives to offer improved security by isolating applications. It
   is up to the compositors to provide screenshot capability, and most do. GNOME
   Shell also provides a public interface for applications to use which Peek
   does support.

2. The Wayland protocol does not provide absolute screen coordinates to the
   applications. There is not even a coordinate system for windows at all. Again
   this is intentional, as they are not needed in many cases and you do not need
   to follow restrictions imposed by the traditional assumption that the screen
   is a rectangular area (e.g. you can have circular screens or [layout windows
   in 3D space](https://www.youtube.com/watch?v=_FjuPn7MXMs)).

Unfortunately, the whole concept of the Peek UI is that the window position
itself is used to obtain the recording coordinates. That means, for now, there
cannot be any fully native Wayland support without special support for this
use case by the compositor.

It is, however, possible to use Peek in a GNOME Shell Wayland session using
XWayland by launching Peek with the X11 backend:

    GDK_BACKEND=x11 peek

Support for compositors other than GNOME Shell can be added if a suitable
screencasting interface is provided.


## Contribute
If you want to help make Peek better the easiest thing you can do is to
[report issues and feature requests](https://github.com/phw/peek/issues).
Or you can help in development and translation.

### Development
You are welcome to contribute code and provide pull requests for Peek. The
easiest way to start is looking at the open issues tagged with
[good first issue](https://github.com/phw/peek/labels/good%20first%20issue). Those are
open issues which are not too difficult to solve and can be started without
too much knowledge about the code.

Another good starting point are issues tagged with
[help wanted](https://github.com/phw/peek/labels/help%20wanted). Those issues are
probably harder to solve, but for some reason I cannot work on it for now and
would love to see somebody jump in.

In any case, just leave a note on the issue itself that you are working on it,
to avoid multiple people working on the same issue.


### Translations
You can help translate Peek into your language. Peek is using
[Weblate](https://weblate.org/) for translation management.

Go to the [Peek localization project](https://hosted.weblate.org/projects/peek/translations/)
to start translating. If the language you want to translate into is not already
available, you [can add it here](https://hosted.weblate.org/projects/peek/translations/#newlang).

If you want to be credited for your translation, please add your name to the
[translator-credits](https://hosted.weblate.org/search/peek/translations/?q=translator-credits&search=exact&source=on&type=all&ignored=False)
for your language. The translator credits are shown in Peek's About dialog.


## License
Peek Copyright © 2015-2018 by Philipp Wolfer <ph.wolfer@gmail.com>

Peek is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Peek is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Peek.  If not, see <http://www.gnu.org/licenses/>.
