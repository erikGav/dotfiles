#!/bin/bash

UTILS_DIR="./utils"

function run_all() {
    echo "Running all utility scripts in $UTILS_DIR"
    for script in "$UTILS_DIR"/*.sh; do
        echo "Running $(basename "$script")..."
        bash "$script" || {
            echo "Error running $script"
            return 1
        }
    done
}

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
    echo "Running 'stow .'"
    stow .
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

while true; do
    echo
    echo "Choose an option:"
    echo "1) Run all utility scripts"
    echo "2) Run zshenv-setup script"
    echo "3) Run import-all-dconf script"
    echo "4) Run 'stow .'"
    echo "5) Exit"
    read -rp "Enter choice [1-5]: " choice

    case "$choice" in
    1)
        run_all && ask_stow
        ;;
    2)
        run_script "zshenv-setup" && ask_stow
        ;;
    3)
        run_script "import-all-dconf"
        ;;
    4)
        run_stow
        ;;
    5)
        echo "Goodbye!"
        exit 0
        ;;
    *)
        echo "Invalid option. Please enter 1-5."
        ;;
    esac
done
