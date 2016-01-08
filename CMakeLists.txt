project("peek" C)
cmake_minimum_required(VERSION 2.6)

set (PEEK_VERSION_MAJOR 0)
set (PEEK_VERSION_MINOR 2)
set (PEEK_VERSION_PATCH 1)

set (XDG_APPS_INSTALL_DIR share/applications)
set (GettextTranslate_GMO_BINARY TRUE)
set (GettextTranslate_ALL TRUE)
set (LOCALEDIR ${CMAKE_INSTALL_PREFIX}/share/locale)

# Include macros for Vala and GLib
list(APPEND CMAKE_MODULE_PATH
  ${CMAKE_SOURCE_DIR}/cmake
)

include(FindVala)
include(UseVala)
include(GResource)
include(GSettings)
include(GettextTranslate)

# Check dependencies
find_package(Vala 0.22 REQUIRED)

find_package(PkgConfig)
pkg_check_modules(GTK REQUIRED gtk+-3.0>=3.10)
add_definitions(${GTK_CFLAGS} ${GTK_CFLAGS_OTHER})
link_libraries(${GTK_LIBRARIES})
link_directories(${GTK_LIBRARY_DIRS})

pkg_check_modules(GLIB2 REQUIRED glib-2.0>=2.38)
pkg_check_modules(CAIRO REQUIRED cairo)
pkg_check_modules(GMODULE REQUIRED gmodule-2.0)

# compile glib resource files to c code
configure_file (
  "${PROJECT_SOURCE_DIR}/ui/about.ui.in"
  "${PROJECT_SOURCE_DIR}/ui/about.ui"
  )

GLIB_COMPILE_RESOURCES(GLIB_RESOURCES
  SOURCE
    ui/${PROJECT_NAME}.gresource.xml
)

# GSettings
add_schema(schemas/de.uploadedlobster.peek.gschema.xml)

# Compile Vala to C
vala_precompile(VALA_C
    src/main.vala
    src/peek-application.vala
    src/peek-application-window.vala
    src/peek-about-dialog.vala
    src/peek-preferences-dialog.vala
    src/desktop-integration.vala
    src/screen-recorder/screen-recorder.vala
    src/screen-recorder/recording-area.vala
    src/screen-recorder/command-line-screen-recorder.vala
    #src/screen-recorder/avconv-screen-recorder.vala
    src/screen-recorder/ffmpeg-screen-recorder.vala
  PACKAGES
    gtk+-3.0
    posix
  OPTIONS
    --target-glib=2.38
    --gresources=${CMAKE_SOURCE_DIR}/ui/${PROJECT_NAME}.gresource.xml
)

# Compile C code
add_definitions(-DGETTEXT_PACKAGE="${PROJECT_NAME}")
add_executable(${PROJECT_NAME} ${VALA_C} ${GLIB_RESOURCES})

# Installation
install(TARGETS ${PROJECT_NAME} DESTINATION bin)
install(PROGRAMS peek.desktop DESTINATION ${XDG_APPS_INSTALL_DIR})

add_subdirectory(assets)
add_subdirectory(po)
