#!/usr/bin/env bash
# install.sh — Stow all packages into $HOME, auto-backup only true conflicts
# Strategy: parse stow dry-run for conflicts, back up exactly those paths.

set -euo pipefail

# Require bash 4+ for associative arrays and mapfile
if (( BASH_VERSINFO[0] < 4 )); then
  echo "Error: bash 4 or newer is required (found bash ${BASH_VERSION})." >&2
  echo "  macOS ships bash 3.2. Install a newer bash via Homebrew: brew install bash" >&2
  echo "  Then ensure it appears in PATH before /bin/bash." >&2
  exit 1
fi

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${HOME}"
TS="$(date +%Y%m%d%H%M%S)"

# Initialize/update git submodules (e.g. tmux plugins) before stow runs,
# so symlink targets are populated.
if [ -f "$SCRIPT_DIR/.gitmodules" ]; then
  echo "Initializing git submodules..."
  git -C "$SCRIPT_DIR" submodule update --init --recursive
  echo "Submodules ready."
  echo
fi

# Run opencode-extras install if opencode is installed
if [ -f "$SCRIPT_DIR/extras/opencode-extras/install.sh" ]; then
  if [ -d "${HOME}/.config/opencode" ]; then
    echo "Running extras/opencode-extras/install.sh..."
    bash "$SCRIPT_DIR/extras/opencode-extras/install.sh"
    echo
  else
    echo "Warning: ~/.config/opencode not found; skipping opencode-extras install." >&2
    echo "  Run extras/opencode-extras/install.sh manually after installing opencode." >&2
    echo
  fi
fi

# ---------------------------------------------------------------------------
# Platform detection — used to print install hints for missing commands
# ---------------------------------------------------------------------------
_detect_pkg_manager() {
  if command -v brew >/dev/null 2>&1; then
    echo "brew"
  elif command -v pacman >/dev/null 2>&1; then
    echo "pacman"
  elif command -v apt-get >/dev/null 2>&1; then
    echo "apt"
  else
    echo "unknown"
  fi
}
PKG_MGR="$(_detect_pkg_manager)"

# Print the recommended install command for a given tool on the detected platform.
_install_hint() {
  local cmd="$1"
  case "$PKG_MGR" in
  brew)
    case "$cmd" in
    stow)  echo "  brew install stow" ;;
    find)  echo "  brew install findutils" ;;
    sort)  echo "  brew install coreutils" ;;
    awk)   echo "  brew install gawk" ;;
    *)     echo "  brew install $cmd" ;;
    esac
    ;;
  pacman)
    case "$cmd" in
    stow)  echo "  sudo pacman -S stow" ;;
    find)  echo "  sudo pacman -S findutils" ;;
    sort)  echo "  sudo pacman -S coreutils" ;;
    awk)   echo "  sudo pacman -S gawk" ;;
    *)     echo "  sudo pacman -S $cmd" ;;
    esac
    ;;
  apt)
    case "$cmd" in
    stow)  echo "  sudo apt install stow" ;;
    find)  echo "  sudo apt install findutils" ;;
    sort)  echo "  sudo apt install coreutils" ;;
    awk)   echo "  sudo apt install gawk" ;;
    *)     echo "  sudo apt install $cmd" ;;
    esac
    ;;
  *)
    echo "  (no package manager detected — please install '$cmd' manually)"
    ;;
  esac
}

# Collect all missing required commands, then report and exit if any are absent.
_missing=()
for _cmd in stow find sort awk; do
  command -v "$_cmd" >/dev/null 2>&1 || _missing+=("$_cmd")
done

if [ "${#_missing[@]}" -gt 0 ]; then
  echo "Error: the following required commands are missing:" >&2
  for _cmd in "${_missing[@]}"; do
    echo "  - $_cmd" >&2
  done
  echo >&2
  echo "Install them with:" >&2
  for _cmd in "${_missing[@]}"; do
    _install_hint "$_cmd" >&2
  done
  echo >&2
  echo "Then re-run ./install.sh" >&2
  exit 1
fi

