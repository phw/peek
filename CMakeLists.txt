project("peek" C)
cmake_minimum_required(VERSION 2.6)

set (PEEK_VERSION_MAJOR 1)
set (PEEK_VERSION_MINOR 0)
set (PEEK_VERSION_PATCH 0)

set (XDG_APPS_INSTALL_DIR share/applications)
set (GettextTranslate_GMO_BINARY TRUE)
set (GettextTranslate_ALL TRUE)
set (LOCALEDIR ${CMAKE_INSTALL_PREFIX}/share/locale)

# Include macros for Vala and GLib
list(APPEND CMAKE_MODULE_PATH
  ${CMAKE_SOURCE_DIR}/cmake
)

include(CTest)
include(FindVala)
include(UseVala)
include(GResource)
include(GettextTranslate)

# Check dependencies
find_package(Vala 0.22 REQUIRED)

find_package(PkgConfig)
pkg_check_modules(GTK REQUIRED gtk+-3.0>=3.14)
pkg_check_modules(CAIRO REQUIRED cairo)
pkg_check_modules(GIO REQUIRED gio-2.0>=2.42)
pkg_check_modules(GLIB2 REQUIRED glib-2.0>=2.38)
pkg_check_modules(GMODULE REQUIRED gmodule-2.0)
pkg_check_modules(KEYBINDER REQUIRED keybinder-3.0)

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

if(${GTK_VERSION} VERSION_EQUAL "3.16" OR ${GTK_VERSION} VERSION_GREATER "3.16")
  message(STATUS "Compiling with features for GTK >= 3.16")
  list(APPEND VALA_DEFINITIONS "HAS_GTK_LABEL_XALIGN")
endif()

if(${GTK_VERSION} VERSION_EQUAL "3.20" OR ${GTK_VERSION} VERSION_GREATER "3.20")
  message(STATUS "Compiling with features for GTK >= 3.20")
  list(APPEND VALA_DEFINITIONS "HAS_GTK_FILECHOOSERNATIVE")
endif()

if(${GTK_VERSION} VERSION_EQUAL "3.22" OR ${GTK_VERSION} VERSION_GREATER "3.22")
  message(STATUS "Compiling with features for GTK >= 3.22")
  list(APPEND VALA_DEFINITIONS "HAS_GTK_SHORTCUT_LABEL")
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
    src/post-processing/imagemagick-post-processor.vala
    src/post-processing/post-processor.vala
    src/recording/screen-recorder.vala
    src/recording/base-screen-recorder.vala
    src/recording/screen-recorder-factory.vala
    src/recording/recording-area.vala
    src/recording/gnome-shell-dbus-recorder.vala
    src/recording/command-line-screen-recorder.vala
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
    src/vapi/config.vapi
    src/vapi/keybinder-3.0.vapi
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
install(TARGETS ${PROJECT_NAME} DESTINATION bin)

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
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "Simple animated GIF screen recorder with an easy to use interface")
set(CPACK_PACKAGE_VENDOR "")
set(CPACK_PACKAGE_CONTACT "Philipp Wolfer <ph.wolfer@gmail.com>")
set(CPACK_PACKAGE_DESCRIPTION_FILE "${CMAKE_CURRENT_SOURCE_DIR}/README.md")
set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/LICENSE")
set(CPACK_PACKAGE_VERSION_MAJOR ${PEEK_VERSION_MAJOR})
set(CPACK_PACKAGE_VERSION_MINOR ${PEEK_VERSION_MINOR})
set(CPACK_PACKAGE_VERSION_PATCH ${PEEK_VERSION_PATCH})
set(CPACK_PACKAGE_INSTALL_DIRECTORY "Peek")

set(CPACK_DEBIAN_PACKAGE_DEPENDS "libgtk-3-0 (>= 3.14), libglib2.0-0 (>= 2.38), libkeybinder-3.0-0, ffmpeg | libav-tools, imagemagick")
set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE "amd64")
set(CPACK_DEBIAN_PACKAGE_SECTION "video")

include(CPack)
