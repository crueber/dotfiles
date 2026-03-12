#!/usr/bin/env bash
# unstow.sh — Remove all stow-managed symlinks from $HOME for every package
# in this repository.  Mirrors the package-discovery logic from install.sh.

set -euo pipefail

# Require bash 4+ (matches install.sh requirement)
if (( BASH_VERSINFO[0] < 4 )); then
  echo "Error: bash 4 or newer is required (found bash ${BASH_VERSION})." >&2
  echo "  macOS ships bash 3.2. Install a newer bash via Homebrew: brew install bash" >&2
  echo "  Then ensure it appears in PATH before /bin/bash." >&2
  exit 1
fi

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${HOME}"

require() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Error: required command '$1' not found." >&2
    exit 1
  fi
}
require stow
require find
require sort

# Collect packages = top-level directories (exclude infra)
packages=()
while IFS= read -r -d '' dir; do
  name="$(basename "$dir")"
  case "$name" in
  .git | .svn | .hg | .github | .gitlab | node_modules | .stow) continue ;;
  esac
  packages+=("$name")
done < <(find "$SCRIPT_DIR" -mindepth 1 -maxdepth 1 -type d -print0 | sort -z)

if [ "${#packages[@]}" -eq 0 ]; then
  echo "No stowable packages found in: $SCRIPT_DIR"
  exit 0
fi

echo "Detected packages:"
printf "  - %s\n" "${packages[@]}"
echo

echo "Unstowing (removing symlinks):"
stow -D -v -d "$SCRIPT_DIR" -t "$TARGET_DIR" "${packages[@]}"

echo
echo "Done. All stow-managed symlinks have been removed from ${TARGET_DIR}."
