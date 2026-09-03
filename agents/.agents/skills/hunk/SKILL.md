---
name: hunk
description: Do local code reviews with hunk terminal diff viewer via live session CLI. Use when user says hunk, local code review, review diff, walk through changeset, or annotate hunks.
---

# hunk - Local Code Review

Hunk is a local-only interactive diff viewer. The TUI is for the USER - agents must never run blocking interactive commands (`hunk diff`, `hunk show`, `hunk pager`, `hunk patch` without piped input) directly in the agent shell. Drive a live session via `hunk session *` through the local daemon instead.

Bundled reference (read-only, do not duplicate): `hunk skill path` prints `.../skills/hunk-review/SKILL.md` with the full session protocol.

## 0. Security rules (always follow)

- Local-only by design: hunk talks to `localhost` daemon, no cloud upload. Keep it that way - do NOT pipe diffs containing secrets/keys/tokens to external tools, webfetch, or issue comments. Redact secrets before quoting diffs elsewhere.
- NEVER `cat` or paste credential files spotted in a diff (`hosts.yml`, `config.yml`, `*.pem`, `.env`) - flag and skip them.
- Session commands are read-then-write: inspect (`list`, `get`, `review --json`) before mutating (`reload`, `comment add/apply/clear`, `highlight clear`). `comment clear --all` and `highlight clear` are destructive - confirm first.
- `hunk session reload -- <command>` executes a diff command - only pass trusted `diff`/`show` invocations with explicit refs/paths; never interpolate untrusted branch names without quoting.
- If `hunk session list` reports `No active Hunk sessions` yet the user says Hunk is open, it is likely a sandbox/network block on localhost - retry once, then ask the user to check, do not launch `hunk diff` yourself (it blocks).

## 1. Workflow (agent-safe)

```text
1. hunk session list [--json]                  # find live sessions; if none, ask user to open Hunk
2. hunk session get --repo .                   # confirm Path / Repo / Source
3. hunk session review --repo . --json         # file/hunk structure WITHOUT patch (cheap)
4. hunk session review --repo . --include-patch --json  # raw diff only for files you need
5. hunk session context --repo . --json        # where the user is looking
6. hunk session navigate --repo . --file <p> (--hunk N | --new-line N | --old-line N)
7. hunk session reload --repo . -- diff ...    # swap content if needed (note `--`)
8. hunk session comment add ... / comment apply --stdin   # annotate (one vs batch)
9. hunk session highlight add ...              # light up exact range while narrating
```

Select session by `--repo <path>` (most common) or `<session-id>` when several share a repo. `--json` for scripting.

## 2. Key commands

```bash
hunk session list --json
hunk session get --repo .
hunk session context --repo . --json
hunk session review --repo . --json
hunk session navigate --repo . --file src/App.tsx --hunk 2
hunk session navigate --repo . --file src/App.tsx --new-line 372
hunk session comment add --repo . --file README.md --new-line 103 --summary "Tighten this wording"
printf '%s\n' '{"comments":[{"filePath":"README.md","newLine":103,"summary":"Tighten this wording"}]}' | hunk session comment apply --repo . --stdin
hunk session highlight add --repo . --file src/App.tsx --new-line 42 --start 6 --end 19 --tone warning --focus
hunk session reload --repo . -- diff main...feature -- src/ui
hunk session reload --repo . -- show HEAD~1
```

- `comment add` needs `--file`, `--summary`, exactly one of `--old-line`/`--new-line`. Batch path: `comment apply --stdin` with `filePath` + `summary` + one target (`hunk`/`hunkNumber`/`oldLine`/`newLine`).
- `highlight add` needs `--file`, one of `--old-line`/`--new-line`, `--start`/`--end` as 0-based inclusive/exclusive UTF-16 offsets. Tones: `match|info|warning|error|dim|current`.
- Untracked files appear by default; `reload -- diff --exclude-untracked` for tracked-only.

## 3. No live session? Fall back without blocking

Do NOT launch `hunk diff` to fix it. Instead:

1. Tell the user: "Open Hunk in your terminal (`hunk diff` / `hunk show`), then I'll drive the review."
2. Meanwhile review with plain git: `git status --short`, `git diff --stat`, `git diff main...HEAD -- <path>` - summarize intent, risks, follow-ups without faking Hunk comments.

## 4. Review guidance

- Navigate before commenting so the user sees what you discuss; use `--focus` sparingly.
- Prefer one `comment apply` batch over many `comment add` calls; keep notes on intent/structure/risks, not every hunk.
- Pair visual-only highlights with a persisted `comment add` when the point must stick.
- STML rich markup (`--markup`) ONLY when `session context --json` lists `stml` in `experimentalFeatures`; first run `hunk markup guide` and preview with `hunk markup render`.
