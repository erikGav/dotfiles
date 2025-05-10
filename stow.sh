#!/bin/bash

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Check if stow is installed, install it if not
if ! command_exists stow; then
  echo "⚠️ GNU Stow is not installed. Attempting to install it..."

  # Check which package manager is available
  if command_exists apt-get; then
    sudo apt-get update && sudo apt-get install -y stow
  elif command_exists dnf; then
    sudo dnf install -y stow
  elif command_exists yum; then
    sudo yum install -y stow
  elif command_exists pacman; then
    sudo pacman -Sy stow --noconfirm
  elif command_exists zypper; then
    sudo zypper install -y stow
  elif command_exists brew; then
    brew install stow
  else
    echo "❌ Error: Could not install stow. No supported package manager found."
    echo "Please install GNU Stow manually and run this script again."
    exit 1
  fi

  # Verify installation was successful
  if ! command_exists stow; then
    echo "❌ Error: Failed to install GNU Stow. Please install it manually."
    exit 1
  fi

  echo "✅ GNU Stow has been installed successfully."
fi

echo "Stowing all subdirectories in $(pwd)..."
echo "Ignoring: packages/"

for dir in */; do
  # Skip non-directories and the 'packages/' folder
  [ -d "$dir" ] || continue
  [ "$dir" = "packages/" ] && continue

  echo "→ Stowing: $dir"
  stow "$dir"
done

source ~/.zshrc
echo "✅ Done."
