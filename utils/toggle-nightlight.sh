#!/bin/bash
if [ "$(gsettings get org.gnome.settings-daemon.plugins.color night-light-enabled)" = "true" ]; then
    gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled false
    notify-send "Night Light" "Night Light turned OFF"
else
    gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true
    notify-send "Night Light" "Night Light turned ON"
fi

