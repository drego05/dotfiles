#!/bin/bash

# Dotfiles Installation Script
# This script creates symlinks from your home directory to the dotfiles repo

set -e

DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

echo "Installing dotfiles from $DOTFILES_DIR"

# Function to backup and create symlink
backup_and_link() {
    local source="$1"
    local target="$2"

    # Create parent directory if it doesn't exist
    mkdir -p "$(dirname "$target")"

    # If target exists and is not a symlink, back it up
    if [ -e "$target" ] && [ ! -L "$target" ]; then
        echo "Backing up existing $target to $BACKUP_DIR"
        mkdir -p "$BACKUP_DIR"
        mv "$target" "$BACKUP_DIR/"
    fi

    # Remove existing symlink if it exists
    if [ -L "$target" ]; then
        echo "Removing existing symlink $target"
        rm "$target"
    fi

    # Create new symlink
    echo "Creating symlink: $target -> $source"
    ln -s "$source" "$target"
}

# Install tmux config
echo ""
echo "Installing tmux config..."
backup_and_link "$DOTFILES_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"

# Install neovim config
echo ""
echo "Installing neovim config..."
backup_and_link "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"

echo ""
echo "Installation complete!"
if [ -d "$BACKUP_DIR" ]; then
    echo "Your original configs were backed up to: $BACKUP_DIR"
fi
echo ""
echo "You may need to:"
echo "  - Restart tmux: tmux source ~/.tmux.conf (if running)"
echo "  - Restart neovim or run :Lazy sync (for plugin installation)"
