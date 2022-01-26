#!/bin/sh

WORKDIR=$(dirname "$0")
cd "${WORKDIR}"

vala-dbus-binding-tool --api-path=./org.gnome.Shell.Screencast.xml --directory=./ --strip-namespace=org --rename-namespace=gnome:Gnome --rename-namespace=Shell:ShellNS --no-synced
mv gnome-shellns.vala gnome-shell-screencast.vala

vala-dbus-binding-tool --api-path=./org.gnome.Shell.xml --directory=./ --strip-namespace=org --rename-namespace=gnome:Gnome --no-synced
mv gnome.vala gnome-shell.vala

vala-dbus-binding-tool --api-path=./org.freedesktop.FileManager1.xml --directory=./ --strip-namespace=org --rename-namespace=freedesktop:Freedesktop --no-synced
mv freedesktop.vala freedesktop-filemanager.vala

vala-dbus-binding-tool --api-path=./org.freedesktop.DBus.xml --directory=./ --strip-namespace=org --rename-namespace=freedesktop:Freedesktop --no-synced
mv freedesktop.vala freedesktop-dbus.vala
