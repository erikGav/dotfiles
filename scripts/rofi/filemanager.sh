#!/bin/bash

FILEMANAGER="thunar"
current="$HOME"

while true; do
    list=". (open here)"
    [[ "$current" != "/" ]] && list="$list\n.."
    entries=$(ls -1 --group-directories-first "$current" 2>/dev/null)
    [[ -n "$entries" ]] && list="$list\n$entries"

    choice=$(echo -e "$list" | rofi -dmenu -i -p "$current")

    [[ -z "$choice" ]] && exit 0

    if [[ "$choice" == ". (open here)" ]]; then
        $FILEMANAGER "$current" &
        exit 0
    elif [[ "$choice" == ".." ]]; then
        current=$(dirname "$current")
    elif [[ -d "${current%/}/$choice" ]]; then
        current="${current%/}/$choice"
    elif [[ -d "$choice" ]]; then
        current="$choice"
    elif [[ -d "${choice/#\~/$HOME}" ]]; then
        current="${choice/#\~/$HOME}"
    else
        $FILEMANAGER "$current" &
        exit 0
    fi
done
