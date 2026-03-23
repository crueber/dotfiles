[ -f ~/.zshrc.local ] && source ~/.zshrc.local
[ -f ~/.zshrc.update ] && source ~/.zshrc.update

export EDITOR=nvim
export VISUAL=nvim
export HISTSIZE=4096

source $HOME/.aliases
export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH:$HOME/bin"

# Added by LM Studio CLI (lms) — macOS only
[[ "$(uname)" == "Darwin" ]] && export PATH="$PATH:$HOME/.lmstudio/bin"
# End of LM Studio CLI section

eval "$(mise activate zsh)"
[[ "$(uname)" == "Darwin" ]] && export JAVA_HOME="/Library/Java/JavaVirtualMachines/temurin-17.jdk/Contents/Home"

# delta — git diff pager. Defaults to dark mode (see ~/.gitconfig [delta]).
# To use light mode, add this to ~/.zshrc.local:
#   export DELTA_FEATURES=+light


# opencode
export PATH=$HOME/.opencode/bin:$PATH

# oh-my-posh — init after PATH is fully set so the binary can be found
#eval "$(oh-my-posh init zsh --config 'catppuccin_mocha')"
eval "$(oh-my-posh init zsh --config '~/.oh-my-posh/blue-owl-custom.omp.json')"

if [[ -z "$TMUX" ]] && command -v tmux &>/dev/null; then
  #tmux attach 2>/dev/null || tmux new-session
fi

















# >>> opentmux >>>
export OPENCODE_PORT=4096
alias opencode='opentmux'
# <<< opentmux <<<
