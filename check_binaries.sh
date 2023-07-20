#!/bin/bash

required_binaries=('zsh' 'awk' 'sed' 'nvim' 'gdu' 'htop' 'btop' 'node' 'deno' 'ruby' 'go' 'ag' 'exa' 'bat' 'lg' 'tig')

available_binaries=''
missing_binaries=''

for binary in "${required_binaries[@]}"; do
  if ! command -v $binary &> /dev/null && ! type $binary >/dev/null 2>&1; then
    missing_binaries+=" $binary"
  else
    available_binaries+=" $binary"
  fi
done

echo "Available tools:$available_binaries"
echo "Missing tools:$missing_binaries"

