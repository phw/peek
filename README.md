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
  - [Arch Linux](#arch-linux)
  - [Ubuntu](#ubuntu)
  - [Debian](#debian)
  - [Fedora](#fedora)
  - [Other distributions](#other-distributions)
  - [From source](#from-source)
- [Frequently Asked Questions](#frequently-asked-questions)
  - [How can I capture mouse clicks and/or key strokes?](#how-can-i-capture-mouse-clicks-andor-key-strokes)
  - [The recording area is all black, how can I record anything?](#the-recording-area-is-all-black-how-can-i-record-anything)
  - [My recorded GIFs flicker, what is wrong?](#my-recorded-gifs-flicker-what-is-wrong)
  - [Why can't I interact with the UI elements inside the recording area?](#why-cant-i-interact-with-the-ui-elements-inside-the-recording-area)
  - [Why are the GIF files so big?](#why-are-the-gif-files-so-big)
  - [If GIF is so bad why use it at all?](#if-gif-is-so-bad-why-use-it-at-all)
  - [What about WebM or MP4? Those are well supported on the web.](#what-about-webm-or-mp4-those-are-well-supported-on-the-web)
  - [Why no native Wayland support?](#why-no-native-wayland-support)
- [Contribute](#contribute)
  - [Development](#development-1)
  - [Translations](#translations)
- [License](#license)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## About
Peek creates animated GIF screencasts using FFmpeg and ImageMagick. It was
built for the specific use case of recording screen areas, e.g., for easily
showing UI features of your own apps or for showing a bug in bug reports. It
is not a general purpose screencast app with extended features and it never
will be.

Peek runs on X11 or inside a GNOME Shell Wayland session using XWayland.
Support for more Wayland desktops might be added in the future (see FAQs below).


## Requirements
### Runtime

- GTK+ >= 3.14
- GLib >= 2.38
- [libkeybinder3](https://github.com/kupferlauncher/keybinder)
- FFmpeg or libav-tools
- ImageMagick
- Window manager with compositing enabled

### Development

- Vala compiler >= 0.22
- CMake >= 2.8.8
- Gettext (>= 0.19 for localized .desktop entry)


## Installation
### Official distribution packages
Peek is available in official package repositories for the following
distributions:

- [Gentoo](https://packages.gentoo.org/packages/media-video/peek)
- [OpenSUSE Tumbleweed](https://software.opensuse.org/package/peek)
- [Parabola](https://www.parabola.nu/packages/?q=peek)

### Flatpak
Peek can be installed on all distributions supporting [Flatpak](http://flatpak.org/).
To install, either download
[peek-stable.flatpakref](http://flatpak.uploadedlobster.com/peek-stable.flatpakref)
and open it with GNOME Software or install via command line:

    flatpak install --user http://flatpak.uploadedlobster.com/peek-stable.flatpakref

For full functionality you should also install
[xdg-desktop-portal-gtk](https://github.com/flatpak/xdg-desktop-portal-gtk).
Once installed you can run Peek via its application icon in your desktop
environment or from command line:

    flatpak run com.uploadedlobster.peek

To update to the latest version run:

    flatpak update --user com.uploadedlobster.peek

To test the latest development version you can install
[peek-master.flatpakref](http://flatpak.uploadedlobster.com/peek-master.flatpakref)

### Snappy
Peek can also be installed on all distributions supporting [Snappy](https://snapcraft.io/docs/core/install).
Currently only the development version is available in the Snappy format:

    sudo snap install peek --edge --devmode

### Arch Linux
For Arch Linux
[peek](https://aur.archlinux.org/packages/peek/) is available in the AUR. You
can also use [peek-git](https://aur.archlinux.org/packages/peek-git/) to install
the latest development version.

### Ubuntu
You can install the latest versions of Peek from the
[Ubuntu PPA](https://code.launchpad.net/~peek-developers/+archive/ubuntu/stable).

    sudo add-apt-repository ppa:peek-developers/stable
    sudo apt update
    sudo apt install peek

If you want to use the latest development version there is also a
[PPA with daily builds](https://code.launchpad.net/~peek-developers/+archive/ubuntu/daily)
available. Use the repository `ppa:peek-developers/daily` in the above commands.

### Debian
There are no official Debian packages, yet, but you can easily create your own
.deb package for Peek. First install the build dependencies:

    sudo apt install cmake valac libgtk-3-dev libkeybinder-3.0-dev libxml2-utils gettext

Then build Peek and package it:

    git clone https://github.com/phw/peek.git
    mkdir peek/build
    cd peek/build
    cmake -DCMAKE_INSTALL_PREFIX=/usr -DGSETTINGS_COMPILE=OFF ..
    make package

This will create the package `peek-1.0.1-Linux.deb`. You can install it with
dpkg:

    sudo dpkg -i peek-1.0.1-Linux.deb

### Fedora
Fedora 25 users can use this repository:

    sudo dnf config-manager --add-repo http://download.opensuse.org/repositories/home:/Bajoja/Fedora_25/home:Bajoja.repo
    sudo dnf install peek

To install the required `ffmpeg` package you can use the RPM Fusion free
repository, see the
[setup instructions for RPM Fusion](https://rpmfusion.org/Configuration).
Once the repository is enabled install FFmpeg with:

    sudo dnf install ffmpeg

For MP4 recording on GNOME Shell you also need the `gstreamer1-plugins-ugly`
package also available from RPM Fusion free:

    sudo dnf install gstreamer1-plugins-ugly

### Other distributions
See the [Repology package list](https://repology.org/metapackage/peek/packages)
for a list of Peek packages for various distributions.

### From source
You can build and install Peek using CMake:

    git clone https://github.com/phw/peek.git
    mkdir peek/build
    cd peek/build
    cmake -DCMAKE_INSTALL_PREFIX=/usr ..
    make

    # Run directly from source
    ./peek

    # Install system wide
    sudo make install

You can uninstall Peek again by running `sudo make uninstall` from within the
build directory.


## Frequently Asked Questions
### How can I capture mouse clicks and/or key strokes?
Peek does not support this natively. But you could install an external tool
like [key-mon](https://github.com/critiqjo/key-mon) which is usually included
in most distributions, so you can easily install with your package manager.
Then start key-mon with `key-mon --visible_click`. The `--visible_click` option
is for drawing small circles around mouse clicks.

### The recording area is all black, how can I record anything?
If the recording area is not showing the content behind Peek you have probably
compositing disabled in your window manager. Peek requires compositing in order
to make the Peek window transparent. Please consult your window manager's
documentation how to enable compositing.

### My recorded GIFs flicker, what is wrong?
Some users have experienced recorded windows flicker or other strange visual
artifacts only visible in the recorded GIF. This is most likely a video driver
issue. If you are using Intel video drivers switching between the SNA and UXA
acceleration methods can help. For NVIDIA drivers changing the "Allow Flipping"
setting in the NVIDIA control panel
[was reported to help](https://github.com/phw/peek/issues/86).

### Why can't I interact with the UI elements inside the recording area?
You absolutely should be able to click the UI elements inside the area you are
recording. However this does not work as intended on some window managers,
most notably i3. If this does not work for you on any other window manager
please open an [issue on Github](https://github.com/phw/peek/issues).

### Why are the GIF files so big?
Peek is using ImageMagick to optimize the GIF files and reduce the file size.
As was shown in
[issue #3](https://github.com/phw/peek/issues/3#issuecomment-243872774)
the resulting files are already small and compare well to other GIF recording
software. In the end the GIF format is not well suited for doing large
animations with a lot of changes and colors. For best results:

- Use a lower frame rate. 10fps is the default and works well, but in many
  cases you can even get good results with lower framerates.
- Avoid too much change. If there is heavy animation the frames will differ
  a lot.
- Record small areas or use the downsample option to scale the image. The GIF
  file format is not well suited for high resolution or full screen recording.
- Avoid too many colors, since GIF is limited to a 256 color palette. This one
  is not so much about file size but more about visual quality.
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
   is a rectangular area (e.g. you can have circular screens or [lay out windows
   in 3D space](https://www.youtube.com/watch?v=_FjuPn7MXMs)).

Unfortunately the whole concept of the Peek UI is that the window position
itself is used to obtain the recording coordinates. That means for now there
cannot be any fully native Wayland support without special support for this
use case by the compositor.

It is however possible to use Peek in a GNOME Shell Wayland session using
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
[up-for-grabs](https://github.com/phw/peek/labels/up-for-grabs). Those are
open issues which are not too difficult to solve and can be started without
too much knowledge about the code.

Another good starting point are issues tagged with
[help-wanted](https://github.com/phw/peek/labels/help-wanted). Those issues are
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
Peek Copyright © 2015-2017 by Philipp Wolfer <ph.wolfer@gmail.com>

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
