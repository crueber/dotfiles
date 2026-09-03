# AGENTS.md — Dotfiles Repository

This repository manages personal dotfiles using **GNU Stow** as the symlink manager.
Every top-level directory is a stow package whose internal tree mirrors `$HOME`.

---

## Repository Structure

```
dotfiles/
├── agents/       → ~/.agents/       (shared agent skills)
├── bin/          → ~/bin/           (utility scripts)
├── extras/                          (non-stow extras; gitignored)
├── git/          (NOT stowed; .gitconfig/.gitignore copied to ~/ if absent)
├── config/       → ~/.config/       (lsd, htop, btop, mise, opencode, nvim, …)
├── oh-my-posh/   → ~/.oh-my-posh/   (prompt themes)
├── zsh/          → ~/               (.zshrc, .zsh_aliases)
├── install.sh                       (stow all packages)
├── unstow.sh                        (unstow all packages)
└── check_deps.sh                    (verify/install dependencies)
```

The `extras/` directory is **excluded from stow** and **gitignored**.

The `bin/bin/` double-nesting is intentional: the outer `bin/` is the stow package,
the inner `bin/` mirrors `~/bin/` so each script is symlinked individually.

---

## Build / Run Commands

There is no build system or test suite. The primary commands are:

```bash
# Install (runs check_deps.sh first, then stow all packages)
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

```

There are no lint, test, or format commands in this repo. `shellcheck` is the
recommended tool for validating shell scripts if available.

`install.sh` always runs `check_deps.sh` before stowing. `check_deps.sh` runs
`mise install --yes` early (shims go on PATH) so mise-managed tools — including
`omp` (oh-my-pi) and `opencode`, declared in `config/.config/mise/config.toml` —
are present before the availability checks run.

## Adding a New Package

1. Create a top-level directory named after the tool (e.g., `neovim/`).
2. Mirror the `$HOME` path inside it (e.g., `neovim/.config/nvim/init.lua`).
3. Run `./install.sh` — it discovers packages dynamically; no hardcoded list exists.
4. Commit the new directory.

Excluded directory names (never treated as stow packages): `.git`, `git`, `.svn`,
`.hg`, `.github`, `.gitlab`, `node_modules`, `.stow`, `extras`. The `git/` package
is special: not stowed, its files copied only if the targets don't exist.

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
  (`.omp.json`, `.yaml`)

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


---

## Secrets and Machine-Specific Config

- **Never commit secrets or machine-specific overrides** to this repo.
- Gitignored local files: `~/.zshrc.local` (sourced by `.zshrc`),
  `~/.gitconfig.local` (included by the repo `.gitconfig` for per-host auth:
  Gitea CA certs, credential helpers), `config/.config/git/` (per-host
  credential helpers/tokens/CAs), `config/.config/gh/hosts.yml`,
  `config/.config/tea/`, `config/.config/collie/`,
  `config/.config/systemd/`, `config/.config/go/telemetry/`, and
  `**/node_modules/`.
- A failed `git add -A` sweep previously nearly committed a GitHub oauth token
  (`gh/hosts.yml`) and a Gitea token (`tea/config.yml`). Always re-scan staged
  diffs for secrets before committing.
- `check_deps.sh` reads `$GH_TOKEN` from the environment — never hardcode it.

---

## Dependencies

**Required:** `bash` (4+), `git`, `stow`, `find`, `sort`, `awk`

**Recommended:** `mise`, `oh-my-posh`, `nvim` (LazyVim), `lsd`, `bat`, `lazygit`,
`btop`, `fastfetch`, `rustnet`, `herdr`

**Supported package managers:** Homebrew (macOS), apt (Debian/Ubuntu), Arch: `paru` > `yay` > `pamac` > `pacman`
