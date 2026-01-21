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
    echo "Snippet not found in $ZSHENV_FILE, appending..."

    if [ -w "$ZSHENV_FILE" ]; then
        # Append directly
        cat >>"$ZSHENV_FILE" <<EOF

$SNIPPET
EOF
        echo "Appended snippet without sudo."

    elif sudo test -w "$ZSHENV_FILE"; then
        # Append using sudo
        sudo bash -c "cat >> '$ZSHENV_FILE' <<'EOL'

$SNIPPET
EOL
"
        echo "Appended snippet using sudo."

    else
        echo "Cannot write to $ZSHENV_FILE, and sudo is not permitted. Exiting."
        exit 1
    fi
else
    echo "Snippet already present in $ZSHENV_FILE, skipping append."
fi
