#!/bin/bash

# Default directory for storing package lists
PACKAGES_DIR="."
FORCE=false
DRY_RUN=false

# Function to display usage information
show_usage() {
    echo "Usage: $0 save|restore [OPTIONS]"
    echo ""
    echo "Commands:"
    echo "  save      Save lists of installed packages"
    echo "  restore   Install packages from saved lists"
    echo ""
    echo "Options:"
    echo "  -f, --force     Skip confirmation prompts when saving"
    echo "  -d, --dry-run   Show what would be installed without making changes"
    echo "  -h, --help      Show this help message"
    exit 1
}

# Function to parse command line arguments
parse_args() {
    # Store the command (first argument)
    COMMAND="$1"
    shift

    # Check if the command is valid
    if [[ "$COMMAND" != "save" && "$COMMAND" != "restore" ]]; then
        show_usage
    fi

    # Parse remaining arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -f|--force)
                FORCE=true
                shift
                ;;
            -d|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -h|--help)
                show_usage
                ;;
            -*)
                # Handle combined short options like -fd
                if [[ ${#1} -gt 2 ]]; then
                    # Extract individual options from combined flag
                    combined_flags="${1:1}"  # Remove the leading -
                    shift
                    
                    # Process each character as a separate flag
                    for (( i=0; i<${#combined_flags}; i++ )); do
                        flag="-${combined_flags:$i:1}"
                        set -- "$flag" "$@"  # Add the individual flag back to the argument list
                    done
                    continue
                else
                    echo "Unknown option: $1"
                    show_usage
                fi
                ;;
            *)
                echo "Unknown option: $1"
                show_usage
                ;;
        esac
    done
}

# Function to save package lists
save_packages() {
    echo "Saving package lists..."

    if [ "$FORCE" = true ]; then
        echo "Force flag set: Skipping overwrite confirmation."
    fi

    # Define the files to save
    local apt_file="$PACKAGES_DIR/apt-packages.txt"
    local snap_file="$PACKAGES_DIR/snap-packages.txt"
    local flatpak_file="$PACKAGES_DIR/flatpak-packages.txt"
    local files=("$apt_file" "$snap_file" "$flatpak_file")

    # Check if files already exist and prompt for overwrite (unless force is set)
    if [ "$FORCE" = false ]; then
        for file in "${files[@]}"; do
            if [ -f "$file" ]; then
                echo "$file exists. Overwrite? (y/n)"
                read -r overwrite
                if [ "$overwrite" != "y" ]; then
                    echo "Skipping $file"
                    # Remove this file from the files array
                    files=(${files[@]/$file})
                fi
            fi
        done
    fi

    # Save the package lists (only for files that weren't skipped)
    for file in "${files[@]}"; do
        case "$file" in
            "$apt_file")
                echo "Saving APT packages to $apt_file"
                apt-mark showmanual > "$apt_file"
                ;;
            "$snap_file")
                echo "Saving Snap packages to $snap_file"
                snap list | tail -n +2 | awk '{print $1}' > "$snap_file"
                ;;
            "$flatpak_file")
                echo "Saving Flatpak packages to $flatpak_file"
                flatpak list --app --columns=application > "$flatpak_file"
                ;;
        esac
    done

    echo "Package lists saved."
}

# Function to restore package lists
restore_packages() {
    echo "Restoring packages..."

    # Define the files to restore from
    local apt_file="$PACKAGES_DIR/apt-packages.txt"
    local snap_file="$PACKAGES_DIR/snap-packages.txt"
    local flatpak_file="$PACKAGES_DIR/flatpak-packages.txt"

    # Ensure files exist before restoring
    local missing_files=false
    for file in "$apt_file" "$snap_file" "$flatpak_file"; do
        if [ ! -f "$file" ]; then
            echo "Missing required file: $file"
            missing_files=true
        fi
    done

    if [ "$missing_files" = true ]; then
        echo "One or more required package files are missing."
        exit 1
    fi

    # Process based on dry run flag
    if [ "$DRY_RUN" = true ]; then
        echo "Dry run mode: No changes will be made."
        echo "The following packages would be installed:"
        
        echo "APT packages:"
        cat "$apt_file"
        
        echo "Snap packages:"
        cat "$snap_file"
        
        echo "Flatpak packages:"
        cat "$flatpak_file"
    else
        # Actually install packages
        echo "Installing APT packages..."
        # Use xargs to handle empty files or large lists
        cat "$apt_file" | xargs -r -n 1 sh -c 'apt-get install -y "$0"'
        
        echo "Installing Snap packages..."
        while read -r package || [ -n "$package" ]; do
            [ -z "$package" ] && continue
            echo "Installing snap: $package"
            sudo snap install "$package"
        done < "$snap_file"
        
        echo "Installing Flatpak packages..."
        while read -r package || [ -n "$package" ]; do
            [ -z "$package" ] && continue
            echo "Installing flatpak: $package"
            flatpak install -y "$package"
        done < "$flatpak_file"
    fi

    echo "Packages restoration complete."
}

# Main program execution
main() {
    # Need at least one argument
    if [ $# -lt 1 ]; then
        show_usage
    fi

    # Parse the command line arguments
    parse_args "$@"

    # Execute the appropriate function based on command
    case "$COMMAND" in
        save)
            save_packages
            ;;
        restore)
            restore_packages
            ;;
        *)
            show_usage
            ;;
    esac
}

# Call the main function with all arguments
main "$@"