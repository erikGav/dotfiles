#!/bin/bash

echo "Stowing all subdirectories in $(pwd)..."
echo "Ignoring: packages/"

for dir in */; do
  # Skip non-directories and the 'packages/' folder
  [ -d "$dir" ] || continue
  [ "$dir" = "packages/" ] && continue

  echo "→ Stowing: $dir"
  stow "$dir"
done

echo "✅ Done."
