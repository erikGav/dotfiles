#!/bin/bash

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$DOTFILES_DIR/scripts"

STOW_DIRS=("config" "home" "themes" "icons")

# Use sudo only when not already root
function _sudo() {
    if [[ $EUID -eq 0 ]]; then
        "$@"
    else
        sudo "$@"
    fi
}

# Install apt packages listed in a file (one per line, blank lines ignored)
# Skips 'eza' and 'atuin' — those have dedicated install functions
function install_packages() {
    local pkg_file="$1"
    if [[ ! -f "$pkg_file" ]]; then
        echo "Package file not found: $pkg_file"
        return 1
    fi

    local packages=()
    while IFS= read -r line; do
        # strip leading/trailing whitespace
        line="${line#"${line%%[![:space:]]*}"}"
        line="${line%"${line##*[![:space:]]}"}"
        [[ -z "$line" ]] && continue
        # handled separately
        [[ "$line" == "eza" || "$line" == "atuin" ]] && continue
        packages+=("$line")
    done < "$pkg_file"

    echo "Updating apt..."
    _sudo apt-get update -qq
    # Install packages individually so one missing package doesn't abort the rest
    local failed=()
    for pkg in "${packages[@]}"; do
        if ! _sudo apt-get install -y "$pkg" -qq 2>/dev/null; then
            echo "  Warning: could not install '$pkg' via apt"
            failed+=("$pkg")
        fi
    done
    if [[ ${#failed[@]} -gt 0 ]]; then
        echo "Packages not installed via apt (may need manual install): ${failed[*]}"
    fi
}

# Install eza from deb.gierens.de (not in standard Ubuntu repos)
function install_eza() {
    if command -v eza &>/dev/null; then
        echo "eza already installed, skipping..."
        return 0
    fi
    echo "Installing eza..."
    _sudo apt-get install -y gpg wget -qq
    _sudo mkdir -p /etc/apt/keyrings
    wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc \
        | _sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" \
        | _sudo tee /etc/apt/sources.list.d/gierens.list
    _sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
    _sudo apt-get update -qq
    _sudo apt-get install -y eza || {
        echo "Error installing eza"
        return 1
    }
}

# Install atuin non-interactively via its official installer
function install_atuin() {
    if command -v atuin &>/dev/null; then
        echo "atuin already installed, skipping..."
        return 0
    fi
    echo "Installing atuin..."
    curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh -s -- --non-interactive || {
        echo "Error installing atuin"
        return 1
    }
}

# Install Oh My Zsh unattended (no shell change, no interactive prompt)
function install_omz() {
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        echo "Oh My Zsh already installed, skipping..."
        return 0
    fi
    echo "Installing Oh My Zsh..."
    RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || {
        echo "Error installing Oh My Zsh"
        return 1
    }
}

# Install Powerlevel10k as an Oh My Zsh custom theme
function install_p10k() {
    local p10k_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
    if [[ -d "$p10k_dir" ]]; then
        echo "Powerlevel10k already installed, skipping..."
        return 0
    fi
    echo "Installing Powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$p10k_dir" || {
        echo "Error installing Powerlevel10k"
        return 1
    }
}

# Install zsh-syntax-highlighting into ~/.config/zsh-syntax-highlighting/
function install_zsh_syntax_highlighting() {
    local dest="$HOME/.config/zsh-syntax-highlighting"
    if [[ -d "$dest" ]]; then
        echo "zsh-syntax-highlighting already installed, skipping..."
        return 0
    fi
    echo "Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$dest" || {
        echo "Error installing zsh-syntax-highlighting"
        return 1
    }
}

function set_default_shell() {
    local zsh_path
    zsh_path="$(which zsh)"
    if [[ "$SHELL" == "$zsh_path" ]]; then
        echo "zsh is already the default shell, skipping..."
        return 0
    fi
    echo "Setting zsh as default shell..."
    _sudo chsh -s "$zsh_path" "$USER" || {
        echo "Error changing default shell"
        return 1
    }
}

# Adds ZDOTDIR export to /etc/zsh/zshenv so zsh reads config from ~/.config/zsh/
function run_zshenv_setup() {
    echo "Configuring /etc/zsh/zshenv..."
    bash "$SCRIPTS_DIR/misc/zshenv-setup.sh" || {
        echo "Error running zshenv-setup"
        return 1
    }
}

# Symlink zsh and p10k config dirs into ~/.config/
# Must run AFTER zshenv-setup so ZDOTDIR is already pointing here
function stow_zsh_configs() {
    mkdir -p "$HOME/.config"
    for pkg in zsh p10k; do
        local src="$DOTFILES_DIR/config/$pkg"
        [[ ! -d "$src" ]] && continue
        echo "Linking $pkg config..."
        ln -sfn "$src" "$HOME/.config/$pkg" || {
            echo "Error linking $pkg"
            return 1
        }
    done
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
        (cd "$dir_path" && _sudo env "PATH=$PATH" stow .) || {
            echo "Error stowing $dir_name"
            return 1
        }
    done

    echo "Stow completed successfully!"
}

function install_zsh_only() {
    echo "==> [1/9] Installing zsh packages..."
    install_packages "$DOTFILES_DIR/packages/zsh" || return 1

    echo "==> [2/9] Installing eza..."
    install_eza || return 1

    echo "==> [3/9] Installing Oh My Zsh..."
    install_omz || return 1

    echo "==> [4/9] Installing Powerlevel10k..."
    install_p10k || return 1

    echo "==> [5/9] Installing zsh-syntax-highlighting..."
    install_zsh_syntax_highlighting || return 1

    echo "==> [6/9] Installing atuin..."
    install_atuin || return 1

    # zshenv-setup must run before symlinking configs
    echo "==> [7/9] Configuring /etc/zsh/zshenv (ZDOTDIR -> ~/.config/zsh/)..."
    run_zshenv_setup || return 1

    echo "==> [8/9] Symlinking zsh configs to ~/.config/..."
    stow_zsh_configs || return 1

    echo "==> [9/9] Setting zsh as default shell..."
    set_default_shell || return 1

    echo "Zsh installation complete!"
}

function full_install() {
    echo "==> [1/9] Installing all packages..."
    install_packages "$DOTFILES_DIR/packages/full" || return 1

    echo "==> [2/9] Installing eza..."
    install_eza || return 1

    echo "==> [3/9] Installing Oh My Zsh..."
    install_omz || return 1

    echo "==> [4/9] Installing Powerlevel10k..."
    install_p10k || return 1

    echo "==> [5/9] Installing zsh-syntax-highlighting..."
    install_zsh_syntax_highlighting || return 1

    echo "==> [6/9] Installing atuin..."
    install_atuin || return 1

    echo "==> [7/9] Configuring /etc/zsh/zshenv (ZDOTDIR -> ~/.config/zsh/)..."
    run_zshenv_setup || return 1

    echo "==> [8/9] Stowing all dotfiles..."
    run_stow || return 1

    echo "==> [9/9] Setting zsh as default shell..."
    set_default_shell || return 1

    echo "Full installation complete!"
}

function print_menu() {
    echo
    echo "Choose an option:"
    echo "1) Full install"
    echo "2) Zsh only"
    echo "3) Stow ."
    echo "4) Exit"
    read -rp "Enter choice [1-4]: " choice
    echo
    case "$choice" in
    1) full_install ;;
    2) install_zsh_only ;;
    3) run_stow ;;
    4) echo "Goodbye!"; exit 0 ;;
    *) echo "Invalid option. Please enter 1-4."; exit 1 ;;
    esac
}

print_menu
exit 0
