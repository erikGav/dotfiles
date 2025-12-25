#!/bin/bash

STATE_FILE="$HOME/.lock_disabled_state"

if [ -f "$STATE_FILE" ]; then
    # If currently disabled → enable it
    xset s on
    xset +dpms
    rm "$STATE_FILE"
    notify-send -t 1300 "Screen Lock" "Enabled ✅"
else
    # Disable screensaver and DPMS
    xset s off
    xset -dpms
    xset s noblank
    touch "$STATE_FILE"
    notify-send -t 1300 "Screen Lock" "Disabled ⛔"
fi
