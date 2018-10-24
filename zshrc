
ZSH=$HOME/.oh-my-zsh
export ZSH=$ZSH
#ZSH_THEME="chrisrueber" # or: gallois
ZSH_THEME="agnoster" # or: gallois

# alias packden="$HOME/Dropbox/packden.sh"
alias newprodkubectl="kubectl config use-context prod.balanc3.net && kubectl"

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
export PATH="$PATH:$HOME/.bin:$HOME/bin:node_modules/.bin:/usr/local/share/npm/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

#[ -z "$TMUX" ] && exec tmux new -As $WINDOWID
[ -n "$WINDOWID" ] && [ -z "$TMUX" ] && exec tmux new -As $WINDOWID

