#!/usr/bin/env bash
# check_deps.sh — verify and (optionally) install required tools
# Checks/installs: stow, find, sort, git, wget, fastfetch, mise, oh-my-posh,
#                  brew, lsd, nvim, bat, btop, delta, opencode, and ensures LazyVim.
# Supports: macOS/Homebrew, Debian/Ubuntu (apt), Arch/Manjaro (pacman)

set -euo pipefail

confirm() {
  local prompt="${1:-Proceed?} [y/N] "
  read -r -p "$prompt" ans || true
  case "$ans" in
  y | Y | yes | YES) return 0 ;;
  *) return 1 ;;
  esac
}

have() { command -v "$1" >/dev/null 2>&1; }

install_instructions_note() {
  echo "Tip: You can re-run with --yes to auto-install without prompts."
}

# Detect package manager/platform
OS="$(uname -s)"
HOMEBREW_BIN="${HOMEBREW_PREFIX:-/opt/homebrew}/bin/brew"
[ -x /usr/local/bin/brew ] && HOMEBREW_BIN="/usr/local/bin/brew"

PKG="unknown"
if have brew; then
  PKG="brew"
elif [ -x "$HOMEBREW_BIN" ]; then
  PKG="brew"
elif have apt-get; then
  PKG="apt"
elif have pacman; then
  PKG="pacman"
fi

AUTO_YES=0
for a in "$@"; do
  [ "$a" = "--yes" ] && AUTO_YES=1
done

ask_install() {
  if [ "$AUTO_YES" -eq 1 ]; then
    return 0
  fi
  confirm "Install missing component(s)?"
}

brew_install() {
  local pkg="$1"
  echo "Installing $pkg via Homebrew..."
  brew install "$pkg"
}

apt_install() {
  local pkg="$1"
  echo "Installing $pkg via apt..."
  sudo apt-get update -y
  sudo apt-get install -y "$pkg"
}

pacman_install() {
  local pkg="$1"
  echo "Installing $pkg via pacman..."
  sudo pacman -Sy --noconfirm "$pkg"
}

ensure_brew() {
  if have brew; then
    return 0
  fi
  if [ "$PKG" = "apt" ] || [ "$PKG" = "pacman" ]; then
    # On Linux, brew is optional; prefer system pkg manager if present
    return 1
  fi
  echo "Homebrew not found. Install it?"
  if ask_install; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || true)"
    eval "$(/usr/local/bin/brew shellenv 2>/dev/null || true)"
  else
    return 1
  fi
}

missing=()

need_cmd() {
  local cmd="$1"
  local pretty="${2:-$1}"
  if have "$cmd"; then
    printf "OK   %-12s -> %s\n" "$pretty" "$(command -v "$cmd")"
  else
    printf "MISS %-12s\n" "$pretty"
    missing+=("$cmd")
  fi
}

echo "Checking required commands..."
need_cmd stow
need_cmd find
need_cmd sort
need_cmd git
need_cmd wget
need_cmd fastfetch
need_cmd mise
need_cmd oh-my-posh
need_cmd brew
need_cmd lsd
need_cmd nvim "neovim"
need_cmd bat
need_cmd btop
need_cmd delta
need_cmd opencode

