# GSettings
include(GSettings)
add_schema(com.uploadedlobster.peek.gschema.xml)

include(FindGettext)

set (XDG_APPS_INSTALL_DIR ${CMAKE_INSTALL_DATAROOTDIR}/applications)

# Translate and install the desktop file
set (GETTEXT_REQUIRED_VERSION 0.19)
if(GETTEXT_VERSION_STRING VERSION_EQUAL GETTEXT_REQUIRED_VERSION OR GETTEXT_VERSION_STRING VERSION_GREATER GETTEXT_REQUIRED_VERSION)
  add_custom_command(
      OUTPUT com.uploadedlobster.peek.desktop
      COMMAND ${GETTEXT_MSGFMT_EXECUTABLE}
        --desktop
        --template=data/com.uploadedlobster.peek.desktop.in
        -d po
        -o ${CMAKE_BINARY_DIR}/data/com.uploadedlobster.peek.desktop
      WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    )
  add_custom_target(build-desktop-file ALL DEPENDS com.uploadedlobster.peek.desktop)
  install(
    FILES ${CMAKE_BINARY_DIR}/data/com.uploadedlobster.peek.desktop
    DESTINATION ${XDG_APPS_INSTALL_DIR})
else()
  message(WARNING "Gettext >= ${GETTEXT_REQUIRED_VERSION} required for .desktop file translation")
  install(
    FILES com.uploadedlobster.peek.desktop.in
    DESTINATION ${XDG_APPS_INSTALL_DIR}
    RENAME com.uploadedlobster.peek.desktop)
endif()

# Translate and install AppData file
set (GETTEXT_REQUIRED_VERSION 0.19.7)
if(GETTEXT_VERSION_STRING VERSION_EQUAL GETTEXT_REQUIRED_VERSION OR GETTEXT_VERSION_STRING VERSION_GREATER GETTEXT_REQUIRED_VERSION)
  add_custom_command(
      OUTPUT com.uploadedlobster.peek.appdata.xml
      COMMAND ${GETTEXT_MSGFMT_EXECUTABLE}
        --xml
        --template=data/com.uploadedlobster.peek.appdata.xml.in
        -d po
        -o ${CMAKE_BINARY_DIR}/data/com.uploadedlobster.peek.appdata.xml
      WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    )
  add_custom_target(build-appdata-file ALL DEPENDS com.uploadedlobster.peek.appdata.xml)
  install(
    FILES ${CMAKE_BINARY_DIR}/data/com.uploadedlobster.peek.appdata.xml
    DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/metainfo)
else()
  message(WARNING "Gettext >= ${GETTEXT_REQUIRED_VERSION} required for AppData file translation")
  install(
    FILES com.uploadedlobster.peek.appdata.xml.in
    DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/metainfo
  RENAME com.uploadedlobster.peek.appdata.xml)
endif()

# Install application icons
install(FILES "icons/16x16/com.uploadedlobster.peek.png" DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/icons/hicolor/16x16/apps)
install(FILES "icons/24x24/com.uploadedlobster.peek.png" DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/icons/hicolor/24x24/apps)
install(FILES "icons/32x32/com.uploadedlobster.peek.png" DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/icons/hicolor/32x32/apps)
install(FILES "icons/48x48/com.uploadedlobster.peek.png" DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/icons/hicolor/48x48/apps)
install(FILES "icons/64x64/com.uploadedlobster.peek.png" DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/icons/hicolor/64x64/apps)
install(FILES "icons/128x128/com.uploadedlobster.peek.png" DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/icons/hicolor/128x128/apps)
install(FILES "icons/256x256/com.uploadedlobster.peek.png" DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/icons/hicolor/256x256/apps)
install(FILES "icons/512x512/com.uploadedlobster.peek.png" DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/icons/hicolor/512x512/apps)

# Install DBus service
configure_file (
  com.uploadedlobster.peek.service.in
  com.uploadedlobster.peek.service
  )

install(FILES ${CMAKE_BINARY_DIR}/data/com.uploadedlobster.peek.service DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/dbus-1/services)

# Copy build data FILES
file(
  COPY com.canonical.Unity.gschema.xml
  DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/extra/
)

add_subdirectory(man)
