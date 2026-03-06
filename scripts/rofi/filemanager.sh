#!/bin/bash

FILEMANAGER="thunar"

# Rofi script mode: $1 is the selected entry, ROFI_RETV is the event type
# ROFI_RETV=0: initial call, ROFI_RETV=1: entry selected, ROFI_RETV=2: custom input

# Store current directory in a temp file for state across calls
STATE_FILE="/tmp/rofi-filemanager-path"

if [[ -z "$ROFI_RETV" ]]; then
    # Called outside rofi script mode — launch rofi
    echo "$HOME" > "$STATE_FILE"
    exec rofi -show filemanager -modi "filemanager:$0"
fi

if [[ "$ROFI_RETV" -eq 0 ]]; then
    # Initial call — show starting directories
    echo "$HOME" > "$STATE_FILE"
    current="$HOME"
elif [[ "$ROFI_RETV" -eq 1 ]]; then
    # Entry selected from the list
    current=$(cat "$STATE_FILE")
    selected="$1"

    if [[ "$selected" == ".." ]]; then
        current=$(dirname "$current")
    elif [[ "$selected" == ". (open here)" ]]; then
        coproc ( $FILEMANAGER "$current" & )
        exit 0
    else
        target="${current%/}/$selected"
        if [[ -d "$target" ]]; then
            current="$target"
        else
            # Selected a file — open its parent directory
            coproc ( $FILEMANAGER "$current" & )
            exit 0
        fi
    fi
    echo "$current" > "$STATE_FILE"
elif [[ "$ROFI_RETV" -eq 2 ]]; then
    # Custom input typed by user
    typed="$1"
    typed="${typed/#\~/$HOME}"
    if [[ -d "$typed" ]]; then
        current="$typed"
        echo "$current" > "$STATE_FILE"
    else
        # Not a directory — try opening parent
        parent=$(dirname "$typed")
        if [[ -d "$parent" ]]; then
            coproc ( $FILEMANAGER "$parent" & )
        fi
        exit 0
    fi
fi

# Display prompt with current path
echo -en "\0prompt\x1f$current\n"

# Show navigation options
echo ". (open here)"
[[ "$current" != "/" ]] && echo ".."

# List directories first, then files
(ls -1 --group-directories-first "$current" 2>/dev/null)
