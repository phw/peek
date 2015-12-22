project("peek" C)
cmake_minimum_required(VERSION 2.6)

# Include macros for Vala and GLib
list(APPEND CMAKE_MODULE_PATH
  ${CMAKE_SOURCE_DIR}/cmake
)

include(FindVala)
include(UseVala)
include(GResource)

# Check dependencies
find_package(Vala REQUIRED)

find_package(PkgConfig)
pkg_check_modules(GTK REQUIRED gtk+-3.0)
add_definitions(${GTK_CFLAGS} ${GTK_CFLAGS_OTHER})
link_libraries(${GTK_LIBRARIES})
link_directories(${GTK_LIBRARY_DIRS})

pkg_check_modules(REQUIRED cairo gmodule-2.0)

# Compile Vala to C
vala_precompile(VALA_C
    src/main.vala src/screen-recorder.vala
  PACKAGES
    gtk+-3.0
    gmodule-2.0
)

# compile glib resource files to c code
GLIB_COMPILE_RESOURCES( GLIB_RESOURCES
  SOURCE
    ui/${PROJECT_NAME}.gresource.xml
)

# Compile C code
add_executable(${PROJECT_NAME} ${VALA_C} ${GLIB_RESOURCES})
