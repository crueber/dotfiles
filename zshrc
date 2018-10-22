
ZSH=$HOME/.oh-my-zsh
export ZSH=$ZSH
#ZSH_THEME="chrisrueber" # or: gallois
ZSH_THEME="agnoster" # or: gallois

# alias packden="$HOME/Dropbox/packden.sh"

# DISABLE_AUTO_UPDATE="true"
# DISABLE_LS_COLORS="true"
# DISABLE_AUTO_TITLE="true"
COMPLETION_WAITING_DOTS="true"

plugins=(redis-cli history-substring-search)

source $ZSH/oh-my-zsh.sh

# export EDITOR=code
export VISUAL=vim
export EDITOR=$VISUAL
export SHELL=/usr/bin/zsh
export HISTSIZE=4096

