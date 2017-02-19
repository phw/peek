# Peek - an animated GIF recorder
[![Build Status](https://travis-ci.org/phw/peek.svg?branch=master)](https://travis-ci.org/phw/peek)
[![Translation Status](https://hosted.weblate.org/widgets/peek/-/svg-badge.svg)](https://hosted.weblate.org/engage/peek/?utm_source=widget)
[![Packaging status](https://repology.org/badge/tiny-repos/peek.svg)](https://repology.org/metapackage/peek/packages)


## About
A simple tool that allows you to record short animated GIF images from your screen.

Currently only Linux with X11 is supported. Other Unix like systems using X11
should work as well. It is planned to also support Wayland and maybe other
operating systems in the future.


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


## Translations
You can help translate Peek into your language. Peek is using
[Weblate](https://weblate.org/) for translation management.

Go to the [Peek localization project](https://hosted.weblate.org/engage/peek/)
to start translating.


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
