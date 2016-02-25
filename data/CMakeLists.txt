include(GSettings)

# GSettings
add_schema(gsettings/com.uploadedlobster.peek.gschema.xml)

# Desktop file and icons
install(PROGRAMS desktop/com.uploadedlobster.peek.desktop DESTINATION ${XDG_APPS_INSTALL_DIR})

install(FILES "icons/16x16/peek.png" DESTINATION share/icons/hicolor/16x16/apps)
install(FILES "icons/24x24/peek.png" DESTINATION share/icons/hicolor/24x24/apps)
install(FILES "icons/32x32/peek.png" DESTINATION share/icons/hicolor/32x32/apps)
install(FILES "icons/48x48/peek.png" DESTINATION share/icons/hicolor/48x48/apps)
install(FILES "icons/256x256/peek.png" DESTINATION share/icons/hicolor/256x256/apps)
install(FILES "icons/512x512/peek.png" DESTINATION share/icons/hicolor/512x512/apps)
