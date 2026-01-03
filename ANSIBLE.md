# Ansible Deployment Guide

Deploy dotfiles to multiple machines using Ansible.

## Quick Start

### 1. Prerequisites

Install Ansible on your control machine:

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install ansible

# macOS
brew install ansible

# Verify installation
ansible --version
```

### 2. Setup Inventory

Copy the example inventory and customize it:

```bash
cp ansible-inventory.example inventory.ini
vim inventory.ini
```

Edit `inventory.ini` with your target machines:

```ini
[local]
localhost ansible_connection=local

[servers]
server1 ansible_host=192.168.1.10 ansible_user=youruser
server2 ansible_host=192.168.1.11 ansible_user=youruser
```

### 3. Run the Playbook

**Deploy to all machines**:
```bash
ansible-playbook -i inventory.ini setup-dotfiles.yml
```

**Deploy to specific group**:
```bash
ansible-playbook -i inventory.ini setup-dotfiles.yml --limit servers
```

**Deploy to single host**:
```bash
ansible-playbook -i inventory.ini setup-dotfiles.yml --limit server1
```

**With sudo password prompt**:
```bash
ansible-playbook -i inventory.ini setup-dotfiles.yml --ask-become-pass
```

**Check what would change (dry run)**:
```bash
ansible-playbook -i inventory.ini setup-dotfiles.yml --check
```

## Usage Examples

### Local Machine Only

```bash
# Simple inventory
echo "localhost ansible_connection=local" > inventory.ini

# Run playbook
ansible-playbook -i inventory.ini setup-dotfiles.yml
```

### Multiple Remote Servers

```bash
# Create inventory
cat > inventory.ini << EOF
[webservers]
web1 ansible_host=192.168.1.10
web2 ansible_host=192.168.1.11

[databases]
db1 ansible_host=192.168.1.20

[all:vars]
ansible_user=admin
EOF

# Deploy to all
ansible-playbook -i inventory.ini setup-dotfiles.yml --ask-become-pass
```

### Using SSH Keys

```bash
# Inventory with SSH key
cat > inventory.ini << EOF
[servers]
server1 ansible_host=example.com ansible_user=user ansible_ssh_private_key_file=~/.ssh/id_rsa
EOF

# Run playbook
ansible-playbook -i inventory.ini setup-dotfiles.yml
```

## What the Playbook Does

The `setup-dotfiles.yml` playbook:

1. ✅ Installs prerequisites (git, curl, wget, unzip)
2. ✅ Configures git user name and email
3. ✅ Clones dotfiles repository to `~/dotfiles`
4. ✅ Updates repository if it already exists
5. ✅ Makes bootstrap script executable
6. ✅ Runs the bootstrap script which installs:
   - Zsh
   - tmux
   - Neovim
   - Oh My Zsh
   - Spaceship Prompt
   - zsh plugins
   - eza
   - GitHub CLI
   - MesloLGS Nerd Font
7. ✅ Creates symlinks for all dotfiles
8. ✅ Sets Zsh as default shell

## Customization

### Change Git Repository

Edit the playbook variables at the top of `setup-dotfiles.yml`:

```yaml
vars:
  dotfiles_repo: "https://github.com/yourusername/dotfiles.git"
  git_user_name: "Your Name"
  git_user_email: "your.email@example.com"
```

### Run on Specific Hosts

Create host-specific variables in `inventory.ini`:

```ini
[servers]
server1 ansible_host=192.168.1.10
server2 ansible_host=192.168.1.11 dotfiles_repo=https://github.com/custom/dotfiles.git
```

### Skip Specific Tasks

Use tags (if you add them to the playbook):

```bash
ansible-playbook -i inventory.ini setup-dotfiles.yml --skip-tags "bootstrap"
```

## Testing

### Test Connection to All Hosts

```bash
ansible -i inventory.ini all -m ping
```

### Check Ansible Can Run Commands

```bash
ansible -i inventory.ini all -m shell -a "whoami"
```

### Dry Run (Check Mode)

```bash
ansible-playbook -i inventory.ini setup-dotfiles.yml --check
```

## Troubleshooting

### SSH Connection Issues

```bash
# Test SSH connection
ssh user@hostname

# Add SSH key to ssh-agent
ssh-add ~/.ssh/id_rsa

# Use verbose mode to debug
ansible-playbook -i inventory.ini setup-dotfiles.yml -vvv
```

### Permission Denied

```bash
# Use --ask-become-pass for sudo
ansible-playbook -i inventory.ini setup-dotfiles.yml --ask-become-pass

# Or specify become password in inventory
echo "ansible_become_pass=yourpassword" >> inventory.ini
```

### Repository Access Issues

If the repository is private, ensure:
1. SSH keys are set up on target machines
2. Or use personal access token in repo URL:
   ```yaml
   dotfiles_repo: "https://username:token@github.com/username/dotfiles.git"
   ```

### Bootstrap Script Fails

Check the output:
```bash
ansible-playbook -i inventory.ini setup-dotfiles.yml -v
```

Run bootstrap manually on target:
```bash
ssh user@hostname
cd ~/dotfiles
./bootstrap.sh
```

## Advanced Usage

### Run with Different SSH Port

```ini
[servers]
server1 ansible_host=example.com ansible_port=2222 ansible_user=admin
```

### Use Jump Host (Bastion)

```ini
[servers]
internal-server ansible_host=10.0.0.5 ansible_ssh_common_args='-o ProxyCommand="ssh -W %h:%p bastion@jump-host"'
```

### Parallel Execution

Run on multiple hosts in parallel:
```bash
ansible-playbook -i inventory.ini setup-dotfiles.yml --forks=10
```

### Run on WSL Targets

```ini
[wsl]
wsl-ubuntu ansible_connection=local

[wsl:vars]
ansible_shell_executable=/bin/bash
```

## Integration with Existing Ansible Setup

### Include in Existing Playbook

```yaml
---
- name: Main Infrastructure Setup
  hosts: all
  roles:
    - common
    - security

- import_playbook: dotfiles/setup-dotfiles.yml
```

### Add as Role

Move to roles directory:
```bash
mkdir -p roles/dotfiles
mv setup-dotfiles.yml roles/dotfiles/tasks/main.yml
```

## Post-Installation

After running the playbook on target machines:

1. **Configure terminal font** to `MesloLGS Nerd Font`
2. **Restart terminal** or run `exec zsh`
3. **Authenticate GitHub CLI**: `gh auth login`
4. **Start using**:
   ```bash
   tmux          # Start tmux session
   v file.txt    # Edit with neovim
   ll            # Beautiful file listing
   ```

## Files in This Directory

- `setup-dotfiles.yml` - Main Ansible playbook
- `ansible-inventory.example` - Example inventory file
- `ANSIBLE.md` - This documentation (you are here)

---

**Note**: This playbook is idempotent - safe to run multiple times. It will only make changes when needed.
