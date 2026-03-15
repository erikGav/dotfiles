#!/bin/bash

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$DOTFILES_DIR/scripts"

# Just add directory names here - no need for additional constants
STOW_DIRS=("config" "home" "themes" "icons")

function run_script() {
    local name=$1
    local script="$SCRIPTS_DIR/misc/$name.sh"
    if [[ -f "$script" ]]; then
        echo "Running $name script..."
        bash "$script" || {
            echo "Error running $script"
            return 1
        }
    else
        echo "No such script: $name"
        return 1
    fi
}

function run_stow() {
    [[ ! -d "$HOME/.config" ]] && mkdir -p ~/.config

    for dir_name in "${STOW_DIRS[@]}"; do
        local dir_path="$DOTFILES_DIR/$dir_name"

        if [[ ! -d "$dir_path" ]]; then
            echo "Warning: Directory $dir_name not found, skipping..."
            continue
        fi

        echo "Running stow for $dir_name files..."
        (cd "$dir_path" && sudo stow .) || {
            echo "Error stowing $dir_name"
            return 1
        }
    done

    echo "Stow completed successfully!"
}

function ask_stow() {
    while true; do
        read -rp "Do you want to run 'stow .' now? (y/n): " yn
        case $yn in
        [Yy]*)
            run_stow
            break
            ;;
        [Nn]*)
            echo "Skipping 'stow .'"
            break
            ;;
        *) echo "Please answer y or n." ;;
        esac
    done
}

function install_zsh() {
    local zsh_dirs=("config/zsh" "config/p10k")

    for dir_name in "${zsh_dirs[@]}"; do
        local dir_path="$DOTFILES_DIR/$dir_name"

        if [[ ! -d "$dir_path" ]]; then
            echo "Warning: Directory $dir_name not found, skipping..."
            continue
        fi

        echo "Running stow for $dir_name files..."
        (cd "$dir_path" && sudo stow .) || {
            echo "Error stowing $dir_name"
            return 1
        }
    done

    run_script "zshenv-setup" || return 1
    echo "Zsh install completed successfully!"
}

function print_menu() {
    echo
    echo "Choose an option:"
    echo "1) Run 'stow .'"
    echo "2) Run zshenv-setup script"
    echo "3) Install zsh files only"
    echo "4) Exit"
    read -rp "Enter choice [1-4]: " choice
    echo
    case "$choice" in
    1)
        run_stow
        ;;
    2)
        run_script "zshenv-setup" && ask_stow
        ;;
    3)
        install_zsh
        ;;
    4)
        echo "Goodbye!"
        exit 0
        ;;
    *)
        echo "Invalid option. Please enter 1-4."
        exit 1
        ;;
    esac
}

print_menu
exit 0
