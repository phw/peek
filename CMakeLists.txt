project("peek" C)
cmake_minimum_required(VERSION 2.6)

set (XDG_APPS_INSTALL_DIR share/applications)

# Include macros for Vala and GLib
list(APPEND CMAKE_MODULE_PATH
  ${CMAKE_SOURCE_DIR}/cmake
)

include(FindVala)
include(UseVala)
include(GResource)
include(GSettings)

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
GLIB_COMPILE_RESOURCES(GLIB_RESOURCES
  SOURCE
    ui/${PROJECT_NAME}.gresource.xml
)

# GSettings
add_schema ("de.uploadedlobster.peek.gschema.xml")

# Compile Vala to C
vala_precompile(VALA_C
    src/main.vala
    src/peek-application.vala
    src/peek-application-window.vala
    src/peek-about-dialog.vala
    src/peek-preferences-dialog.vala
    src/desktop-integration.vala
    src/screen-recorder.vala
  PACKAGES
    gtk+-3.0
  OPTIONS
    --target-glib=2.38
    --gresources=../ui/${PROJECT_NAME}.gresource.xml
)

# Compile C code
add_executable(${PROJECT_NAME} ${VALA_C} ${GLIB_RESOURCES})

# Installation
install (TARGETS ${PROJECT_NAME} DESTINATION bin)
install (PROGRAMS peek.desktop DESTINATION ${XDG_APPS_INSTALL_DIR})
