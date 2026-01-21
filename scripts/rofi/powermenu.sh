#!/bin/bash

options=" Lock\n Logout\n Suspend\n Reboot\n Shutdown"

choice=$(echo -e "$options" | rofi -dmenu -theme ~/.config/rofi/powermenu.rasi -p "Power")

case "$choice" in
  *Lock) i3lock -c 000000 ;;
  *Logout)  i3-msg exit ;;
  *Suspend) systemctl suspend ;;
  *Reboot) systemctl reboot ;;
  *Shutdown) systemctl poweroff ;;
esac