# Collect packages = top-level directories (exclude infra)
packages=()
while IFS= read -r -d '' dir; do
  name="$(basename "$dir")"
  case "$name" in
  .git | .svn | .hg | .github | .gitlab | node_modules | .stow | extras) continue ;;
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

echo "Dry run (capturing conflicts):"
# Capture dry-run output (do not fail script on conflicts)
DRYRUN_OUT="$(stow -n -v -d "$SCRIPT_DIR" -t "$TARGET_DIR" "${packages[@]}" 2>&1 || true)"
printf "%s\n" "$DRYRUN_OUT"
echo

# Parse conflict targets out of dry-run.
# Stow prints lines like:
# "WARNING! stowing <pkg> would cause conflicts:"
# "  * existing target <path> is neither... "
# "  * cannot stow <source> over existing target <target> since ..."
# We extract the final target path after the words "target ".
conflicts=()
while IFS= read -r line; do
  case "$line" in
  *" cannot stow "*)
    # extract after " target " up to end (strip reason)
    tgt="$(printf "%s" "$line" | awk -F ' target ' '{print $2}' | awk '{print $1}')"
    ;;
  *" existing target "*)
    tgt="$(printf "%s" "$line" | awk -F ' existing target ' '{print $2}' | awk '{print $1}')"
    ;;
  *)
    tgt=""
    ;;
  esac
  if [ -n "$tgt" ]; then
    # If relative (starts without /), make it absolute in $TARGET_DIR
    case "$tgt" in
    /*) abs="$tgt" ;;
    *) abs="${TARGET_DIR%/}/${tgt}" ;;
    esac
    conflicts+=("$abs")
  fi
done <<<"$DRYRUN_OUT"

# De-duplicate conflict list
if [ "${#conflicts[@]}" -gt 0 ]; then
  mapfile -t conflicts < <(printf "%s\n" "${conflicts[@]}" | awk '!seen[$0]++')
fi

# Helper: is a path a backup file name we created?
is_backup_name() {
  case "$1" in
  *.bak | *.bak.[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]) return 0 ;;
  *) return 1 ;;
  esac
}

# Helper: does a symlink point into our repo?
points_into_repo() {
  local path="$1"
  [ -L "$path" ] || return 1
  local parent dest abs repo
  parent="$(dirname "$path")"
  dest="$(readlink "$path" || true)"
  [ -z "$dest" ] && return 1
  if [ "${dest#/}" = "$dest" ]; then
    dest="${parent}/${dest}"
  fi
  if command -v realpath >/dev/null 2>&1; then
    abs="$(realpath -m "$dest" 2>/dev/null || echo "$dest")"
    repo="$(realpath -m "$SCRIPT_DIR" 2>/dev/null || echo "$SCRIPT_DIR")"
  else
    abs="$dest"
    repo="$SCRIPT_DIR"
  fi
  case "$abs" in
  "$repo"/*) return 0 ;;
  *) return 1 ;;
  esac
}

# Backup only true conflicts
if [ "${#conflicts[@]}" -gt 0 ]; then
  echo "Backing up conflicting targets to *.bak.${TS}:"
  for target in "${conflicts[@]}"; do
    # Skip if it no longer exists (state changed) or is already correctly stowed
    if [ ! -e "$target" ] && [ ! -L "$target" ]; then
      continue
    fi
    if points_into_repo "$target"; then
      continue
    fi
    # Skip our own backups
    if is_backup_name "$target"; then
      continue
    fi
    bak="${target}.bak.${TS}"
    echo "  ${target} -> ${bak}"
    mkdir -p "$(dirname "$target")"
    mv -f "$target" "$bak"
  done
  echo "Backup complete."
else
  echo "No conflicts detected by stow dry-run."
fi

echo
echo "Applying (restow):"
stow -R -v -d "$SCRIPT_DIR" -t "$TARGET_DIR" "${packages[@]}"

echo
echo "Done."
echo "- Only paths reported by stow as conflicts were backed up."
echo "- Backups use suffix .bak.${TS} and won’t be touched on reruns."
