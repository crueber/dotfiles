#!/bin/bash

link () {
  name=$1
  target=$2

  if [ -L "$target" ]; then
    echo "INFO: $target symlink exists."
  elif [ -e "$target" ] && [ ! -L "$target" ]; then
    echo "WARNING: $target exists but is not symlinked."
  else
    echo "Symlinking '$name' to '$target'"
    ln -s "$name" "$target"
  fi
}

skip=('config' 'install.sh' 'README.md' 'LICENSE' 'nvim-custom' 'zsh-themes')
for name in *; do
  if [[ " ${skip[*]} " =~ " ${name} " ]]; then
    continue
  fi

  link $name "$HOME/.$name"
done

if [ ! -e "$HOME/.config" ]; then
  echo "INFO: $HOME/.config does not exist, creating."
  mkdir $HOME/.config
else
  echo "INFO: Ensured $HOME/.config exists."
fi

for name in config/*; do
  link $name "$HOME/.$name"
done

if [ -e "$HOME/.oh-my-zsh/themes" ]; then
  echo "INFO: Copying oh-my-zsh themes to the $HOME/.oh-my-zsh/themes/."
  cp -r $PWD/zsh-themes/* "$HOME/.oh-my-zsh/themes/"
else
  echo "WARNING: Oh-my-zhs theme directory not found, skipping theme copy."
fi

NVIM="$HOME/.config/nvim"
if [ -e "$NVIM" ] && [ ! -e "$NVIM/.git" ]; then
  echo "INFO: Removing $NVIM because it is not a git repo."
  rm -rf $NVIM
fi
if [ ! -e "$NVIM" ]; then
  echo "INFO: Cloning in to nvChad at $NVIM."
  git clone https://github.com/nvchad/nvchad "$NVIM" --depth 1
fi
if [ -e "$NVIM/lua" ]; then 
  if [ -e "$NVIM/lua/custom" ]; then
    echo "INFO: Removing $NVIM/lua/custom."
    rm -rf "$NVIM/lua/custom"
  fi
  echo "INFO: Copying custom lua scripts for nvim in to $NVIM/lua/custom"
  cp -r nvim-custom "$NVIM/lua/custom"
fi 

cmds=('zsh' 'nvim' 'node' 'deno' 'ruby' 'go' 'ag')
for cmd in "${cmds[@]}"; do
  cmdwhich=$(which ${cmd} 2>&1)
  if [[ "$cmdwhich" =~ ^which.*$ ]]; then
    echo "WARNING: $cmd is unavailable!"
  else
    echo "INFO: $cmd is available"
  fi
done

