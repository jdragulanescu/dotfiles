# ============================================
# ENVIRONMENT
# ============================================
export PATH="$HOME/scripts/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="/Applications/Docker.app/Contents/Resources/bin:$PATH"
export PATH="/usr/local/opt/openjdk/bin:$PATH"
export GPG_TTY=$(tty)

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
# zsh-autosuggestions
[ -f $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh ] && \
  source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# zsh-syntax-highlighting
[ -f $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && \
  source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# fzf keybindings (Ctrl-R for history, Ctrl-T for files)
[ -f $(brew --prefix)/opt/fzf/shell/key-bindings.zsh ] && \
  source $(brew --prefix)/opt/fzf/shell/key-bindings.zsh
[ -f $(brew --prefix)/opt/fzf/shell/completion.zsh ] && \
  source $(brew --prefix)/opt/fzf/shell/completion.zsh

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

# iTerm2 integration (optional)
[ -f "${HOME}/.iterm2_shell_integration.zsh" ] && \
  source "${HOME}/.iterm2_shell_integration.zsh"

# ============================================
# ALIASES
# ============================================
[ -f ~/.aliases ] && source ~/.aliases
