#!/bin/bash
lang="${1:-eng}"
img="$(mktemp --suffix=.png)"

if command -v wl-paste > /dev/null; then
    wl-paste --type image/png > "$img"
elif command -v xclip > /dev/null; then
    xclip -selection clipboard -t image/png -o > "$img"
else
    echo "No clipboard image tool found." >&2
    return 1
fi

tesseract "$img" - -l "$lang" 2> /dev/null \
    | tee /dev/tty \
    | xclip -selection clipboard

rm -f "$img"