# ============================================
# LOCALE
# ============================================
# Set UTF-8 locale if available, fallback gracefully
if locale -a 2>/dev/null | grep -q "en_US.UTF-8"; then
    export LANG="en_US.UTF-8"
    export LC_ALL="en_US.UTF-8"
elif locale -a 2>/dev/null | grep -q "en_US.utf8"; then
    export LANG="en_US.utf8"
    export LC_ALL="en_US.utf8"
elif locale -a 2>/dev/null | grep -q "C.UTF-8"; then
    export LANG="C.UTF-8"
    export LC_ALL="C.UTF-8"
fi

# ============================================
# ENVIRONMENT
# ============================================
export PATH="$HOME/scripts/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export GPG_TTY=$(tty)

# Platform detection
case "$(uname -s)" in
    Darwin)
        # macOS: Docker Desktop app
        [ -d "/Applications/Docker.app/Contents/Resources/bin" ] && \
            export PATH="/Applications/Docker.app/Contents/Resources/bin:$PATH"
        # macOS: Homebrew OpenJDK (Intel or Apple Silicon)
        [ -d "/usr/local/opt/openjdk/bin" ] && export PATH="/usr/local/opt/openjdk/bin:$PATH"
        [ -d "/opt/homebrew/opt/openjdk/bin" ] && export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
        ;;
    Linux)
        # Linux: OpenJDK via apt (usually in PATH already, but check common locations)
        [ -d "/usr/lib/jvm/default-java/bin" ] && export PATH="/usr/lib/jvm/default-java/bin:$PATH"
        # Linuxbrew
        [ -d "/home/linuxbrew/.linuxbrew" ] && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        ;;
esac

# ============================================
# HISTORY
# ============================================
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS

# ============================================
# COMPLETIONS
# ============================================
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# ============================================
# FZF-TAB (must load AFTER compinit, BEFORE autosuggestions)
# ============================================
[ -f ~/.zsh/fzf-tab/fzf-tab.plugin.zsh ] && source ~/.zsh/fzf-tab/fzf-tab.plugin.zsh

# Preview directory contents on cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'

# Preview git operations
zstyle ':fzf-tab:complete:git-(add|diff|restore):*' fzf-preview 'git diff $word | delta'
zstyle ':fzf-tab:complete:git-log:*' fzf-preview 'git log --color=always $word'
zstyle ':fzf-tab:complete:git-checkout:*' fzf-preview 'git log --color=always $word'

# Switch groups with < and >
zstyle ':fzf-tab:*' switch-group '<' '>'

# ============================================
# PLUGINS (sourced directly, no framework)
# ============================================
# Determine plugin paths based on platform
_load_plugin() {
    local plugin_name="$1"
    local plugin_file="$2"

    # Try Homebrew paths first (works on both macOS and Linux with brew)
    if command -v brew &>/dev/null; then
        local brew_prefix="$(brew --prefix)"
        [ -f "$brew_prefix/share/$plugin_name/$plugin_file" ] && \
            source "$brew_prefix/share/$plugin_name/$plugin_file" && return
        [ -f "$brew_prefix/opt/$plugin_name/share/$plugin_name/$plugin_file" ] && \
            source "$brew_prefix/opt/$plugin_name/share/$plugin_name/$plugin_file" && return
    fi

    # Ubuntu/Debian system paths
    [ -f "/usr/share/$plugin_name/$plugin_file" ] && \
        source "/usr/share/$plugin_name/$plugin_file" && return
    [ -f "/usr/share/zsh/plugins/$plugin_name/$plugin_file" ] && \
        source "/usr/share/zsh/plugins/$plugin_name/$plugin_file" && return
}

# zsh-autosuggestions
_load_plugin "zsh-autosuggestions" "zsh-autosuggestions.zsh"

# zsh-syntax-highlighting
_load_plugin "zsh-syntax-highlighting" "zsh-syntax-highlighting.zsh"

# fzf keybindings (Ctrl-R for history, Ctrl-T for files)
_load_fzf() {
    local loaded=0
    # Homebrew paths (macOS or Linuxbrew)
    if command -v brew &>/dev/null; then
        local brew_prefix="$(brew --prefix)"
        [ -f "$brew_prefix/opt/fzf/shell/key-bindings.zsh" ] && source "$brew_prefix/opt/fzf/shell/key-bindings.zsh" && loaded=1
        [ -f "$brew_prefix/opt/fzf/shell/completion.zsh" ] && source "$brew_prefix/opt/fzf/shell/completion.zsh"
    fi
    # Ubuntu/Debian system paths (try these if brew didn't load fzf)
    if [ $loaded -eq 0 ]; then
        [ -f "/usr/share/doc/fzf/examples/key-bindings.zsh" ] && source "/usr/share/doc/fzf/examples/key-bindings.zsh"
        [ -f "/usr/share/doc/fzf/examples/completion.zsh" ] && source "/usr/share/doc/fzf/examples/completion.zsh"
        # Alternative location on some systems
        [ -f "/usr/share/fzf/key-bindings.zsh" ] && source "/usr/share/fzf/key-bindings.zsh"
        [ -f "/usr/share/fzf/completion.zsh" ] && source "/usr/share/fzf/completion.zsh"
    fi
}
_load_fzf

# ============================================
# VERSION MANAGERS
# ============================================
# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Pyenv
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null && export PATH="$PYENV_ROOT/bin:$PATH"
command -v pyenv >/dev/null && eval "$(pyenv init -)"

# Deno
[ -f "$HOME/.deno/env" ] && . "$HOME/.deno/env"

# ============================================
# TOOLS
# ============================================
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"

# iTerm2 integration (macOS only)
[[ "$(uname -s)" == "Darwin" ]] && [ -f "${HOME}/.iterm2_shell_integration.zsh" ] && \
  source "${HOME}/.iterm2_shell_integration.zsh"

# ============================================
# ALIASES
# ============================================
[ -f ~/.aliases ] && source ~/.aliases
