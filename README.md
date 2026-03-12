# dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/). Each top-level directory is a stow package that mirrors the structure of `$HOME`. Running `install.sh` symlinks everything into place and safely backs up any pre-existing files that would conflict.

## Requirements

### Required

| Tool | Purpose |
|------|---------|
| `bash` 4+ | Install and helper scripts |
| `stow` | Symlink management |
| `git` | Version control |
| `find` / `sort` / `awk` | Used by install script |

### Strongly Recommended

| Tool | Purpose |
|------|---------|
| [mise](https://mise.jdx.dev) | Runtime version manager (replaces nvm, rbenv, etc.) |
| [oh-my-posh](https://ohmyposh.dev) | Shell prompt |
| [neovim](https://neovim.io) | Editor (`nvim`) |
| [lsd](https://github.com/lsd-rs/lsd) | Modern `ls` replacement |
| [bat](https://github.com/sharkdp/bat) | Modern `cat` replacement |
| [lazygit](https://github.com/jesseduffield/lazygit) | Terminal UI for git |
| [btop](https://github.com/aristocratos/btop) | System monitor |
| [fastfetch](https://github.com/fastfetch-cli/fastfetch) | System info display |
| [tmux](https://github.com/tmux/tmux) + [tpm](https://github.com/tmux-plugins/tpm) | Terminal multiplexer + plugin manager |

### Optional

| Tool | Purpose |
|------|---------|
| [LM Studio](https://lmstudio.ai) | Local LLM runner (path configured in `.zshrc`) |
| [opencode](https://opencode.ai) / opentmux | AI coding assistant alias |
| Java (Temurin 17) | `JAVA_HOME` is configured in `.zshrc` |

Run `check_deps.sh` to verify what is and isn't installed — it can also install missing tools automatically.

## Installation

```bash
# 1. Clone the repo
git clone git@github.com:crueber/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# 2. (Optional) Check and install dependencies
./check_deps.sh
# or auto-install everything without prompts:
./check_deps.sh --yes

# 3. Stow all packages into $HOME
./install.sh
```

`install.sh` is safe to re-run at any time. It will never silently overwrite existing files — conflicts are renamed to `<original>.bak.<timestamp>` before stowing.

## How It Works

### Stow Layout

Each top-level directory is a **stow package**. The directory tree inside it mirrors `$HOME`, so stow knows exactly where to create symlinks:

```
dotfiles/
├── bin/
│   └── bin/          → ~/bin/
├── git/
│   ├── .gitconfig    → ~/.gitconfig
│   └── .gitignore    → ~/.gitignore
├── lsd/
│   └── .config/
│       └── lsd/      → ~/.config/lsd/
├── oh-my-posh/
│   └── .oh-my-posh/  → ~/.oh-my-posh/
├── tmux/
│   ├── .tmux.conf    → ~/.tmux.conf
│   └── .tmux/        → ~/.tmux/
└── zsh/
    ├── .zshrc        → ~/.zshrc
    └── .aliases      → ~/.aliases
```

> **Note on `bin/bin/` double-nesting:** Stow would normally symlink the entire `bin/` package directory as `~/bin`. The inner `bin/bin/` nesting causes stow to instead create `~/bin/` as a real directory and symlink each script individually inside it. This is intentional — it keeps `~/bin/` as a real directory that can safely contain non-stow-managed files alongside the symlinked scripts.

### install.sh

The install script does the following:

1. Discovers all stow packages dynamically (any top-level directory that isn't `.git`, `.github`, `node_modules`, etc.)
2. Runs `stow --dry-run` to detect conflicts without making any changes
3. Parses the dry-run output to find exactly which files would conflict
4. Renames only those conflicting files to `<path>.bak.<timestamp>`
5. Runs `stow -R` (restow) to apply all packages

Backups are timestamped so re-runs never clobber previous backups. Symlinks that already point into the repo are skipped.

### check_deps.sh

Checks for all required and recommended tools. Detects the available package manager (Homebrew, apt, pacman) and can install anything missing. Accepts `--yes` to skip confirmation prompts.

```bash
./check_deps.sh        # interactive
./check_deps.sh --yes  # auto-install all missing tools
```

## Package Details

### `zsh/`

- **`.zshrc`** — Initializes oh-my-posh with the `blue-owl-custom` theme, activates mise, sets `EDITOR`/`VISUAL` to nvim, configures PATH for `~/bin`, LM Studio, and opencode.
- **`.aliases`** — Shell aliases: `ls=lsd`, `vim=nvim`, `n=nvim`, `cat=bat`, `ll="ls -al"`, `..="cd .."`, `lg=lazygit`

**Local overrides:** Create `~/.zshrc.local` for machine-specific settings (tokens, private paths, etc.). It is sourced automatically if it exists and is excluded from git via `.gitignore`.

### `git/`

- **`.gitconfig`** — User info, push default (`current`), useful aliases (`aa`, `ap`, `ci`, `co`, `st`, `rebase-origin`), Sourcetree difftool/mergetool, and a commit message template.
- **`.gitignore`** — Global ignores: `.DS_Store`, editor swap files, common Rails and macOS artifacts.

### `tmux/`

- **`.tmux.conf`** — Loads [tpm](https://github.com/tmux-plugins/tpm), [tmux-sensible](https://github.com/tmux-plugins/tmux-sensible), and [tmux-themepack](https://github.com/jimeh/tmux-themepack) with the `powerline/default/blue` theme. Mouse support and `tmux-256color` terminal are enabled.
- **`.tmux/plugins/tpm/`** — TPM is vendored directly in the repo so it's available immediately after stowing without a separate bootstrap step.

After stowing, install tmux plugins by pressing `prefix + I` inside a tmux session.

### `oh-my-posh/`

Four prompt themes are included. The active theme is set in `.zshrc`:

| File | Notes |
|------|-------|
| `blue-owl-custom.omp.json` | **Active** — customized version of blue-owl |
| `blue-owl.omp.json` | Upstream base theme |
| `microverse-power.omp.json` | Alternative |
| `tiwahu.omp.json` | Alternative |

To switch themes, update the `--config` path in `zsh/.zshrc`.

### `lsd/`

- **`config.yaml`** — Enables color always, sets a custom color theme.
- **`colors.yml`** — 256-color palette for file type coloring.

### `bin/`

Scripts symlinked into `~/bin/` and available on `$PATH`:

| Script | Description |
|--------|-------------|
| `aaxtractor.sh` | Convert Audible `.aax`/`.aaxc` files to `.m4b` |
| `align.sh` | Library: `right_aligned()` helper for terminal output (source, don't execute) |
| `convert.sh` | Batch convert `.aax` → `.m4b` via ffmpeg |
| `get-gh-repos-for.sh` | Clone or pull all repos for a GitHub user or org |
| `gh-web.sh` | Open the current repo's GitHub page in Brave Browser |
| `git-churn.sh` | Show most frequently changed files across all git history |
| `port-kill.sh` | Kill the process listening on a given TCP port |
| `port-what.sh` | Show the process listening on a given TCP port |
| `sync-to-git.sh` | Initialize/auto-commit a Syncthing-managed directory as a git repo |
| `update-repos.sh` | Pull `master` or `main` for every git repo in subdirectories |
| `xlsx-to-csv.sh` | Convert `.xlsx` to `.csv` using Nushell |
| `aaxclean-cli` | Compiled binary for Audible AAX decryption |

## Adding a New Package

1. Create a top-level directory named after the package (e.g., `ssh/`)
2. Inside it, recreate the path structure as it should appear under `$HOME` (e.g., `ssh/.ssh/config`)
3. Re-run `./install.sh` — the new package is picked up automatically

## Secrets and Local Overrides

Never commit secrets or machine-specific configuration. Use `~/.zshrc.local` instead:

```bash
# ~/.zshrc.local  (not tracked in git)
export GH_TOKEN="your-token-here"
export SOME_API_KEY="..."
```

The `.gitignore` at the repo root excludes `zsh/.zshrc.local` and `.zshrc.local` to prevent accidental commits.
