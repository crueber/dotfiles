
ZSH=$HOME/.oh-my-zsh
export ZSH=$ZSH
#ZSH_THEME="chrisrueber" # or: gallois
ZSH_THEME="agnoster" # or: gallois
ZSH_THEME="nord-extended/nord" # or: gallois

zstyle ':omz:update' mode auto      # update automatically without asking
zstyle ':omz:update' frequency 13

# DISABLE_MAGIC_FUNCTIONS="true"
# DISABLE_LS_COLORS="true"
# DISABLE_AUTO_TITLE="true"
# ENABLE_CORRECTION="true"
# COMPLETION_WAITING_DOTS="true"
# DISABLE_UNTRACKED_FILES_DIRTY="true"
# HIST_STAMPS="mm/dd/yyyy"
# ZSH_CUSTOM=/path/to/new-custom-folder

COMPLETION_WAITING_DOTS="true"

plugins=(git history-substring-search)

export EDITOR=vim
export VISUAL=vim
export SHELL=/usr/bin/zsh
export HISTSIZE=4096

source $ZSH/oh-my-zsh.sh
source $HOME/.aliases

[ -e /usr/bin/neofetch ] && neofetch


export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
