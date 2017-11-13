project("peek" C)
cmake_minimum_required(VERSION 2.6)

set (PEEK_VERSION_MAJOR 1)
set (PEEK_VERSION_MINOR 1)
set (PEEK_VERSION_PATCH 0)

# Include macros for Vala and GLib
list(APPEND CMAKE_MODULE_PATH
  ${CMAKE_SOURCE_DIR}/cmake
)

include(GNUInstallDirs)
include(CTest)
include(FindVala)
include(UseVala)
include(GResource)

set (GettextTranslate_GMO_BINARY TRUE)
set (GettextTranslate_ALL TRUE)
if (NOT DEFINED LOCALEDIR)
  set (LOCALEDIR ${CMAKE_INSTALL_FULL_LOCALEDIR})
endif ()
include(GettextTranslate)

# Check dependencies
find_package(Vala 0.22 REQUIRED)

find_package(PkgConfig)
set(REQUIRE_GTK "3.14")
pkg_check_modules(GTK REQUIRED gtk+-3.0>=${REQUIRE_GTK})
pkg_check_modules(CAIRO REQUIRED cairo)
pkg_check_modules(GIO REQUIRED gio-2.0>=2.42)
pkg_check_modules(GLIB2 REQUIRED glib-2.0>=2.38)
pkg_check_modules(GMODULE REQUIRED gmodule-2.0)
pkg_check_modules(KEYBINDER keybinder-3.0)

add_definitions(${GTK_CFLAGS} ${GTK_CFLAGS_OTHER})
link_libraries(${GTK_LIBRARIES})
link_libraries(${KEYBINDER_LIBRARIES})
link_directories(${GTK_LIBRARY_DIRS})

# compile glib resource files to c code
configure_file (
  "${PROJECT_SOURCE_DIR}/ui/about.ui.in"
  "${PROJECT_SOURCE_DIR}/ui/about.ui"
  )

GLIB_COMPILE_RESOURCES(GLIB_RESOURCES
  SOURCE
    ui/${PROJECT_NAME}.gresource.xml
)

set(VALA_DEFINITIONS "")
set(VALA_CUSTOM_VAPIS "")

list(APPEND VALA_CUSTOM_VAPIS "src/vapi/config.vapi")

if(NOT CMAKE_BUILD_TYPE STREQUAL Release)
  message (STATUS "Debug build")
  list(APPEND VALA_DEFINITIONS "DEBUG")
endif()

if(${KEYBINDER_FOUND})
  list(APPEND VALA_DEFINITIONS "HAS_KEYBINDER")
  list(APPEND VALA_CUSTOM_VAPIS "src/vapi/keybinder-3.0.vapi")
endif()

# Check for GTK features
if(${GTK_VERSION} VERSION_EQUAL "3.16" OR ${GTK_VERSION} VERSION_GREATER "3.16")
  message(STATUS "Compiling with features for GTK >= 3.16")
  set(REQUIRE_GTK "3.16")
  list(APPEND VALA_DEFINITIONS "HAS_GTK_LABEL_XALIGN")
endif()

# if(${GTK_VERSION} VERSION_EQUAL "3.20" OR ${GTK_VERSION} VERSION_GREATER "3.20")
#   message(STATUS "Compiling with features for GTK >= 3.20")
#   set(REQUIRE_GTK "3.20")
#   list(APPEND VALA_DEFINITIONS "HAS_GTK_FILECHOOSERNATIVE")
# endif()

if(${GTK_VERSION} VERSION_EQUAL "3.22" OR ${GTK_VERSION} VERSION_GREATER "3.22")
  message(STATUS "Compiling with features for GTK >= 3.22")
  set(REQUIRE_GTK "3.22")
  list(APPEND VALA_DEFINITIONS "HAS_GTK_SHORTCUT_LABEL")
endif()

# Flags for disabling certain features
if(DISABLE_GNOME_SHELL)
  message(STATUS "GNOME Shell recorder disabled by configuration")
  list(APPEND VALA_DEFINITIONS "DISABLE_GNOME_SHELL")
endif()

if(DISABLE_OPEN_FILE_MANAGER)
  message(STATUS "File manager integration disabled by configuration")
  list(APPEND VALA_DEFINITIONS "DISABLE_OPEN_FILE_MANAGER")
endif()

