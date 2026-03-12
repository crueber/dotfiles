#eval "$(oh-my-posh init zsh --config 'catppuccin_mocha')"
eval "$(oh-my-posh init zsh --config '~/.oh-my-posh/blue-owl-custom.omp.json')"
eval "$(/Users/crueber/.local/bin/mise activate zsh)"

[ -f ~/.zshrc.local ] && source ~/.zshrc.local
export EDITOR=nvim
export VISUAL=nvim
export HISTSIZE=4096

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/crueber/.lmstudio/bin"
# End of LM Studio CLI section

source $HOME/.aliases
export PATH="$PATH:$HOME/bin"
export JAVA_HOME="/Library/Java/JavaVirtualMachines/temurin-17.jdk/Contents/Home"


# opencode
export PATH=/Users/crueber/.opencode/bin:$PATH

if [[ -z "$TMUX" ]] && command -v tmux &>/dev/null; then
  #tmux attach 2>/dev/null || tmux new-session
fi






# >>> opentmux >>>
export OPENCODE_PORT=4096
alias opencode='opentmux'
# <<< opentmux <<<
