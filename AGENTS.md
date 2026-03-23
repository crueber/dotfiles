# AGENTS.md — Dotfiles Repository

This repository manages personal dotfiles using **GNU Stow** as the symlink manager.
Every top-level directory is a stow package whose internal tree mirrors `$HOME`.

---

## Repository Structure

```
dotfiles/
├── bin/          → ~/bin/           (utility scripts)
├── extras/                          (non-stow extras with own install scripts; gitignored)
│   └── opencode-extras/             (opencode skills/modes — cloned and symlinked via install.sh)
├── git/          → ~/               (.gitconfig, .gitignore)
├── lsd/          → ~/.config/lsd/   (lsd color config)
├── oh-my-posh/   → ~/.oh-my-posh/   (prompt themes)
├── tmux/         → ~/               (.tmux.conf, .tmux/)
├── zsh/          → ~/               (.zshrc, .aliases)
├── install.sh                       (stow all packages + run extras installs)
├── unstow.sh                        (unstow all packages)
└── check_deps.sh                    (verify/install dependencies)
```

The `extras/` directory is **excluded from stow** and **gitignored**. It contains
external repos that manage their own symlinks via their own `install.sh` scripts.
`install.sh` clones or pulls each one automatically, and `.zshrc.update` re-runs
them after each daily pull.

The `bin/bin/` double-nesting is intentional: the outer `bin/` is the stow package,
the inner `bin/` mirrors `~/bin/` so each script is symlinked individually.

---

## Build / Run Commands

There is no build system or test suite. The primary commands are:

```bash
# Install (stow all packages, auto-backup conflicts)
./install.sh

# Remove all stow-managed symlinks
./unstow.sh

# Check or install dependencies (add --yes to skip prompts)
./check_deps.sh
./check_deps.sh --yes

# Stow a single package manually
stow -d . -t "$HOME" -R -v <package>

# Dry-run stow for a single package (check conflicts without applying)
stow -d . -t "$HOME" -n -v <package>

# Update all git submodules to latest tracked commits
git submodule update --init --recursive

# Update a specific submodule to its latest remote HEAD
git submodule update --remote tmux/.tmux/plugins/<plugin-name>
```

There are no lint, test, or format commands in this repo. `shellcheck` is the
recommended tool for validating shell scripts if available.

---

## Git Submodules

Three tmux plugins are tracked as git submodules:

| Path | Remote |
|---|---|
| `tmux/.tmux/plugins/nord-tmux` | `https://github.com/arcticicestudio/nord-tmux` |
| `tmux/.tmux/plugins/tmux-sensible` | `https://github.com/tmux-plugins/tmux-sensible` |
| `tmux/.tmux/plugins/tmux-themepack` | `https://github.com/jimeh/tmux-themepack` |

`tpm` (the plugin manager) is a full vendored copy — NOT a submodule.

`extras/opencode-extras` is **not a submodule** — it is cloned directly by `install.sh`
from `https://github.com/crueber/opencode-extras` and is gitignored. Do not add it
back as a submodule.

**When committing changes that affect tmux plugins or the tmux package:**
- Always run `git submodule update --init --recursive` before committing to ensure
  submodule pointers are consistent.
- When adding or updating a submodule, commit the updated `.gitmodules` and submodule
  pointer in the same commit.
- Never commit a submodule in a detached-HEAD or dirty state.
- After cloning this repo fresh, run `git submodule update --init --recursive` to
  populate the plugin directories.

---

## Adding a New Package

1. Create a top-level directory named after the tool (e.g., `neovim/`).
2. Mirror the `$HOME` path inside it (e.g., `neovim/.config/nvim/init.lua`).
3. Run `./install.sh` — it discovers packages dynamically; no hardcoded list exists.
4. Commit the new directory.

Excluded directory names (never treated as stow packages): `.git`, `.svn`, `.hg`,
`.github`, `.gitlab`, `node_modules`, `.stow`, `extras`.

---

## Shell Script Style Guidelines

All infrastructure scripts (`install.sh`, `unstow.sh`, `check_deps.sh`) follow these
conventions. New scripts and edits should match them.

### Shebang and Safety Flags

```bash
#!/usr/bin/env bash
set -euo pipefail
```

- Use `#!/usr/bin/env bash` (not `#!/bin/bash`) for portability.
- Always use `set -euo pipefail` on infrastructure scripts.
- Utility scripts under `bin/` may use `#!/bin/bash` or `#!/bin/sh` (POSIX) as
  appropriate; `set -e` is optional there but preferred for new scripts.

### Naming Conventions

- **Global variables / constants:** `SCREAMING_SNAKE_CASE`
- **Local variables and function names:** `lower_snake_case`
- **Script filenames:** `kebab-case.sh`
- **Config/theme filenames:** `kebab-case` with tool-appropriate extensions
  (`.omp.json`, `.tmuxtheme`, `.yaml`)

### Functions

- Keep functions small and single-purpose.
- Guard required commands with a `require()` helper:

```bash
require() {
  command -v "$1" >/dev/null 2>&1 || { echo "Error: '$1' not found" >&2; exit 1; }
}
```

- Check command availability with: `command -v "$cmd" >/dev/null 2>&1`

### Error Handling

- Print errors to stderr: `echo "Error: ..." >&2`
- Exit with non-zero on failure: `exit 1`
- Wrap stow dry-runs in `|| true` so conflict output doesn't abort the script.
- Use `return 0` / `return 1` idiom inside functions.

### Conditionals and Control Flow

- Prefer `case` over complex `if/elif` chains for multi-value tests.
- Use `[ ]` for file/path tests; use `[[ ]]` for string/regex comparisons.
- Use `mapfile -t` to read arrays from command output (not `arr=( $(cmd) )`).

### Argument Handling

- Simple scripts: access args positionally (`$1`, `$2`).
- Scripts with flags: parse manually with `case "$1" in` or use `getopts` for
  anything with more than two options.

### Comments

- File-level: a short block after the shebang describing purpose and strategy.
- Inline: explain *why*, not *what*. Align inline comments where readable.

---

## Configuration File Conventions

### YAML (lsd)
- Lowercase keys, no quoted strings unless necessary.
- Inline `# color-name` comments for color values.

### JSON (oh-my-posh)
- Standard JSON, no comments.
- Schema version 4 for new themes.
- Go template syntax `{{ }}` for dynamic values inside theme strings.

### INI (gitconfig)
- Standard git config format.
- Tabs for indentation under section headers.

### tmux config
- TPM plugin list at the top (`set -g @plugin ...`).
- TPM `run` line at the very bottom of `.tmux.conf` (required by tpm).
- Comment out alternative themes rather than deleting them.

---

## Secrets and Machine-Specific Config

- **Never commit secrets or machine-specific overrides** to this repo.
- `.gitignore` excludes `*.zshrc.local`.
- Machine-specific env vars, tokens, and path overrides go in `~/.zshrc.local`,
  which is sourced automatically by `.zshrc` if it exists.
- `check_deps.sh` reads `$GH_TOKEN` from the environment — never hardcode it.

---

## Dependencies

**Required:** `bash` (4+), `git`, `stow`, `find`, `sort`, `awk`

**Recommended:** `mise`, `oh-my-posh`, `nvim` (LazyVim), `lsd`, `bat`, `lazygit`,
`btop`, `fastfetch`, `tmux`, `tpm`

**Supported package managers:** Homebrew (primary), apt, pacman/yay
