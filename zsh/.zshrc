#eval "$(oh-my-posh init zsh --config 'catppuccin_mocha')"
eval "$(oh-my-posh init zsh --config '~/.oh-my-posh/velvet-custom.omp.json')"
eval "$(/Users/crueber/.local/bin/mise activate zsh)"

export EDITOR=nvim
export VISUAL=nvim
export HISTSIZE=4096

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/crueber/.lmstudio/bin"
# End of LM Studio CLI section

source $HOME/.aliases
export PATH="$PATH:$HOME/bin"

