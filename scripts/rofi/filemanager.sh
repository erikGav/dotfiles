#!/bin/bash

FILEMANAGER="thunar"
current="$HOME"

while true; do
    list=". (open here)\n. (open terminal here)"
    [[ "$current" != "/" ]] && list="$list\n.."
    entries=$(ls -1 --group-directories-first "$current" 2>/dev/null)
    [[ -n "$entries" ]] && list="$list\n$entries"

    choice=$(echo -e "$list" | rofi -dmenu -i -p "$current")

    [[ -z "$choice" ]] && exit 0

    if [[ "$choice" == ". (open here)" ]]; then
        $FILEMANAGER "$current" &
        exit 0
    elif [[ "$choice" == ". (open terminal here)" ]]; then
        ghostty -e bash -c "cd '$current' && exec $SHELL" &
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
        # Resolve the choice to a path and open it with its default app
        target="${current%/}/$choice"
        [[ -e "$target" ]] || target="${choice/#\~/$HOME}"
        if [[ -f "$target" ]]; then
            setsid -f xdg-open "$target" >/dev/null 2>&1
        else
            $FILEMANAGER "$current" &
        fi
        exit 0
    fi
done
