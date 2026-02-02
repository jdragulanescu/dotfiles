#!/bin/bash
set -e

echo "=== Dotfiles Bootstrap ==="
echo ""

# Detect OS
OS="$(uname -s)"
echo "Detected OS: $OS"
echo ""

# ============================================
# PACKAGE INSTALLATION
# ============================================

install_ubuntu_packages() {
    echo "[1/7] Installing packages via apt..."
    sudo apt update
    sudo apt install -y \
        zsh \
        git \
        curl \
        wget \
        stow \
        fzf \
        bat \
        fd-find \
        ripgrep \
        jq \
        htop \
        neovim \
        tmux \
        gnupg \
        zsh-autosuggestions \
        zsh-syntax-highlighting \
        lsof \
        unzip

    # Install eza (not in default Ubuntu repos)
    if ! command -v eza &> /dev/null; then
        echo "Installing eza..."
        sudo mkdir -p /etc/apt/keyrings
        wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor --yes -o /etc/apt/keyrings/gierens.gpg
        echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
        sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
        sudo apt update
        sudo apt install -y eza
    fi

    # Install zoxide (not in older Ubuntu repos)
    if ! command -v zoxide &> /dev/null; then
        echo "Installing zoxide..."
        curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
    fi

    # Install starship
    if ! command -v starship &> /dev/null; then
        echo "Installing starship..."
        curl -sS https://starship.rs/install.sh | sh -s -- -y
    fi

    # Create symlinks for differently-named binaries on Debian/Ubuntu
    mkdir -p ~/.local/bin
    # fd is installed as fdfind on Ubuntu
    if [ -f /usr/bin/fdfind ]; then
        ln -sf /usr/bin/fdfind ~/.local/bin/fd
    fi
    # bat is installed as batcat on Ubuntu
    if [ -f /usr/bin/batcat ]; then
        ln -sf /usr/bin/batcat ~/.local/bin/bat
    fi

    # Install JetBrains Mono Nerd Font
    install_nerd_font
}

install_nerd_font() {
    local font_dir="$HOME/.local/share/fonts"
    if [ -f "$font_dir/JetBrainsMonoNerdFont-Regular.ttf" ]; then
        echo "JetBrains Mono Nerd Font already installed"
        return
    fi

    echo "Installing JetBrains Mono Nerd Font..."
    mkdir -p "$font_dir"
    local tmp_zip="/tmp/JetBrainsMono.zip"
    curl -fLo "$tmp_zip" https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/JetBrainsMono.zip
    unzip -o "$tmp_zip" -d "$font_dir/"
    rm -f "$tmp_zip"

    # Rebuild font cache
    if command -v fc-cache &> /dev/null; then
        fc-cache -fv "$font_dir/"
    fi
    echo "JetBrains Mono Nerd Font installed"
}

install_macos_packages() {
    # Install Homebrew if not present
    if ! command -v brew &> /dev/null; then
        echo "[1/7] Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # Add brew to path for Apple Silicon
        if [[ $(uname -m) == "arm64" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    else
        echo "[1/7] Homebrew already installed"
    fi

    # Install all brew packages
    echo "[1/7] Installing brew packages..."
    brew bundle --file=~/dotfiles/homebrew/Brewfile

    # Install JetBrains Mono Nerd Font via Homebrew
    echo "Installing JetBrains Mono Nerd Font..."
    brew install --cask font-jetbrains-mono-nerd-font 2>/dev/null || true
}

case "$OS" in
    Darwin)
        install_macos_packages
        ;;
    Linux)
        if [ -f /etc/debian_version ]; then
            install_ubuntu_packages
        else
            echo "Warning: Non-Debian Linux detected. Please install packages manually."
            echo "Required: zsh git stow fzf bat eza fd-find ripgrep zoxide starship"
        fi
        ;;
    *)
        echo "Unsupported OS: $OS"
        exit 1
        ;;
esac

# ============================================
# DOTFILES SETUP
# ============================================

# Clone dotfiles if not present
if [ ! -d "$HOME/dotfiles" ]; then
    echo "[2/7] Cloning dotfiles..."
    git clone https://github.com/jdragulanescu/dotfiles.git ~/dotfiles
