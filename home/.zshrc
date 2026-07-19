# Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Load Powerlevel10k (from Nix, via the per-user profile)
NIX_ZSH_SHARE="/etc/profiles/per-user/$USER/share"
[[ -r $NIX_ZSH_SHARE/zsh/themes/powerlevel10k/powerlevel10k.zsh-theme ]] \
  && source $NIX_ZSH_SHARE/zsh/themes/powerlevel10k/powerlevel10k.zsh-theme
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

# Plugins (from Nix)
[[ -r $NIX_ZSH_SHARE/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]] \
  && source $NIX_ZSH_SHARE/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
[[ -r $NIX_ZSH_SHARE/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] \
  && source $NIX_ZSH_SHARE/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

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
alias docker="podman"

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

# SSH to a Marqeta Kubernetes bastion and copy workload creds + kubectl setup to clipboard.
# Usage: mkssh <cluster>   e.g. mkssh mkprod-useast1-2
mkssh() {
    [[ -z $1 ]] && { echo "usage: mkssh <cluster>  e.g. mkssh mkprod-useast1-2"; return 1; }
    local cluster=$1 region account
    case $cluster in
        *useast1*)    region=us-east-1 ;;
        *useast2*)    region=us-east-2 ;;
        *uswest2*)    region=us-west-2 ;;
        *eucentral1*) region=eu-central-1 ;;
        *) echo "unsupported region in cluster name"; return 1 ;;
    esac
    case $cluster in
        mk*qa*)   account=mq01-qa ;;
        mk*prod*) account=mq01-prod ;;
        *) echo "unsupported account for cluster"; return 1 ;;
    esac

    echo "→ switching to workload role (team-transaction-engine-dev)..."
    mqc --account-name $account --role-name team-transaction-engine-dev --region-name $region || return 1

    # Resolve bastion instance ID while we still have ec2:DescribeInstances (bastn role doesn't).
    local instance_id=$(aws ec2 describe-instances \
        --filters "Name=tag:Name,Values=${cluster}-marqkubed-bastion-asg" \
                  "Name=instance-state-name,Values=running" \
        --region $region --output text --query 'Reservations[0].Instances[0].InstanceId')
    if [[ -z $instance_id || $instance_id == "None" ]]; then
        echo "Could not find running bastion with tag:Name=${cluster}-marqkubed-bastion-asg in $region"
        return 1
    fi

    {
        aws configure export-credentials --format env | grep -v AWS_CREDENTIAL_EXPIRATION
        print "aws eks update-kubeconfig --region $region --name $cluster"
        print "kubectl config set-context --current --namespace=transaction-engine"
        print "alias k=kubectl"
    } | pbcopy
    echo "→ workload creds + kubectl setup copied to clipboard."

    echo "→ starting SSM session to $instance_id..."
    aws ssm start-session --target $instance_id --region $region
}
