#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARENT_DIR="$(dirname "$SCRIPT_DIR")"
DCONF_DIR="$PARENT_DIR/dconf"

for dconf_file in "$DCONF_DIR"/*.dconf; do
    [ -e "$dconf_file" ] || continue

    echo "Processing $dconf_file"

    # Extract the first non-empty, non-comment line that starts with #
    schema=$(grep -m1 '^# *\/' "$dconf_file" | sed 's/^# *//')

    if [[ -z "$schema" ]]; then
        echo "❌ No schema found in $dconf_file (expected first line to be '# /some/schema/')"
        continue
    fi

    echo "✅ Importing $dconf_file into schema $schema"
    # Strip the comment line before passing to dconf
    tail -n +2 "$dconf_file" | dconf load "$schema"
done
