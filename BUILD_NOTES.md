# Peek build and packaging notes
This file contains information about building and packaging Peek. The
information here is mainly for developers and packagers, end users should
refer to the installation instrctions in README.md.

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
 - cmake (>= 2.6)
 - valac (>= 0.22)
 - libgtk-3-dev (>= 3.14)
 - libkeybinder-3.0-dev
 - libxml2-utils
 - gettext

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

Build Flatpak and place it in flatpak-repo repository:

    flatpak-builder --repo=flatpak-repo com.uploadedlobster.peek \
        flatpak.json --force-clean

Generate a `.flatpak` file for single file distribution:

    flatpak build-bundle flatpak-repo peek-1.0.0.flatpak \
        com.uploadedlobster.peek

### Snappy

Build snappy package with:

    snapcraft
