#!/usr/bin/env bash

# Dotfiles Bootstrap Script
# This script sets up a complete Zsh environment with Oh My Zsh, Starship, eza, and custom configs
# Works on: Linux (Arch, Debian/Ubuntu), WSL, and macOS

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the dotfiles directory
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${GREEN}===================================${NC}"
echo -e "${GREEN}  Dotfiles Bootstrap Script${NC}"
echo -e "${GREEN}===================================${NC}"
echo ""

# Function to print status messages
print_status() {
    echo -e "${YELLOW}==>${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Detect OS and Package Manager
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
    if grep -qi microsoft /proc/version; then
        OS="wsl"
    fi
    
    # Detect package manager
    if command -v pacman &> /dev/null; then
        PKG_MANAGER="pacman"
        print_status "Detected package manager: pacman (Arch Linux)"
    elif command -v apt-get &> /dev/null; then
        PKG_MANAGER="apt"
        print_status "Detected package manager: apt (Debian/Ubuntu)"
    else
        print_error "No supported package manager found (pacman or apt-get)"
        exit 1
    fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="mac"
    PKG_MANAGER="brew"
    print_status "Detected package manager: brew (macOS)"
else
    print_error "Unsupported OS: $OSTYPE"
    exit 1
fi

print_status "Detected OS: $OS"

# Package installation wrapper
install_package() {
    local package=$1
    
    if [[ "$PKG_MANAGER" == "pacman" ]]; then
        sudo pacman -Sy --noconfirm $package
    elif [[ "$PKG_MANAGER" == "apt" ]]; then
        sudo apt-get update -qq
        sudo apt-get install -y $package
    elif [[ "$PKG_MANAGER" == "brew" ]]; then
        brew install $package
    fi
}

# Install Zsh if not already installed
if ! command -v zsh &> /dev/null; then
    print_status "Installing Zsh..."
    install_package zsh
    print_success "Zsh installed"
else
    print_success "Zsh already installed"
fi

# Install tmux if not already installed
if ! command -v tmux &> /dev/null; then
    print_status "Installing tmux..."
    install_package tmux
    print_success "tmux installed"
else
    print_success "tmux already installed"
fi

# Install Neovim if not already installed
if ! command -v nvim &> /dev/null; then
    print_status "Installing Neovim..."
    if [[ "$PKG_MANAGER" == "pacman" ]]; then
        install_package neovim
    elif [[ "$PKG_MANAGER" == "apt" ]]; then
        install_package neovim
    elif [[ "$PKG_MANAGER" == "brew" ]]; then
        install_package neovim
    fi
    print_success "Neovim installed"
else
    print_success "Neovim already installed"
fi

# Install Oh My Zsh if not already installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    print_status "Installing Oh My Zsh..."
    RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    print_success "Oh My Zsh installed"
else
    print_success "Oh My Zsh already installed"
fi

# Install Starship Prompt
if ! command -v starship &> /dev/null; then
    print_status "Installing Starship Prompt..."
    mkdir -p "$HOME/.local/bin"
    curl -sS https://starship.rs/install.sh | sh -s -- --bin-dir "$HOME/.local/bin" -y

    # Ensure .local/bin is in PATH
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        export PATH="$HOME/.local/bin:$PATH"
    fi
    print_success "Starship Prompt installed"
else
    print_success "Starship already installed ($(starship --version))"
fi

# Create Starship config if it doesn't exist
STARSHIP_CONFIG="$HOME/.config/starship.toml"
if [ ! -f "$STARSHIP_CONFIG" ]; then
    print_status "Creating default Starship configuration..."
    mkdir -p "$HOME/.config"
    cat > "$STARSHIP_CONFIG" << 'STARSHIP_EOF'
# Starship Configuration
# See https://starship.rs/config/

format = """
[┌──](#9ece6a)$os$username$hostname$directory$git_branch$git_status
[└─>](#9ece6a) """

add_newline = true

[os]
disabled = false

[username]
show_always = true
format = "[$user]($style)@"

[hostname]
ssh_only = false
format = "[$hostname]($style) "

[directory]
truncation_length = 3

[git_branch]
symbol = " "

[git_status]
format = '([\[$all_status$ahead_behind\]]($style) )'
STARSHIP_EOF
    print_success "Starship config created"
else
    print_success "Starship config already exists"
fi

# Install zsh-autosuggestions plugin
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
    print_status "Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
    print_success "zsh-autosuggestions installed"
else
    print_success "zsh-autosuggestions already installed"
fi

# Install zsh-syntax-highlighting plugin
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]; then
    print_status "Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
    print_success "zsh-syntax-highlighting installed"
else
    print_success "zsh-syntax-highlighting already installed"
fi