else
    echo "[2/7] Dotfiles already cloned"
fi

# Install fzf-tab (not in package managers)
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
[ -f ~/.tmux.conf ] && [ ! -L ~/.tmux.conf ] && mv ~/.tmux.conf ~/.tmux.conf.backup 2>/dev/null || true
[ -f ~/.ssh/config ] && [ ! -L ~/.ssh/config ] && mv ~/.ssh/config ~/.ssh/config.backup 2>/dev/null || true

# Create directory structures for packages that need file-level symlinks
# (So data/cache files don't end up in dotfiles)
echo "[6/7] Creating directory structures..."

# Cursor - create dirs so only config files get symlinked
mkdir -p ~/.cursor/{commands,hooks,skills-cursor}

# Claude - create dirs so only config files get symlinked
mkdir -p ~/.claude/{agents,commands,scripts,skills}

# Remove existing directories if they exist (for folder symlinks)
rm -rf ~/docker ~/scripts 2>/dev/null || true

# Stow all packages
echo "[7/7] Stowing dotfiles..."
builtin cd ~/dotfiles

# Basic config files
stow zsh git starship ssh tmux

# Packages with existing files (use --adopt)
stow --adopt claude 2>/dev/null || stow claude
stow --adopt cursor 2>/dev/null || stow cursor

# Directory-based packages (symlinked as entire directories)
stow docker scripts

# Create additional directories for organization
mkdir -p ~/archives/{machine,projects,legacy}
mkdir -p ~/development/{personal,clients}

# Set zsh as default shell if not already
if [ "$SHELL" != "$(which zsh)" ]; then
    echo ""
    echo "Setting zsh as default shell..."
    ZSH_PATH="$(which zsh)"

    # Try chsh first (works on standard systems)
    if chsh -s "$ZSH_PATH" 2>/dev/null; then
        echo "Shell changed via chsh"
    else
        # Fallback: add exec zsh to bashrc (works in containers, cloud envs, LDAP, etc.)
        if [ -f ~/.bashrc ] && ! grep -q "exec zsh" ~/.bashrc; then
            echo "" >> ~/.bashrc
            echo "# Launch zsh (chsh not available in this environment)" >> ~/.bashrc
            echo "[ -x \"$ZSH_PATH\" ] && exec $ZSH_PATH" >> ~/.bashrc
            echo "Shell changed via bashrc fallback"
        fi
    fi
fi

# ============================================
# GPG SIGNING SETUP
# ============================================
if [ -f ~/.gitconfig.local ] && grep -q "signingkey" ~/.gitconfig.local; then
    echo ""
    echo "GPG signing already configured"
else
    echo ""
    echo -n "Set up GPG commit signing? [Y/n] "
    read -r SETUP_GPG
    if [ "$SETUP_GPG" != "n" ] && [ "$SETUP_GPG" != "N" ]; then
        ~/dotfiles/scripts/scripts/bin/setup-gpg-signing
    fi
fi

echo ""
echo "=== Bootstrap complete! ==="
echo ""
echo "Symlinks created:"
echo "  ~/.zshrc        → dotfiles/zsh/.zshrc"
echo "  ~/.aliases      → dotfiles/zsh/.aliases"
echo "  ~/.gitconfig    → dotfiles/git/.gitconfig"
echo "  ~/.config/starship.toml → dotfiles/starship/.config/starship.toml"
echo "  ~/.ssh/config   → dotfiles/ssh/.ssh/config"
echo "  ~/.tmux.conf    → dotfiles/tmux/.tmux.conf"
echo "  ~/.claude/*     → dotfiles/claude/.claude/*"
echo "  ~/.cursor/*     → dotfiles/cursor/.cursor/*"
echo "  ~/docker/       → dotfiles/docker/docker/"
echo "  ~/scripts/      → dotfiles/scripts/scripts/"
echo ""
echo "Next steps:"
echo "  1. Set JetBrains Mono Nerd Font in your terminal app"
echo "  2. Restart your terminal or run: source ~/.zshrc"
echo "  3. Run 'gh auth login' to authenticate with GitHub"
echo "  4. Add your GPG public key to GitHub: https://github.com/settings/gpg/new"
echo ""
