#!/bin/bash

required_binaries=('zsh' 'awk' 'sed' 'nvim' 'gdu' 'htop' 'btop' 'node' 'deno' 'ruby' 'go' 'ag' 'exa' 'bat' 'lazygit' 'tig')

available_binaries=''
missing_binaries=''

for binary in "${required_binaries[@]}"; do

  bin_condition=$(which ${binary} 2>&1)

  if [[ "$bin_condition" =~ ^which.*$ ]]; then
    missing_binaries+=" $binary"
  else
    available_binaries+=" $binary"
  fi
done

echo "Available tools:$available_binaries"
echo "Missing tools:$missing_binaries"

