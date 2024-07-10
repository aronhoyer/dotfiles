export HISTFILESIZE=5000
export HISTSIZE=5000
export HISTFILE=$HOME/.zsh_history
export HISTTIMEFORMAT="[%F %T] "

setopt SHARE_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt INC_APPEND_HISTORY
setopt EXTENDED_HISTORY
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_ALL_DUPS

autoload -U compinit && compinit

setopt autocd autopushd pushdignoredups

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' menu select

bindkey '\e[A' history-search-backward
bindkey '\e[B' history-search-forward
bindkey -r '^L'
bindkey -r '^J'

export CLICOLOR=1
export LSCOLORS=ExFxCxDxBxegedabagaced

autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git svn
setopt prompt_subst
precmd() {
    vcs_info
}
zstyle ':vcs_info:git*' formats '(%b) '

PS1='%F{green}%3~%f ${vcs_info_msg_0_}%F{red}%(?..[%?] )%f%% '

alias vim="$(which nvim)"
alias cat="$(which bat)"
alias ls="ls --color=auto"
alias ll="ls -l"
alias la="ls -al"
alias md="mkdir -p"
alias rf="rm -rf"

export EDITOR="$(which nvim)"

git_current_branch() {
    if git rev-parse --git-dir > /dev/null 2>&1; then
	git -C "$1" branch | sed  '/^\*/!d;s/\* //'
    fi
}

alias ga="git add"
alias gaa="git add --all"
alias gc="git commit"
alias gcan="git commit --amend --no-edit"
alias gcmsg="git commit --message"
alias gco="git checkout"
alias gd="git diff"
alias gf="git fetch"
alias gl="git pull"
alias glo="git log --oneline"
alias glog="git log"
alias gp="git push"
alias gpf="git push --force-with-lease"
alias gpr="git pull --rebase"
alias gpu="git push --set-upstream"
alias gpup="git push --set-upstream origin $(git_current_branch)"
alias gst="git status"
alias gsw="git switch"

mc() {
    mkdir -p $1 && cd $1
}

t() {
    touch $1 &> /dev/null || mkdir -p $(dirname $1) && touch $1
}

bindkey -s '^f' sesh

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export PATH="$PATH:/usr/local/go/bin"
export PATH="$PATH:$HOME/.local/bin"

. "$HOME/.cargo/env"