# Compile Vala to C
vala_precompile(VALA_C
    src/main.vala
    src/application.vala
    src/desktop-integration.vala
    src/defaults.vala
    src/errordomain.vala
    src/gtk-helper.vala
    src/utils.vala
    src/dbus/freedesktop-dbus.vala
    src/dbus/freedesktop-filemanager.vala
    src/dbus/gnome-shell-screencast.vala
    src/post-processing/cli-post-processor.vala
    src/post-processing/extract-frames-post-processor.vala
    src/post-processing/ffmpeg-post-processor.vala
    src/post-processing/gifski-post-processor.vala
    src/post-processing/imagemagick-post-processor.vala
    src/post-processing/post-processing-pipeline.vala
    src/post-processing/post-processor.vala
    src/recording/screen-recorder.vala
    src/recording/base-screen-recorder.vala
    src/recording/screen-recorder-factory.vala
    src/recording/recording-area.vala
    src/recording/recording-config.vala
    src/recording/gnome-shell-dbus-recorder.vala
    src/recording/cli-screen-recorder.vala
    src/recording/avconv-screen-recorder.vala
    src/recording/ffmpeg-screen-recorder.vala
    src/ui/about-dialog.vala
    src/ui/application-window.vala
    src/ui/preferences-dialog.vala
    src/ui/shortcut-label.vala
  PACKAGES
    gtk+-3.0
    posix
  DEFINITIONS
    ${VALA_DEFINITIONS}
  CUSTOM_VAPIS
    ${VALA_CUSTOM_VAPIS}
  GENERATE_HEADER
    application
  OPTIONS
    --target-glib=2.38
    --use-header
    --gresources=${CMAKE_SOURCE_DIR}/ui/${PROJECT_NAME}.gresource.xml
)

# Compile C code
add_definitions(-DGETTEXT_PACKAGE="${PROJECT_NAME}")
add_definitions(-DLOCALEDIR="${LOCALEDIR}")
add_definitions(-DVERSION="${PEEK_VERSION_MAJOR}.${PEEK_VERSION_MINOR}.${PEEK_VERSION_PATCH}")
add_definitions(-Wno-deprecated-declarations)
add_definitions(-Wno-incompatible-pointer-types)
add_definitions(-Wformat)
add_definitions(-Wformat-security)
add_executable(${PROJECT_NAME} ${VALA_C} ${GLIB_RESOURCES})

# Installation
install(TARGETS ${PROJECT_NAME} DESTINATION ${CMAKE_INSTALL_BINDIR})

add_subdirectory(data)
add_subdirectory(po)

if(BUILD_TESTS)
  add_subdirectory(tests)
else()
  add_subdirectory(tests EXCLUDE_FROM_ALL)
endif()

# Uninstall target
configure_file(
  "${CMAKE_CURRENT_SOURCE_DIR}/cmake_uninstall.cmake.in"
  "${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake"
  IMMEDIATE @ONLY)

add_custom_target(uninstall
  COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake)

# CPack configuration
set(CPACK_GENERATOR "DEB")
set(CPACK_PROJECT_CONFIG_FILE ${CMAKE_SOURCE_DIR}/package.txt)
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "Simple screen recorder with an easy to use interface")
set(CPACK_PACKAGE_VENDOR "")
set(CPACK_PACKAGE_CONTACT "Philipp Wolfer <ph.wolfer@gmail.com>")
set(CPACK_PACKAGE_DESCRIPTION_FILE "${CMAKE_CURRENT_SOURCE_DIR}/README.md")
set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/LICENSE")
set(CPACK_PACKAGE_VERSION_MAJOR ${PEEK_VERSION_MAJOR})
set(CPACK_PACKAGE_VERSION_MINOR ${PEEK_VERSION_MINOR})
set(CPACK_PACKAGE_VERSION_PATCH ${PEEK_VERSION_PATCH})
set(CPACK_PACKAGE_INSTALL_DIRECTORY "Peek")

set(CPACK_DEBIAN_PACKAGE_DEPENDS "libgtk-3-0 (>= ${REQUIRE_GTK}), libglib2.0-0 (>= 2.38), libkeybinder-3.0-0, ffmpeg")
set(CPACK_DEBIAN_PACKAGE_RECOMMENDS "gstreamer1.0-plugins-good, gstreamer1.0-plugins-ugly")
set(CPACK_DEBIAN_PACKAGE_SUGGESTS "gifski")
set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE "amd64")
set(CPACK_DEBIAN_PACKAGE_SECTION "video")

include(CPack)
