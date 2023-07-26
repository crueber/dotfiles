
ZSH=$HOME/.oh-my-zsh
export ZSH=$ZSH
#ZSH_THEME="chrisrueber" # or: gallois
ZSH_THEME="agnoster" # or: gallois

# DISABLE_AUTO_UPDATE="true"
# DISABLE_LS_COLORS="true"
# DISABLE_AUTO_TITLE="true"
COMPLETION_WAITING_DOTS="true"

plugins=(git history-substring-search)

export EDITOR=vim
export VISUAL=vim
export SHELL=/usr/bin/zsh
export HISTSIZE=4096

source $ZSH/oh-my-zsh.sh
source $HOME/.aliases

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

[ -n "$WINDOWID" ] && [ -z "$TMUX" ] && exec tmux new -As $WINDOWID

[ -e /usr/bin/neofetch ] && neofetch

