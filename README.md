# Dotfiles

Personal configuration files for tmux and neovim.

## Contents

- **tmux/** - tmux terminal multiplexer configuration
- **nvim/** - Neovim text editor configuration with LSP, Telescope, and more

## Quick Start

### Installation

Clone this repository and run the install script:

```bash
git clone https://github.com/drego05/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

The install script will:
1. Backup your existing configs to `~/.dotfiles_backup_TIMESTAMP/`
2. Create symlinks from your home directory to this repo
3. Preserve your ability to version control your configs

### Manual Installation

If you prefer to manually create symlinks:

```bash
# tmux
ln -s ~/dotfiles/tmux/.tmux.conf ~/.tmux.conf

# neovim
ln -s ~/dotfiles/nvim ~/.config/nvim
```

## Post-Installation

### tmux
If tmux is already running, reload the config:
```bash
tmux source ~/.tmux.conf
```

### Neovim
On first launch, Neovim will install plugins automatically via lazy.nvim. If needed, run:
```vim
:Lazy sync
```

## Updating

To pull the latest changes:

```bash
cd ~/dotfiles
git pull
```

Changes will be immediately reflected since your configs are symlinked.

## Making Changes

Since your actual configs are symlinked to this repo:

1. Edit your configs normally (e.g., `nvim ~/.tmux.conf`)
2. Changes are automatically made in the repo
3. Commit and push:

```bash
cd ~/dotfiles
git add .
git commit -m "Update tmux config"
git push
```

## Structure

```
dotfiles/
├── install.sh          # Automated installation script
├── README.md           # This file
├── tmux/
│   └── .tmux.conf      # tmux configuration
└── nvim/               # Neovim configuration
    ├── init.lua        # Main config file
    └── lua/
        └── plugins/    # Plugin configurations
```

## Requirements

- tmux
- Neovim >= 0.9.0
- Git

## License

Personal use only.
