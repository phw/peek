project("peek" C)
cmake_minimum_required(VERSION 2.6)

set (PEEK_VERSION_MAJOR 0)
set (PEEK_VERSION_MINOR 8)
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
pkg_check_modules(GTK REQUIRED gtk+-3.0>=3.10)
add_definitions(${GTK_CFLAGS} ${GTK_CFLAGS_OTHER})
link_libraries(${GTK_LIBRARIES})
link_directories(${GTK_LIBRARY_DIRS})

pkg_check_modules(GLIB2 REQUIRED glib-2.0>=2.38)
pkg_check_modules(CAIRO REQUIRED cairo)
pkg_check_modules(GMODULE REQUIRED gmodule-2.0)
pkg_check_modules(GIO REQUIRED gio-2.0)

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

if (${GTK_VERSION} VERSION_EQUAL "3.14" OR ${GTK_VERSION} VERSION_GREATER "3.14")
  message(STATUS "Compiling for GTK >= 3.14")
  list(APPEND VALA_DEFINITIONS "GTK_HAS_DECORATION_LAYOUT")
  list(APPEND VALA_DEFINITIONS "GTK_HAS_POPOVER")
  list(APPEND VALA_DEFINITIONS "GTK_HAS_PREFERS_APP_MENU")
elseif (${GTK_VERSION} VERSION_EQUAL "3.12" OR ${GTK_VERSION} VERSION_GREATER "3.12")
  message(STATUS "Compiling for GTK >= 3.12")
  list(APPEND VALA_DEFINITIONS "GTK_HAS_DECORATION_LAYOUT")
  list(APPEND VALA_DEFINITIONS "GTK_HAS_POPOVER")
else()
  message(STATUS "Compiling for GTK < 3.12")
endif ()

if (${GIO_VERSION} VERSION_EQUAL "2.42" OR ${GIO_VERSION} VERSION_GREATER "2.42")
  message(STATUS "Compiling for GIO >= 2.42")
  list(APPEND VALA_DEFINITIONS "GIO_HAS_MAIN_OPTION_ENTRIES")
else()
  message(STATUS "Compiling for GIO < 2.42")
endif ()

# Compile Vala to C
vala_precompile(VALA_C
    src/main.vala
    src/application.vala
    src/application-window.vala
    src/about-dialog.vala
    src/preferences-dialog.vala
    src/desktop-integration.vala
    src/recording/screen-recorder.vala
    src/recording/recording-area.vala
    src/recording/command-line-screen-recorder.vala
    #src/recording/avconv-screen-recorder.vala
    src/recording/ffmpeg-screen-recorder.vala
  PACKAGES
    gtk+-3.0
    posix
  DEFINITIONS
    ${VALA_DEFINITIONS}
  CUSTOM_VAPIS
    src/vapi/config.vapi
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
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "Peek - an animated GIF recorder")
set(CPACK_PACKAGE_VENDOR "")
set(CPACK_PACKAGE_CONTACT "Philipp Wolfer <ph.wolfer@gmail.com>")
set(CPACK_PACKAGE_DESCRIPTION_FILE "${CMAKE_CURRENT_SOURCE_DIR}/README.md")
set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/LICENSE")
set(CPACK_PACKAGE_VERSION_MAJOR ${PEEK_VERSION_MAJOR})
set(CPACK_PACKAGE_VERSION_MINOR ${PEEK_VERSION_MINOR})
set(CPACK_PACKAGE_VERSION_PATCH ${PEEK_VERSION_PATCH})
set(CPACK_PACKAGE_INSTALL_DIRECTORY "Peek")

set(CPACK_DEBIAN_PACKAGE_DEPENDS "libgtk-3-0 (>= 3.10), libglib2.0-0 (>= 2.38), ffmpeg, imagemagick")
set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE "amd64")
set(CPACK_DEBIAN_PACKAGE_SECTION "video")

include(CPack)
