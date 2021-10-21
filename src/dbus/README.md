# Generated DBus interfaces

This requires https://github.com/freesmartphone/vala-dbus-binding-tool

## org.Freedesktop.DBus
Source: `dbus-send --print-reply=literal --dest=org.freedesktop.DBus /org/freedesktop/DBus org.freedesktop.DBus.Introspectable.Introspect`

## org.freedesktop.FileManager1
Source: https://www.freedesktop.org/wiki/Specifications/file-manager-interface/

## org.gnome.Shell.Screencast.xml
Source: https://gitlab.gnome.org/GNOME/gnome-shell/tree/master/data

## org.gnome.Shell
    dbus-send --session --type=method_call --print-reply=literal  \
              --dest=org.gnome.Shell /org/gnome/Shell \
              org.freedesktop.DBus.Introspectable.Introspect > org.gnome.Shell.xml

Read more: https://blog.fpmurphy.com/2012/05/gnome-shell-3-4-dbus-interface.html#ixzz79uT1XplS
