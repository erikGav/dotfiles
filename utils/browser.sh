#!/bin/bash

BROWSER="brave-browser"

declare -A sites=(
    [" Google"]="https://www.google.com"
    [" YouTube"]="https://www.youtube.com"
    ["󰃭 Calendar"]="https://calendar.google.com"
    [" Maps"]="https://www.google.com/maps"
)

options=$(printf "%s\n" "${!sites[@]}")

choice=$(echo -e "$options" | rofi -dmenu -i \
  -p "Search or open site")

[[ -z "$choice" ]] && exit 0

# Check if choice matches any site
if [[ -v sites["$choice"] ]]; then
    exec $BROWSER "${sites[$choice]}"
elif [[ "$choice" =~ ^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}(/.*)?$ ]]; then
    exec $BROWSER "https://$choice"
else
    # No match - treat as search query
    query=$(printf '%s' "$choice" | sed 's/ /+/g')
    exec $BROWSER "https://www.google.com/search?q=$query"
fi
