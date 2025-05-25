#!/bin/bash

# Define the snippet to add
read -r -d '' SNIPPET <<'EOF'
if [[ -z "$XDG_CONFIG_HOME" ]]
then
        export XDG_CONFIG_HOME="$HOME/.config/"
fi

if [[ -d "$XDG_CONFIG_HOME/zsh" ]]
then
        export ZDOTDIR="$XDG_CONFIG_HOME/zsh/"
fi
EOF

ZSHENV_FILE="/etc/zsh/zshenv"

# Check if snippet is already present in /etc/zsh/zshenv
if ! grep -Fq 'export XDG_CONFIG_HOME="$HOME/.config/"' "$ZSHENV_FILE"; then
    echo "Appending snippet to $ZSHENV_FILE"
    # Use sudo tee to append if script is run as non-root
    sudo bash -c "echo -e '\n$SNIPPET' >> $ZSHENV_FILE"
else
    echo "Snippet already present in $ZSHENV_FILE, skipping append."
fi

# Run stow .
stow .
