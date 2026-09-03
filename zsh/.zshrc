[ -f ~/.zshrc.local ] && source ~/.zshrc.local
[ -f ~/.zshrc.update ] && source ~/.zshrc.update

export EDITOR=nvim
export VISUAL=nvim
export HISTSIZE=4096

source $HOME/.zsh_aliases
export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH:$HOME/bin"
export PATH="$PATH:$HOME/.bun/bin"


eval "$(mise activate zsh)"

# On interactive logins (console or SSH) — not nested subshells, not
# non-interactive sessions: show fastfetch and self-update mise tools.
if [[ -o interactive && -o login && $- == *i* && -t 0 ]]; then
  command -v fastfetch >/dev/null 2>&1 && fastfetch

  # Upgrade mise-managed tools when updates are available
  if command -v mise >/dev/null 2>&1 && [[ -n "$(mise outdated 2>/dev/null)" ]]; then
    echo "mise: updating outdated tools..."
    mise upgrade --yes
  fi
fi


# opencode
export PATH=$HOME/.opencode/bin:$PATH

# oh-my-posh — init after PATH is fully set so the binary can be found
#eval "$(oh-my-posh init zsh --config 'catppuccin_mocha')"
eval "$(oh-my-posh init zsh --config '~/.oh-my-posh/blue-owl-custom.omp.json')"

