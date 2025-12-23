#!/bin/bash

is_gnome() {
    echo "$XDG_CURRENT_DESKTOP $DESKTOP_SESSION $GDMSESSION" | grep -qi gnome
}

if is_gnome; then
    SESSION="GNOME"
    if [ "$(gsettings get org.gnome.settings-daemon.plugins.color night-light-enabled)" = "true" ]; then
        gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled false
        notify-send -t 1300 "Night Light ($SESSION)" "Night Light turned OFF"
    else
        gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true
        notify-send -t 1300 "Night Light ($SESSION)" "Night Light turned ON"
    fi
else
    SESSION="i3"
    if pgrep -x gammastep >/dev/null; then
        pkill gammastep
        notify-send -t 1300 "Night Light ($SESSION)" "Night Light turned OFF"
    else
        # Run detached so it doesn't block the terminal
        nohup gammastep >/dev/null 2>&1 &
        notify-send -t 1300 "Night Light ($SESSION)" "Night Light turned ON"
    fi
fi

