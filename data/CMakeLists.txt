# GSettings
include(GSettings)
add_schema(schemas/com.uploadedlobster.peek.gschema.xml)

include(FindGettext)
set (GETTEXT_REQUIRED_VERSION 0.19)

# Translate and install the desktop file
if(GETTEXT_VERSION_STRING VERSION_EQUAL GETTEXT_REQUIRED_VERSION OR GETTEXT_VERSION_STRING VERSION_GREATER GETTEXT_REQUIRED_VERSION)
  add_custom_command(
      OUTPUT com.uploadedlobster.peek.desktop
      COMMAND ${GETTEXT_MSGFMT_EXECUTABLE}
        --desktop
        --template=data/desktop/com.uploadedlobster.peek.desktop.in
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
    FILES desktop/com.uploadedlobster.peek.desktop.in
    DESTINATION ${XDG_APPS_INSTALL_DIR}
    RENAME com.uploadedlobster.peek.desktop)
endif()

# Translate and install AppData file
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
    DESTINATION share/metainfo)
else()
  message(WARNING "Gettext >= ${GETTEXT_REQUIRED_VERSION} required for .desktop file translation")
  install(
    FILES com.uploadedlobster.peek.appdata.xml.in
    DESTINATION share/metainfo
  RENAME com.uploadedlobster.peek.appdata.xml)
endif()

# Install application icons
install(FILES "icons/16x16/peek.png" DESTINATION share/icons/hicolor/16x16/apps)
install(FILES "icons/24x24/peek.png" DESTINATION share/icons/hicolor/24x24/apps)
install(FILES "icons/32x32/peek.png" DESTINATION share/icons/hicolor/32x32/apps)
install(FILES "icons/48x48/peek.png" DESTINATION share/icons/hicolor/48x48/apps)
install(FILES "icons/256x256/peek.png" DESTINATION share/icons/hicolor/256x256/apps)
install(FILES "icons/512x512/peek.png" DESTINATION share/icons/hicolor/512x512/apps)


# Install DBus service
configure_file (
  dbus/com.uploadedlobster.peek.service.in
  dbus/com.uploadedlobster.peek.service
  )

install(FILES ${CMAKE_BINARY_DIR}/data/dbus/com.uploadedlobster.peek.service DESTINATION share/dbus-1/services)
