#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UTILS_DIR="$SCRIPT_DIR/utils"
DOTFILES_DIR="$SCRIPT_DIR/config"
HOME_DIR="$SCRIPT_DIR/home"

# function run_all() {
#     echo "Running all utility scripts in $UTILS_DIR"
#     for script in "$UTILS_DIR"/*.sh; do
#         echo "Running $(basename "$script")..."
#         bash "$script" || {
#             echo "Error running $script"
#             return 1
#         }
#     done
# }

function run_script() {
    local name=$1
    local script="$UTILS_DIR/$name.sh"
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

    echo "Running stow for config files..."
    (cd "$DOTFILES_DIR" && stow .) || {
        echo "Error stowing config"
        return 1
    }
    
    echo "Running stow for home files..."
    (cd "$HOME_DIR" && stow .) || {
        echo "Error stowing home"
        return 1
    }
    
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

function print_menu() {
    echo
    echo "Choose an option:"
    echo "1) Run 'stow .'"
    echo "2) Run zshenv-setup script"
    echo "3) Exit"
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
        echo "Goodbye!"
        exit 0
        ;;
    *)
        echo "Invalid option. Please enter 1-5."
        exit 1
        ;;
    esac
}

print_menu
exit 0
