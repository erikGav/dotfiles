#!/bin/bash
BROWSER="brave-browser"
options=" Google
 YouTube
󰃭 Calendar"

choice=$(echo -e "$options" | rofi -dmenu \
  -p "Search or open site")

[[ -z "$choice" ]] && exit 0

# Check if choice matches any of the menu options
case "$choice" in
  *Google)   exec $BROWSER "https://www.google.com" ;;
  *YouTube)  exec $BROWSER "https://www.youtube.com" ;;
  *Calendar) exec $BROWSER "https://calendar.google.com" ;;
  *)
    # Anything else is a search query
    query=$(printf '%s' "$choice" | sed 's/ /+/g')
    exec $BROWSER "https://www.google.com/search?q=$query"
    ;;
esac
