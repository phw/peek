# Peek build and packaging notes
This file contains information about building and packaging Peek. The
information here is mainly for developers and packagers, end users should
refer to the installation instructions in README.md.

## Building

### Building from source

From inside the Peek source folder run:

    mkdir -p build
    cd build
    cmake -DCMAKE_INSTALL_PREFIX=/usr ..
    make

Or you can build with [ninja](https://ninja-build.org/):

    cmake -DCMAKE_INSTALL_PREFIX=/usr -GNinja ..
    ninja

`ninja` might be called `ninja-build` on some distributions.

### Build and run tests

    cmake -DBUILD_TESTS=ON ..
    make
    make test

### Running Peek with debug output

    G_MESSAGES_DEBUG=all ./peek

### Update translations

    make update-po
    make peek.pot-update


## Packaging

### Debian package

#### Build requirements
 - cmake (>= 2.8.8)
 - valac (>= 0.22)
 - libgtk-3-dev (>= 3.14)
 - libkeybinder-3.0-dev
 - libxml2-utils
 - gettext (>= 0.19 for localized .desktop entry)
 - txt2man (optional for building man page)
 - gzip

#### Runtime requirements
 - libgtk-3-0 (>= 3.14)
 - libglib2.0 (>= 2.38)
 - libkeybinder-3.0-0
 - ffmpeg | libav-tools
 - imagemagick

#### Generating the package
A Debian package can be created with cmake on any system:

    cmake -DCMAKE_INSTALL_PREFIX=/usr -DGSETTINGS_COMPILE=OFF ..
    make package

### Flatpak

Install the GNOME runtime and SDK as described in
http://docs.flatpak.org/en/latest/getting-setup.html

**Note:** Flatpak >= 0.9.3 is required for the build.

Build Flatpak and place it in flatpak-repo repository:

    flatpak-builder --repo=flatpak-repo com.uploadedlobster.peek \
      --gpg-sign=B539AD7A5763EE9C1C2E4DE24C14923F47BF1A02 \
      flatpak-stable.json --force-clean

You can build for different architecture with the `--arch` parameter, e.g.
`--arch=x86_64` or `--arch=i386`.

Generate a `.flatpak` file for single file distribution:

    flatpak build-bundle flatpak-repo peek-1.0.0-0.flatpak \
      com.uploadedlobster.peek stable

### Snappy

Build snappy package with:

    snapcraft

Install the package with:

    sudo snap install --dangerous peek_0.9.1+git_amd64.snap
