export ZSH="$HOME/.config/ohmyzsh"

ZSH_THEME="ez"
plugins=(git vi-mode)

source $ZSH/oh-my-zsh.sh

export LANG=en_US.UTF-8
export EDITOR="$(which nvim)"

export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

# Add deno completions to search path
if [[ ":$FPATH:" != *":/home/aron/.zsh/completions:"* ]]; then export FPATH="/home/aron/.zsh/completions:$FPATH"; fi
export PATH=$HOME/bin:$HOME/.local/bin:$HOME/go/bin:/usr/local/go/bin:/usr/local/bin:$PATH


. $HOME/.cargo/env

alias vim="$(which nvim)"
alias rf="rm -rf"
alias zshconfig="vim $HOME/personal/dotfiles/.zshrc"
alias ohmyzsh="vim $ZSH"

mc() {
    mkdir -p $1 && cd $1
}

t() {
    touch $1 &> /dev/null || mkdir -p $(dirname $1) && touch $1
}

bindkey -s ^f "sesh"
. "/home/aron/.deno/env"