if [ "${#missing[@]}" -gt 0 ]; then
  echo
  echo "Missing: ${missing[*]}"
  install_instructions_note

  if ! ask_install; then
    echo "Skipping installs."
  else
    # Ensure a package manager (install brew only if nothing else usable)
    if [ "$PKG" = "unknown" ]; then
      ensure_brew || true
      if have brew; then PKG="brew"; fi
    fi

    for cmd in "${missing[@]}"; do
      case "$cmd" in
      # Common CLI packages
      stow | git | wget | lsd | nvim | bat | btop | fastfetch | mise | oh-my-posh | delta | opencode)
        case "$PKG" in
        brew)
          case "$cmd" in
          nvim)    brew_install neovim ;;
          bat)     brew_install bat ;;
          lsd)     brew_install lsd ;;
          btop)    brew_install btop ;;
          fastfetch) brew_install fastfetch ;;
          mise)    brew_install mise ;;
          oh-my-posh) brew_install oh-my-posh ;;
          delta)    brew_install git-delta ;;
          opencode) brew_install opencode ;;
          *)        brew_install "$cmd" ;;
          esac
          ;;
        apt)
          case "$cmd" in
          nvim)    apt_install neovim ;;
          bat)     apt_install bat || { apt_install batcat && ln -sf /usr/bin/batcat "$HOME/.local/bin/bat"; } ;;
          lsd)     apt_install lsd ;;
          btop)    apt_install btop ;;
          fastfetch) apt_install fastfetch || sudo snap install fastfetch || true ;;
          mise)
            echo "Installing 'mise' via official script..."
            curl -fsSL https://mise.run | sh
            ;;
          oh-my-posh)
            echo "Installing 'oh-my-posh' via official script..."
            curl -fsSL https://ohmyposh.dev/install.sh | bash -s
            ;;
          delta)    apt_install git-delta ;;
          opencode)
            echo "Installing 'opencode' via official script..."
            curl -fsSL https://opencode.ai/install | bash
            ;;
          *)        apt_install "$cmd" ;;
          esac
          ;;
        pacman)
          # Map to Arch package names
          case "$cmd" in
          nvim)    pacman_install neovim ;;
          bat)     pacman_install bat ;;
          lsd)     pacman_install lsd ;;
          btop)    pacman_install btop ;;
          fastfetch) pacman_install fastfetch ;;
          mise)
            # Prefer yay (AUR) if available; otherwise use official script.
            if have yay; then
              echo "Installing 'mise' via yay (AUR)..."
              yay -S --noconfirm mise-bin || yay -S --noconfirm mise
            else
              echo "Installing 'mise' via official script..."
              curl -fsSL https://mise.run | sh
            fi
            ;;
          oh-my-posh)
            pacman_install oh-my-posh || {
              if have yay; then
                yay -S --noconfirm oh-my-posh-bin || yay -S --noconfirm oh-my-posh
              else
                echo "Installing 'oh-my-posh' via official script..."
                curl -fsSL https://ohmyposh.dev/install.sh | bash -s
              fi
            }
            ;;
          delta)    pacman_install git-delta ;;
          opencode)
            # opencode is in the AUR; fall back to official install script
            if have paru; then
              echo "Installing 'opencode' via paru (AUR)..."
              paru -S --noconfirm opencode-bin
            elif have yay; then
              echo "Installing 'opencode' via yay (AUR)..."
              yay -S --noconfirm opencode-bin
            else
              echo "Installing 'opencode' via official script..."
              curl -fsSL https://opencode.ai/install | bash
            fi
            ;;
          *)        pacman_install "$cmd" ;;
          esac
          ;;
        *)
          echo "No supported package manager found. Please install '$cmd' manually."
          ;;
        esac
        ;;
      find | sort)
        # Usually part of base system. Install coreutils/findutils if really missing.
        case "$PKG" in
        brew)
          brew_install findutils
          brew_install coreutils
          ;;
        apt)
          apt_install findutils
          apt_install coreutils
          ;;
        pacman)
          pacman_install findutils
          pacman_install coreutils
          ;;
        *)
          echo "Please install coreutils/findutils to provide '$cmd'."
          ;;
        esac
        ;;
      brew)
        ensure_brew || echo "Homebrew installation skipped."
        ;;
      *)
        echo "Unknown installer mapping for $cmd"
        ;;
      esac
    done
  fi
else
  echo "All base commands present."
fi

# Ensure brew in PATH if it was just installed
if have brew; then
  eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || true)"
  eval "$(/usr/local/bin/brew shellenv 2>/dev/null || true)"
fi

echo
echo "Checking LazyVim for Neovim..."

have_nvim=0
if have nvim; then have_nvim=1; fi

LAZY_DIR="${HOME}/.local/share/nvim/lazy/lazy.nvim"
NVIM_CFG_DIR="${HOME}/.config/nvim"

ensure_lazy() {
  if [ -d "$LAZY_DIR" ]; then
    echo "OK   lazy.nvim at $LAZY_DIR"
    return 0
  fi
  echo "MISS lazy.nvim"
  if ask_install; then
    git clone --filter=blob:none https://github.com/folke/lazy.nvim.git \
      --branch=stable "$LAZY_DIR"
    echo "Installed lazy.nvim."
  else
    return 1
  fi
}

ensure_lazyvim_starter() {
  if [ -d "$NVIM_CFG_DIR" ] && [ -n "$(ls -A "$NVIM_CFG_DIR" 2>/dev/null || true)" ]; then
    echo "Neovim config exists at $NVIM_CFG_DIR — not overwriting."
    echo "Tip: integrate LazyVim per docs: https://lazyvim.org/installation"
    return 0
  fi
  echo "No existing Neovim config. Install LazyVim starter?"
  if ask_install; then
    git clone https://github.com/LazyVim/starter "$NVIM_CFG_DIR"
    (cd "$NVIM_CFG_DIR" && rm -rf .git)
    echo "LazyVim starter installed to $NVIM_CFG_DIR."
  fi
}

if [ $have_nvim -eq 0 ]; then
  echo "Neovim not found; attempted to install above. Skipping LazyVim checks."
else
  ensure_lazy || true
  ensure_lazyvim_starter || true
  echo "To finalize plugins, run: nvim +Lazy! +q"
fi

echo
echo "Dependency check complete."
