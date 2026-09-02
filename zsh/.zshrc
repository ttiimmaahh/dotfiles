# Fast prompt cache; keep near the top of this file.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced

# Add a directory once, and only when it exists.
path_prepend() {
  [[ -d "$1" ]] && path=("$1" ${path:#"$1"})
}

path_prepend "$HOME/.local/bin"
path_prepend "$HOME/.bun/bin"
path_prepend "$HOME/.jenv/bin"
path_prepend "$HOME/.rokit/bin"
path_prepend "$HOME/.opencode/bin"
path_prepend "$HOME/.grok/bin"
path_prepend "$HOME/Library/pnpm"
export PATH

# History
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
setopt append_history
setopt share_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_verify

bindkey -e
bindkey "^[[A" history-search-backward
bindkey "^[[B" history-search-forward

[[ -d "$HOME/.grok/completions/zsh" ]] && fpath=("$HOME/.grok/completions/zsh" $fpath)
autoload -Uz compinit
compinit -C

# General aliases
alias c='clear'
alias e='exit'
alias ga='git add .'
alias gs='git status --short'
alias python='python3'
alias pip='python3 -m pip'
alias killDS='find . -name .DS_Store -type f -delete'

if (( $+commands[eza] )); then
  alias ls='eza --group-directories-first'
  alias ll='eza --all --long --group-directories-first --icons=auto'
else
  alias ll='ls -la'
fi

checkport() {
  if (( $# != 1 )); then
    print -u2 'Usage: checkport <port>'
    return 2
  fi
  lsof -nP -iTCP:"$1" -sTCP:LISTEN
}

# Optional tool initialization.
if (( $+commands[brew] )); then
  brew_prefix="$(brew --prefix)"
  [[ -r "$brew_prefix/opt/nvm/nvm.sh" ]] && source "$brew_prefix/opt/nvm/nvm.sh"
  [[ -r "$brew_prefix/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] && source "$brew_prefix/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

if (( $+commands[jenv] )); then
  eval "$(jenv init -)"
fi

[[ -r "$HOME/.bun/_bun" ]] && source "$HOME/.bun/_bun"
[[ -r "$HOME/.config/ghostty/project-themes.zsh" ]] && source "$HOME/.config/ghostty/project-themes.zsh"

# Powerlevel10k is the only prompt dependency. Install it with:
#   brew install powerlevel10k
if (( $+commands[brew] )); then
  p10k_theme="$(brew --prefix powerlevel10k 2>/dev/null)/share/powerlevel10k/powerlevel10k.zsh-theme"
  if [[ -r "$p10k_theme" ]]; then
    source "$p10k_theme"
    [[ -r "$HOME/.config/zsh/p10k.zsh" ]] && source "$HOME/.config/zsh/p10k.zsh"
  fi
  unset p10k_theme brew_prefix
fi

# Local-only settings belong here: credentials, work aliases, and machine paths.
[[ -r "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

# Keep syntax highlighting last among plugin initialization.
if (( $+commands[brew] )); then
  zsh_highlighting="$(brew --prefix zsh-syntax-highlighting 2>/dev/null)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
  [[ -r "$zsh_highlighting" ]] && source "$zsh_highlighting"
  unset zsh_highlighting
fi
