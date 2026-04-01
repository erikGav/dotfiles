#!/bin/bash

BROWSER="brave-browser"

declare -A sites=(
    [" Homepage"]="https://erikghome.duckdns.org"
    [" Google"]="https://www.google.com"
    [" YouTube"]="https://www.youtube.com"
    [" Maps"]="https://www.google.com/maps"
    ["󰃭 Calendar@develeap"]="https://calendar.google.com/calendar/u/4/r"
    ["󰃭 Calendar@work"]="https://calendar.google.com/calendar/u/0/r"
    ["@ Email@personal"]="https://mail.google.com/mail/u/1/#inbox"
    ["@ Email@develeap"]="https://mail.google.com/mail/u/4/#inbox"
    ["@ Email@work"]="https://mail.google.com/mail/u/0/#inbox"
)

order=(
    " Homepage"
    " Google"
    " YouTube"
    " Maps"
    "󰃭 Calendar@develeap"
    "󰃭 Calendar@work"
    "@ Email@personal"
    "@ Email@develeap"
    "@ Email@work"
)

options=$(printf "%s\n" "${order[@]}")

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
