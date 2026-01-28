# Dotfiles

Personal dotfiles managed with GNU Stow.

## Quick Start

```bash
# Clone
git clone https://github.com/skylightxo/dotfiles.git ~/dotfiles

# Run bootstrap script
~/dotfiles/scripts/scripts/install/bootstrap.sh
```

## Manual Installation

```bash
# Install brew packages
brew bundle --file=~/dotfiles/homebrew/Brewfile

# Install fzf-tab
git clone https://github.com/Aloxaf/fzf-tab ~/.zsh/fzf-tab

# Create directory structures for cursor (needs file-level symlinks to prevent data files in repo)
mkdir -p ~/.cursor/{commands,hooks,skills-cursor}

# Stow packages
cd ~/dotfiles
stow zsh git starship ssh
stow --adopt claude cursor  # Use --adopt if files already exist
stow docker scripts prompts  # These symlink as entire directories
```

## Structure

```
~/dotfiles/
├── zsh/                    # Shell config
│   ├── .zshrc              # → ~/.zshrc
│   └── .aliases            # → ~/.aliases
├── git/
│   └── .gitconfig          # → ~/.gitconfig
├── starship/
│   └── .config/starship.toml  # → ~/.config/starship.toml
├── ssh/
│   └── .ssh/config         # → ~/.ssh/config
├── claude/                 # Claude Code config
│   └── .claude/
│       ├── CLAUDE.md       # → ~/.claude/CLAUDE.md
│       ├── settings.json   # → ~/.claude/settings.json
│       ├── agents/         # → ~/.claude/agents (directory symlink)
│       ├── commands/       # → ~/.claude/commands (directory symlink)
│       ├── hooks/          # → ~/.claude/hooks (directory symlink)
│       ├── scripts/        # → ~/.claude/scripts (directory symlink)
│       ├── skills/         # → ~/.claude/skills (directory symlink)
│       └── sky/            # → ~/.claude/sky (SKY workflow resources)
├── cursor/                 # Cursor editor config
│   └── .cursor/
│       ├── argv.json       # → ~/.cursor/argv.json
│       ├── cli-config.json # → ~/.cursor/cli-config.json
│       ├── hooks.json      # → ~/.cursor/hooks.json
│       ├── mcp.json        # → ~/.cursor/mcp.json
│       ├── commands/       # → ~/.cursor/commands/*
│       ├── hooks/          # → ~/.cursor/hooks/*
│       └── skills-cursor/  # → ~/.cursor/skills-cursor/*
├── docker/                 # Local dev docker (compose files only)
│   └── docker/
│       ├── mongo/docker-compose.yml
│       ├── postgres/docker-compose.yml
│       └── redis/docker-compose.yml
├── scripts/                # System scripts
│   └── scripts/
│       └── install/bootstrap.sh
├── prompts/                # AI prompts
│   └── prompts/
│       ├── system/
│       ├── coding/
│       └── writing/
├── homebrew/
│   └── Brewfile            # All brew packages
└── docs/                   # Documentation
```

## How Stow Works

Stow creates symlinks from your home directory to the dotfiles repo:

| Source (dotfiles) | Target (home) |
|-------------------|---------------|
| `zsh/.zshrc` | `~/.zshrc` |
| `zsh/.aliases` | `~/.aliases` |
| `git/.gitconfig` | `~/.gitconfig` |
| `starship/.config/starship.toml` | `~/.config/starship.toml` |
| `ssh/.ssh/config` | `~/.ssh/config` |
| `claude/.claude/*` | `~/.claude/*` (subdirs are directory symlinks) |
| `cursor/.cursor/*` | `~/.cursor/*` |
| `docker/docker/` | `~/docker` (directory symlink) |
| `scripts/scripts/` | `~/scripts` (directory symlink) |
| `prompts/prompts/` | `~/prompts` (directory symlink) |

**Note:** `docker`, `scripts`, `prompts`, and `claude` subdirs (`agents/`, `commands/`, `hooks/`, `scripts/`, `skills/`, `sky/`) are symlinked as entire directories. `cursor` uses file-level symlinks (create target dirs first) to prevent data files from ending up in the repo.

## Packages

### CLI Tools
| Package | Description |
|---------|-------------|
| `gh` | GitHub CLI |
| `starship` | Cross-shell prompt |
| `stow` | Symlink manager |
| `zoxide` | Smarter cd |
| `fzf` | Fuzzy finder |
| `gitleaks` | Secret scanner |

### Zsh Plugins
| Package | Description |
|---------|-------------|
| `zsh-autosuggestions` | History-based suggestions |
| `zsh-syntax-highlighting` | Command highlighting |
| `fzf-tab` | Fuzzy tab completion |

### Modern CLI Replacements
| Package | Replaces | Description |
|---------|----------|-------------|
| `eza` | `ls` | Better ls with icons |
| `bat` | `cat` | Syntax highlighting |
| `delta` | `diff` | Better git diffs |
| `fd` | `find` | Faster find |
| `ripgrep` | `grep` | Faster grep |

## Key Bindings

| Key | Action |
|-----|--------|
| Tab | Fuzzy complete (fzf-tab) |
| Ctrl-R | Fuzzy history search |
| Ctrl-T | Fuzzy file search |
| → | Accept autosuggestion |

## Stow Commands

```bash
# Add a package
cd ~/dotfiles && stow <package>

# Remove a package
cd ~/dotfiles && stow -D <package>

# Dry run (preview)
cd ~/dotfiles && stow -n -v <package>

# Adopt existing files (use when files already exist)
cd ~/dotfiles && stow --adopt <package>
```

## Updating

```bash
# Update brew packages
brewup

# Dump current brew packages to Brewfile
brewdump

# Pull latest dotfiles
cd ~/dotfiles && git pull
```

## Post-Install

1. Set **JetBrains Mono Nerd Font** in Warp (Settings > Appearance > Font)
2. Restart terminal
3. Run `gh auth login` for GitHub CLI

## Cleanup Old Setup

After verifying the new shell works:

```bash
rm ~/.p10k.zsh
rm -rf ~/.oh-my-zsh
rm -rf ~/.cache/p10k-*
```
