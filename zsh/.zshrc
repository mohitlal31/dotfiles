# Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Load Powerlevel10k
source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Completions
autoload -Uz compinit && compinit

# History
HISTFILE=$HOME/.zhistory
HISTSIZE=10000
SAVEHIST=10000
setopt share_history
setopt hist_ignore_dups

# Plugins
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Tools
eval "$(zoxide init zsh)"
eval "$(fzf --zsh)"

# Environment
export EDITOR="nvim"
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
export PATH="$HOME/.jenv/bin:$PATH"
export TMUX_THEME="gruvbox"

# Ruby
export GEM_HOME="/opt/homebrew/lib/ruby/gems/3.3.0"
export PATH="$GEM_HOME/bin:/opt/homebrew/opt/ruby/bin:$PATH"

# Aliases
alias ls="eza --icons=always"
alias cd="z"

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
