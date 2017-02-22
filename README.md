# Peek - an animated GIF recorder
[![Build Status](https://travis-ci.org/phw/peek.svg?branch=master)](https://travis-ci.org/phw/peek)
[![Translation Status](https://hosted.weblate.org/widgets/peek/-/svg-badge.svg)](https://hosted.weblate.org/engage/peek/?utm_source=widget)
[![Packaging status](https://repology.org/badge/tiny-repos/peek.svg)](https://repology.org/metapackage/peek/packages)

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
## Contents

- [About](#about)
- [Requirements](#requirements)
  - [Runtime](#runtime)
  - [Development](#development)
- [Installation](#installation)
  - [Arch Linux](#arch-linux)
  - [Ubuntu / Debian](#ubuntu--debian)
  - [Gentoo](#gentoo)
  - [Fedora](#fedora)
  - [From source](#from-source)
- [Frequently Asked Questions](#frequently-asked-questions)
  - [The recording area is all black, how can I record anything?](#the-recording-area-is-all-black-how-can-i-record-anything)
  - [My recorded GIFs flicker, what is wrong?](#my-recorded-gifs-flicker-what-is-wrong)
  - [Why can't I interact with the UI elements inside the recording area?](#why-cant-i-interact-with-the-ui-elements-inside-the-recording-area)
  - [Why are the GIF files so big?](#why-are-the-gif-files-so-big)
  - [If GIF is so bad why use it at all?](#if-gif-is-so-bad-why-use-it-at-all)
  - [What about WEBM or MP4? Those are well supported on the web.](#what-about-webm-or-mp4-those-are-well-supported-on-the-web)
  - [Why no native Wayland support?](#why-no-native-wayland-support)
- [Translations](#translations)
- [License](#license)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## About
Peek creates animated GIF screencasts using ffmpeg and imagemagick. It was
built for the specific use case of recording screen areas, e.g., for easily
showing UI features of your own apps or for showing a bug in bug reports. It
is not a general purpose screencast app with extended features and it never
will be.

Currently only X11 is fully supported. There is no direct support for Wayland
and Mir, but you can use Peek on Gnome Shell with XWayland (see FAQs below).


## Requirements
### Runtime

  * GTK+ >= 3.14
  * GLib >= 2.38
  * FFmpeg or libav-tools
  * ImageMagick
  * Window manager with compositing enabled

### Development

 * Vala compiler
 * CMake >= 2.8.8
 * Gettext (>= 0.19 for localized .desktop entry)


## Installation
### Arch Linux
For Arch Linux there is a
[PKGBUILD](https://aur.archlinux.org/packages/peek/) available in the AUR.

### Ubuntu / Debian
You can install the latest versions of Peek from the
[Ubuntu PPA](https://code.launchpad.net/~peek-developers/+archive/ubuntu/stable).

    sudo add-apt-repository ppa:peek-developers/stable
    sudo apt-get update
    sudo apt-get install peek

If you want to use the latest development version there is also a
[PPA with daily builds](https://code.launchpad.net/~peek-developers/+archive/ubuntu/daily)
available. Use the repository `ppa:peek-developers/daily` in the above commands.

The deb packages from these PPAs probably will also work on Debian.

### Gentoo
Install the [Peek Ebuild](https://packages.gentoo.org/packages/media-video/peek).

### Fedora
Install the dependencies with dnf:

    sudo dnf install vala gtk3-devel ffmpeg

Then follow the instructions to install from source below.

### From source
You can build and install Peek using CMake:

```shell
git clone git@github.com:phw/peek.git
mkdir peek/build
cd peek/build
cmake -DCMAKE_INSTALL_PREFIX=/usr ..
make

# Run directly from source
./peek

# Install system wide
sudo make install
```

## Frequently Asked Questions
### The recording area is all black, how can I record anything?
If the recording area is not showing the content behind Peek you have probably
compositing disabled in your window manager. Peek requires compositing in order
to make the Peek window transparent. Please consult your window manager's
documentation how to enable compositing.

### My recorded GIFs flicker, what is wrong?
Some users have experienced recorded windows flicker or other strange visual
artifacts only visible in the recorded GIF. This is most likely a video driver
issue. If you are using Intel video drivers switching between the SNA and UXA
acceleration methods can help.

### Why can't I interact with the UI elements inside the recording area?
You absolutely should be able to click the UI elements inside the area you are
recording. However this does not work as intented on some window managers,
most notably I3. If this does not work for you on any other window manager
please open an [issue on Github](https://github.com/phw/peek/issues).

### Why are the GIF files so big?
Peek is using ImageMagick to optimize the GIF files and reduce the file size.
As was shown in [issue #3](https://github.com/phw/peek/issues/3#issuecomment-243872774)
the resulting files are already small and compare well to other GIF recording
software. In the end the GIF format is not well suited for doing large
animations with a lot of changes and colors. For best results:

- Use a low framerate. 15fps seems to work quite well.
- Avoid too much change. If there is heavy animation the frames will differ a lot.
- Avoid too many colors, since GIF is limited to a 256 color pallette. This one
  is not so much about file size but more about visual quality.

### If GIF is so bad why use it at all?
While GIF is a very old format, it has seen some rise in usage again in recent
years. One reason is its easy usage in the Web. GIF files are supported nearly
everywhere, which means you can add animations easily to everywhere where you
can upload images. With real video files you are still more limited. Typical use
cases for Peek are recording small user interactions for showing UI features
of an app you developed, for making short tutorials or for reporting bugs.

### What about WEBM or MP4? Those are well supported on the web.
True, but still still not as universally supported as GIFs. But Peek will become
an option to choose WEBM output for those who prefer or need it.

### Why no native Wayland support?
Wayland has two restrictions that make it hard for Peek to support Wayland
natively:

1. The Wayland protocol does not define a standard way for applications to
   obtain a screenshot. That is intentional, as taking an arbitrary screenshot
   essentially means any application can read the contents of the whole display,
   and Wayland strives to offer improved security by isolating applications. It
   is up to the compositors to provide screenshot capability, and most do. Gnome
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

It is however possible to use Peek in a Gnome Shell Wayland session using
XWayland by launching Peek with the X11 backend:

    GDK_BACKEND=x11 peek

Support for cmpositors other than Gnome Shell can be added if a suitable
screencasting interface is provided.


## Translations
You can help translate Peek into your language. Peek is using
[Weblate](https://weblate.org/) for translation management.

Go to the [Peek localization project](https://hosted.weblate.org/projects/peek/translations/)
to start translating. If the language you want to translate into is not already
available, you [can add it here](https://hosted.weblate.org/projects/peek/translations/#newlang).


## License
Peek Copyright (c) 2015-2017 by Philipp Wolfer <ph.wolfer@gmail.com>

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
