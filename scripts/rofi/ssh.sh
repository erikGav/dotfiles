#!/usr/bin/env bash

# Set to true to keep the terminal open after SSH session ends
KEEP_OPEN=false

TERMINAL="${TERMINAL:-ghostty}"
SSH_CONFIG="${HOME}/.ssh/config"

# Parse SSH config into "host  hostname · user" lines
entries=$(awk '
/^Host / {
    if (host != "") {
        meta = (hostname != "") ? hostname : host
        if (user != "") meta = meta " · " user
        printf "%-20s  %s\n", host, meta
    }
    host = $2; hostname = ""; user = ""
}
/^[[:space:]]+HostName / { hostname = $2 }
/^[[:space:]]+User /     { user = $2 }
END {
    if (host != "") {
        meta = (hostname != "") ? hostname : host
        if (user != "") meta = meta " · " user
        printf "%-20s  %s\n", host, meta
    }
}
' "$SSH_CONFIG")

[[ -z "$entries" ]] && exit 1

choice=$(echo "$entries" | rofi -dmenu -i -p "SSH")

[[ -z "$choice" ]] && exit 0

host=$(echo "$choice" | awk '{print $1}')

if [[ "$KEEP_OPEN" == "true" ]]; then
    exec "$TERMINAL" -e bash -c "ssh '$host'; read -p 'Press enter to close...'"
else
    exec "$TERMINAL" -e bash -c "start=\$SECONDS; ssh '$host'; dur=\$(( SECONDS - start )); (( dur < 4 )) && sleep \$(( 4 - dur ))"
fi