# Install eza (modern ls replacement)
if ! command -v eza &> /dev/null; then
    print_status "Installing eza..."
    if [[ "$PKG_MANAGER" == "pacman" ]]; then
        install_package eza
    elif [[ "$PKG_MANAGER" == "apt" ]]; then
        # Install eza on Debian/Ubuntu
        sudo mkdir -p /etc/apt/keyrings
        wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
        echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
        sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
        sudo apt-get update
        sudo apt-get install -y eza
    elif [[ "$PKG_MANAGER" == "brew" ]]; then
        brew install eza
    fi
    print_success "eza installed"
else
    print_success "eza already installed"
fi

# Install GitHub CLI (gh)
if ! command -v gh &> /dev/null; then
    print_status "Installing GitHub CLI..."
    if [[ "$PKG_MANAGER" == "pacman" ]]; then
        install_package github-cli
    elif [[ "$PKG_MANAGER" == "apt" ]]; then
        # Install GitHub CLI on Debian/Ubuntu
        sudo mkdir -p -m 755 /etc/apt/keyrings
        wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null
        sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
        sudo apt-get update
        sudo apt-get install -y gh
    elif [[ "$PKG_MANAGER" == "brew" ]]; then
        brew install gh
    fi
    print_success "GitHub CLI installed"
else
    print_success "GitHub CLI already installed"
fi

# Install Nerd Fonts
print_status "Installing Nerd Fonts for proper icon display..."
FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"

if [ ! -f "$FONT_DIR/MesloLGSNerdFont-Regular.ttf" ]; then
    print_status "Downloading MesloLGS Nerd Font..."

    # Install unzip if needed
    if ! command -v unzip &> /dev/null; then
        print_status "Installing unzip..."
        install_package unzip
    fi

    # Download Meslo Nerd Font (recommended for Starship)
    cd /tmp
    curl -fLo "MesloLGS.zip" https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/Meslo.zip
    unzip -o MesloLGS.zip -d "$FONT_DIR" "*.ttf"
    rm MesloLGS.zip

    # Update font cache
    if command -v fc-cache &> /dev/null; then
        fc-cache -fv "$FONT_DIR" &> /dev/null
        print_success "Nerd Fonts installed and font cache updated"
    else
        print_success "Nerd Fonts downloaded to $FONT_DIR"
    fi

    if [[ "$OS" == "wsl" ]]; then
        print_status "WSL detected - You need to configure your terminal font manually"
        echo "           Set your terminal font to a Nerd Font (e.g., 'MesloLGS Nerd Font')"
        echo "           In Windows Terminal: Settings > Profiles > Defaults > Appearance > Font face"
    elif [[ "$OS" == "mac" ]]; then
        print_status "macOS detected - Configure your terminal to use a Nerd Font"
        echo "           In iTerm2: Preferences > Profiles > Text > Font"
        echo "           In Terminal.app: Preferences > Profiles > Text > Font"
    else
        print_status "Configure your terminal emulator to use a Nerd Font for best results"
    fi
else
    print_success "Nerd Fonts already installed"
fi

# Backup existing dotfiles
backup_file() {
    local file=$1
    if [ -f "$HOME/$file" ] && [ ! -L "$HOME/$file" ]; then
        print_status "Backing up existing $file to $file.backup"
        mv "$HOME/$file" "$HOME/$file.backup"
    fi
}

# Create symlinks
create_symlink() {
    local source=$1
    local target=$2

    if [ -L "$target" ]; then
        rm "$target"
    fi

    ln -sf "$source" "$target"
    print_success "Symlinked $source -> $target"
}

# Backup and symlink dotfiles
print_status "Creating symlinks for dotfiles..."
backup_file ".zshrc"
backup_file ".zsh_aliases"
backup_file ".tmux.conf"

create_symlink "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
create_symlink "$DOTFILES_DIR/.zsh_aliases" "$HOME/.zsh_aliases"
create_symlink "$DOTFILES_DIR/.tmux.conf" "$HOME/.tmux.conf"

# Change default shell to Zsh
if [ "$SHELL" != "$(which zsh)" ]; then
    print_status "Changing default shell to Zsh..."
    chsh -s "$(which zsh)"
    print_success "Default shell changed to Zsh (restart your terminal)"
else
    print_success "Zsh is already the default shell"
fi

echo ""
echo -e "${GREEN}===================================${NC}"
echo -e "${GREEN}  Installation Complete!${NC}"
echo -e "${GREEN}===================================${NC}"
echo ""
echo "Next steps:"
echo "  1. Configure your terminal to use a Nerd Font (e.g., 'MesloLGS Nerd Font') for proper icons"
echo "  2. Restart your terminal or run: exec zsh"
echo "  3. Your old dotfiles are backed up with .backup extension"
echo "  4. Customize your aliases in ~/.zsh_aliases"
echo "  5. Customize Starship prompt in ~/.config/starship.toml"
echo ""
