# Peek - an animated GIF recorder

## About
A simple tool that allows you to record short animated GIF images from your screen.

Currently only Linux with X is supported. Other Unix like systems using X
should work as well. It is planned to also support Wayland and maybe Other
operating systems in the future.

## Requirements
### Runtime

  * GTK+ >= 3.10
  * FFmpeg
  * ImageMagick
  * Window manager with compositing enabled

### Development

 * Vala compiler
 * CMake >= 2.6
 * Gettext

## Building
You can build and install Peek using CMake:

    cmake . && make
    make install

For Arch Linux there is also a
[PKGBUILD](https://aur4.archlinux.org/packages/peek/) available in the AUR.

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
