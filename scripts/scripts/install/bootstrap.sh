#!/bin/bash
set -e

echo "=== Dotfiles Bootstrap ==="
echo ""

# Install Homebrew if not present
if ! command -v brew &> /dev/null; then
    echo "[1/7] Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add brew to path for Apple Silicon
    if [[ $(uname -m) == "arm64" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
else
    echo "[1/7] Homebrew already installed"
fi

# Clone dotfiles if not present
if [ ! -d "$HOME/dotfiles" ]; then
    echo "[2/7] Cloning dotfiles..."
    git clone https://github.com/skylightxo/dotfiles.git ~/dotfiles
else
    echo "[2/7] Dotfiles already cloned"
fi

# Install all brew packages
echo "[3/7] Installing brew packages..."
brew bundle --file=~/dotfiles/homebrew/Brewfile

# Install fzf-tab (not in homebrew)
if [ ! -d "$HOME/.zsh/fzf-tab" ]; then
    echo "[4/7] Installing fzf-tab..."
    mkdir -p ~/.zsh
    git clone https://github.com/Aloxaf/fzf-tab ~/.zsh/fzf-tab
else
    echo "[4/7] fzf-tab already installed"
fi

# Backup existing dotfiles
echo "[5/7] Backing up existing dotfiles..."
[ -f ~/.zshrc ] && [ ! -L ~/.zshrc ] && mv ~/.zshrc ~/.zshrc.backup 2>/dev/null || true
[ -f ~/.aliases ] && [ ! -L ~/.aliases ] && mv ~/.aliases ~/.aliases.backup 2>/dev/null || true
[ -f ~/.gitconfig ] && [ ! -L ~/.gitconfig ] && mv ~/.gitconfig ~/.gitconfig.backup 2>/dev/null || true
[ -f ~/.ssh/config ] && [ ! -L ~/.ssh/config ] && mv ~/.ssh/config ~/.ssh/config.backup 2>/dev/null || true

# Create directory structures for packages that need file-level symlinks
# (So data/cache files don't end up in dotfiles)
echo "[6/7] Creating directory structures..."

# Cursor - create dirs so only config files get symlinked
mkdir -p ~/.cursor/{commands,hooks,skills-cursor}

# Claude - create dirs so only config files get symlinked
mkdir -p ~/.claude/{agents,commands,scripts,skills}

# Remove existing directories if they exist (for folder symlinks)
rm -rf ~/docker ~/scripts ~/prompts 2>/dev/null || true

# Stow all packages
echo "[7/7] Stowing dotfiles..."
cd ~/dotfiles

# Basic config files
stow zsh git starship ssh

# Packages with existing files (use --adopt)
stow --adopt claude 2>/dev/null || stow claude
stow --adopt cursor 2>/dev/null || stow cursor

# Directory-based packages (symlinked as entire directories)
stow docker scripts prompts

# Create additional directories for organization
mkdir -p ~/archives/{machine,projects,legacy}
mkdir -p ~/development/{personal,clients}

echo ""
echo "=== Bootstrap complete! ==="
echo ""
echo "Symlinks created:"
echo "  ~/.zshrc        → dotfiles/zsh/.zshrc"
echo "  ~/.aliases      → dotfiles/zsh/.aliases"
echo "  ~/.gitconfig    → dotfiles/git/.gitconfig"
echo "  ~/.config/starship.toml → dotfiles/starship/.config/starship.toml"
echo "  ~/.ssh/config   → dotfiles/ssh/.ssh/config"
echo "  ~/.claude/*     → dotfiles/claude/.claude/*"
echo "  ~/.cursor/*     → dotfiles/cursor/.cursor/*"
echo "  ~/docker/       → dotfiles/docker/docker/"
echo "  ~/scripts/      → dotfiles/scripts/scripts/"
echo "  ~/prompts/      → dotfiles/prompts/prompts/"
echo ""
echo "Next steps:"
echo "  1. Set JetBrains Mono Nerd Font in Warp (Settings > Appearance > Font)"
echo "  2. Restart your terminal to apply changes"
echo "  3. Run 'gh auth login' to authenticate with GitHub"
echo ""
echo "Optional cleanup (after verifying new shell works):"
echo "  rm ~/.p10k.zsh"
echo "  rm -rf ~/.oh-my-zsh"
echo "  rm -rf ~/.cache/p10k-*"
echo ""
