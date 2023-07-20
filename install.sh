#!/bin/bash

skip=('install.sh' 'README.md' 'LICENSE' 'nvim-custom')

for name in *; do
  if [[ " ${skip[*]} " =~ " ${name} " ]]; then
    continue
  fi

  target="$HOME/.$name"
  if [ -L "$target" ]; then
    echo "INFO: $target symlink exists."
  elif [ -e "$target" ] && [ ! -L "$target" ]; then
    echo "WARNING: $target exists but is not symlinked."
  else
    echo "Symlinking '$PWD/$name' to '$target'"
    ln -s "$PWD/$name" "$target"
  fi
done

if [ -e "$HOME/.oh-my-zsh/themes" ]; then
  cp -r $PWD/zsh-themes/* "$HOME/.oh-my-zsh/themes/"
fi

NVIM="$HOME/.config/nvim"
if [ -e "$NVIM" ] && [ ! -e "$NVIM/.git" ]; then
  echo "Removing $NVIM because it is not a git repo."
  rm -rf $NVIM
fi
if [ ! -e "$NVIM" ]; then
  echo "Cloning in to nvChad at $NVIM."
  git clone https://github.com/nvchad/nvchad "$NVIM" --depth 1
fi
if [ -e "$NVIM/lua" ]; then 
  if [ -e "$NVIM/lua/custom" ]; then
    echo "Removing $NVIM/lua/custom."
    rm -rf "$NVIM/lua/custom"
  fi
  echo "Copying custom lua scripts for nvim in to $NVIM/lua/custom"
  cp -r nvim-custom "$NVIM/lua/custom"
fi 

