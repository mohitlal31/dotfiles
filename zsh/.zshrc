# Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Load Powerlevel10k
source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Vi mode
bindkey -v
KEYTIMEOUT=1  # 10ms ESC delay for snappy mode switching

# Make '^v' in normal mode open command in editor
autoload -z edit-command-line
zle -N edit-command-line
bindkey -M vicmd '^V' edit-command-line

# Completions
autoload -Uz compinit && compinit
source <(kubectl completion zsh)
compdef k=kubectl

# History
HISTFILE=~/.zsh_history
HISTSIZE=200000
SAVEHIST=200000
setopt inc_append_history
setopt hist_ignore_all_dups
setopt hist_expire_dups_first
setopt extended_history
setopt share_history

# Globbing
setopt extended_glob

# Plugins
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Tools
eval "$(jenv init -)"
eval "$(zoxide init zsh)"
eval "$(fzf --zsh)"

# make completion case-insensitive for cd and for zsh-autosuggestions ghost text suggestions.
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' menu select
ZSH_AUTOSUGGEST_CASE_INSENSITIVE=1

# Environment
export EDITOR="nvim"
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
export PATH="$HOME/.jenv/bin:$PATH"
export PATH="/opt/homebrew/opt/mysql-client@8.4/bin:$PATH"
export TMUX_THEME="gruvbox"

# Ruby
export GEM_HOME="$HOME/.gem"
export GEM_PATH="$HOME/.gem/ruby/bin"
export PATH="$GEM_PATH:$PATH"

# Aliases
alias ls="eza --icons=always"
alias ll="eza -la --icons=always --git"
alias cd="z"
alias k="kubectl"
alias qq="kiro-cli"
alias cc="claude"
alias grep="rg"
alias yp="pwd | pbcopy" # yp = yank path
yf() { realpath "$1" | pbcopy } # yf = yank file path
compdef _files yf

# Terraform aliases
alias tf="terraform"
alias tfi='terraform init'
alias tfp="terraform plan"
alias tfa="terraform apply"

# Git aliases
alias g="git"
alias ga="git add"
alias gaa="git add --all"
alias gc="git commit"
alias gcm="git commit -m"
alias gco="git checkout"
alias gst="git status"
alias gl="git pull"
alias gp="git push"
alias gd="git diff"
alias gb="git branch"
alias glog="git log --oneline --graph"

# Amazon Q lazy loading
q() {
    [[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh" ]] && source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh"
    [[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh" ]] && source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh"
    unset -f q
    q "$@"
}

# Load config files for mqc
for conf in "$HOME/.config/zsh/config.d/"*.zsh; do
  source "${conf}"
done
unset conf
