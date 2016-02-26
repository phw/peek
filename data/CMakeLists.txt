# GSettings
include(GSettings)
add_schema(schemas/com.uploadedlobster.peek.gschema.xml)

# Translate the desktop file
include(FindGettext)
set (GETTEXT_REQUIRED_VERSION 0.19)
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

# Install application icons
install(FILES "icons/16x16/peek.png" DESTINATION share/icons/hicolor/16x16/apps)
install(FILES "icons/24x24/peek.png" DESTINATION share/icons/hicolor/24x24/apps)
install(FILES "icons/32x32/peek.png" DESTINATION share/icons/hicolor/32x32/apps)
install(FILES "icons/48x48/peek.png" DESTINATION share/icons/hicolor/48x48/apps)
install(FILES "icons/256x256/peek.png" DESTINATION share/icons/hicolor/256x256/apps)
install(FILES "icons/512x512/peek.png" DESTINATION share/icons/hicolor/512x512/apps)

# Install DBus service
install(FILES "dbus/com.uploadedlobster.peek.service" DESTINATION share/dbus-1/services)
