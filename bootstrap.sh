#!/usr/bin/env bash

# Dotfiles Bootstrap Script
# This script sets up a complete Zsh environment with Oh My Zsh, Spaceship, eza, and custom configs
# Works on: Linux, WSL, and macOS

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

# Detect OS
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
    if grep -qi microsoft /proc/version; then
        OS="wsl"
    fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="mac"
else
    print_error "Unsupported OS: $OSTYPE"
    exit 1
fi

print_status "Detected OS: $OS"

# Install Zsh if not already installed
if ! command -v zsh &> /dev/null; then
    print_status "Installing Zsh..."
    if [[ "$OS" == "linux" ]] || [[ "$OS" == "wsl" ]]; then
        sudo apt-get update
        sudo apt-get install -y zsh
    elif [[ "$OS" == "mac" ]]; then
        brew install zsh
    fi
    print_success "Zsh installed"
else
    print_success "Zsh already installed"
fi

# Install tmux if not already installed
if ! command -v tmux &> /dev/null; then
    print_status "Installing tmux..."
    if [[ "$OS" == "linux" ]] || [[ "$OS" == "wsl" ]]; then
        sudo apt-get install -y tmux
    elif [[ "$OS" == "mac" ]]; then
        brew install tmux
    fi
    print_success "tmux installed"
else
    print_success "tmux already installed"
fi

# Install Neovim if not already installed
if ! command -v nvim &> /dev/null; then
    print_status "Installing Neovim..."
    if [[ "$OS" == "linux" ]] || [[ "$OS" == "wsl" ]]; then
        sudo apt-get install -y neovim
    elif [[ "$OS" == "mac" ]]; then
        brew install neovim
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

# Install Spaceship Prompt
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/spaceship-prompt" ]; then
    print_status "Installing Spaceship Prompt..."
    git clone https://github.com/spaceship-prompt/spaceship-prompt.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/spaceship-prompt" --depth=1
    ln -sf "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/spaceship-prompt/spaceship.zsh-theme" "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/spaceship.zsh-theme"
    print_success "Spaceship Prompt installed"
else
    print_success "Spaceship Prompt already installed"
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
    if [[ "$OS" == "linux" ]] || [[ "$OS" == "wsl" ]]; then
        # Install eza on Linux/WSL
        sudo mkdir -p /etc/apt/keyrings
        wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
        echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
        sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
        sudo apt-get update
        sudo apt-get install -y eza
    elif [[ "$OS" == "mac" ]]; then
        brew install eza
    fi
    print_success "eza installed"
else
    print_success "eza already installed"
fi

# Install GitHub CLI (gh)
if ! command -v gh &> /dev/null; then
    print_status "Installing GitHub CLI..."
    if [[ "$OS" == "linux" ]] || [[ "$OS" == "wsl" ]]; then
        # Install GitHub CLI on Linux/WSL
        sudo mkdir -p -m 755 /etc/apt/keyrings
        wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null
        sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
        sudo apt-get update
        sudo apt-get install -y gh
    elif [[ "$OS" == "mac" ]]; then
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

    # Download Meslo Nerd Font (recommended for Spaceship)
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
        echo "           Set your terminal font to: 'MesloLGS Nerd Font'"
        echo "           In Windows Terminal: Settings > Profiles > Defaults > Appearance > Font face"
    elif [[ "$OS" == "mac" ]]; then
        print_status "macOS detected - Configure your terminal to use 'MesloLGS Nerd Font'"
        echo "           In iTerm2: Preferences > Profiles > Text > Font"
        echo "           In Terminal.app: Preferences > Profiles > Text > Font"
    else
        print_status "Configure your terminal emulator to use 'MesloLGS Nerd Font'"
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
echo "  1. Configure your terminal to use 'MesloLGS Nerd Font' for proper icons"
echo "  2. Restart your terminal or run: exec zsh"
echo "  3. Your old dotfiles are backed up with .backup extension"
echo "  4. Customize your aliases in ~/.zsh_aliases"
echo ""
