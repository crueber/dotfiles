
ZSH=$HOME/.oh-my-zsh
ZSH_THEME="chrisrueber" # or: gallois

alias novustaging='ssh crueber@sae1ca01.novu.com'

# DISABLE_AUTO_UPDATE="true"
# DISABLE_LS_COLORS="true"
# DISABLE_AUTO_TITLE="true"
COMPLETION_WAITING_DOTS="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(bundler gem zeus heroku jruby node osx rake rails3 rvm ruby sublime redis-cli history-substring-search)

source $ZSH/oh-my-zsh.sh

# Customize to your needs...
export PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin
# export EDITOR='subl -w'
export VISUAL=vim
export EDITOR=$VISUAL
export rvm_install_on_use_flag=1
export SHELL=/usr/local/bin/zsh
export HISTSIZE=4096
setopt auto_cd
setopt auto_pushd
export dirstacksize=5

PATH=$PATH:$HOME/.rvm/bin:$HOME/bin:/usr/local/share/npm/bin:$HOME/Development/phantomjs-1.7.0/bin

rvm use default

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"

