#!/bin/sh

cutstring="DO NOT EDIT BELOW THIS LINE"

for name in *; do
  target="$HOME/.$name"
  if [ -e "$target" ]; then
    if [ ! -L "$target" ]; then
      cutline=`grep -n -m1 "$cutstring" "$target" | sed "s/:.*//"`
      if [ -n "$cutline" ]; then
        cutline=$((cutline-1))
        echo "Updating $target"
        head -n $cutline "$target" > update_tmp
        startline=`sed '1!G;h;$!d' "$name" | grep -n -m1 "$cutstring" | sed "s/:.*//"`
        if [ -n "$startline" ]; then
          tail -n $startline "$name" >> update_tmp
        else
          cat "$name" >> update_tmp
        fi
        mv update_tmp "$target"
      else
        echo "WARNING: $target exists but is not a symlink."
      fi
    fi
  else
    if [ "$name" != 'install.sh' ] && [ "$name" != 'README.md' ] && [ "$name" != 'LICENSE' && [ "$name" != "nvim-custom" ]]; then
      echo "Creating $target"
      if [ -n "$(grep "$cutstring" "$name")" ]; then
        cp "$PWD/$name" "$target"
      else
        ln -s "$PWD/$name" "$target"
      fi
    fi
  fi
done

if [ -e "$HOME/.oh-my-zsh/themes" ]; then
  cp $PWD/zsh-themes/* "$HOME/.oh-my-zsh/themes/"
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
if [ -e "$NVIM/lua/custom" ]; then 
  echo "Removing $NVIM/lua/custom and copying custom files."
  rm -rf "$NVIM/lua/custom"
  cp -r nvim-custom "$NVIM/lua/custom"
fi 

