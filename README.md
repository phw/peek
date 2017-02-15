# Peek - an animated GIF recorder
[![Build Status](https://travis-ci.org/phw/peek.svg?branch=master)](https://travis-ci.org/phw/peek)
[![Translation Status](https://hosted.weblate.org/widgets/peek/-/svg-badge.svg)](https://hosted.weblate.org/engage/peek/?utm_source=widget)

## About
A simple tool that allows you to record short animated GIF images from your screen.

Currently only Linux with X11 is supported. Other Unix like systems using X11
should work as well. It is planned to also support Wayland and maybe other
operating systems in the future.

## Requirements
### Runtime

  * GTK+ >= 3.14
  * GLib >= 2.38
  * FFmpeg
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
A x86_64 DEB package is provided for download for the [latest release](https://github.com/phw/peek/releases).

In theory this package should also work on Debian. In practice you will miss the
ffmpeg package. libav is currently not directly usable as a replacement, but I
am working on it ;)

On Ubuntu 16.04 Xenial:
```
$ wget https://github.com/phw/peek/releases/download/v0.8.0/peek-0.8.0-Linux.deb
$ sudo apt-get install libsdl1.2debian ffmpeg libavdevice-ffmpeg56
$ sudo dpkg -i peek-0.8.0-Linux.deb
$ peek
```

### From source
You can build and install Peek using CMake:

    cmake . && make
    make install

## Translations
You can help translate Peek into your language. Peek is using
[Weblate](https://weblate.org/) for translation management.

Go to the [Peek localization project](https://hosted.weblate.org/engage/peek/)
to start translating.

## License
Peek Copyright (c) 2015-2016 by Philipp Wolfer <ph.wolfer@gmail.com>

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
