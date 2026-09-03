---
name: tea
description: Use tea CLI for Forgejo and Gitea access - logins, repos, issues, pulls, releases, actions, api. Use when user says tea, forgejo, gitea, or asks to manage pulls/issues on a self-hosted instance.
---

# tea - Forgejo / Gitea CLI

Use `tea` for all Forgejo/Gitea access (e.g. git.packden.us). It is the `gh` equivalent for the Fediverse-forge world. `tea` is repo-context aware: run from inside a checkout when possible.

## 0. Security rules (always follow)

- NEVER print tokens: do NOT `cat ~/.config/tea/config.yml`, `cat` any `config.yml` under `$XDG_CONFIG_HOME/tea`, or echo `$GITEA_TOKEN` / login tokens. Config contains `token:` + `refresh_token:` in plaintext - treat as secret.
- Config file should be mode `600` (`chmod 600 ~/.config/tea/config.yml`). If you see group/other read bits, warn the user and offer to fix - do not broadcast the contents.
- NEVER pass a token as a CLI argument or in a pasted command. Logins are created interactively by the user via `tea login add`; agents only select among existing logins with `--login <name>`. Never invent or request the raw token in chat unless the user explicitly offers rotation.
- Verify read-only first: `tea logins` (lists name/url/user only) and `tea whoami`. If output says `no login matched this repository, falling back to ...`, you are on the wrong login - add `--login <name>` or `--repo <slug>`, do not re-login on your own.
- Least privilege: prefer read commands (`issues list`, `pulls list`, `releases list`) before writes (`create`, `edit`, `merge`, `close`). Confirm destructive/visible actions (merge, close, release create, webhook/admin ops) first.
- `tea api` sends authenticated requests: default to GET. State method + path + payload and confirm before POST/PUT/PATCH/DELETE.
- Avoid `--debug` / `--vvv` in shared logs - it can leak `Authorization` headers.

## 1. Context discovery

```bash
tea logins                        # which instances exist (no secrets)
tea whoami                        # current user for resolved login
git remote -v                     # which remote maps to which login
```

Resolution order: `--login <name>` > `--repo <owner/repo>` > `--remote <remote>` > local git context > default login. In scripts or outside a checkout, always pass `--login` and/or `--repo` explicitly.

## 2. Common workflows

```bash
# Issues
tea issues list --state open --limit 30 -o yaml
tea issues list --repo owner/repo --login git.packden.us
tea issue 12 --comments           # detail view (aliases: i, issues)
tea issues create --title "..." --description "..."
tea issues close 12
tea issues edit 12 --title "..." --assignees user

# Pulls (aliases: pr, pulls, pull)
tea pulls list --state open --limit 30 -o yaml
tea pull 7 --comments --fields index,title,state,author,base,head,diff
tea pulls create --title "..." --description "..." --base main --head feature
tea pulls checkout 7              # local checkout (alias: co)
tea pulls approve 7               # lgtm
tea pulls reject 7                # request changes
tea pulls merge 7                 # confirm type/strategy first
tea pulls review-comments 7
tea pulls clean 7                 # delete feature branch after close

# Repos / releases / misc
tea repos list --limit 30
tea releases list --repo owner/repo
tea labels --repo owner/repo
tea notifications --login git.packden.us
tea open --repo owner/repo        # print/open web URL (no browser in agent)
tea api /repos/owner/repo --login git.packden.us  # GET by default
```

Output formats: `-o simple|table|csv|tsv|yaml|json`. Prefer `-o yaml`/`-o json` for scripting; use `-f/--fields` to limit columns (e.g. `--fields index,title,state,author`).

## 3. Responding to issues and pulls

Golden rule: read everything before writing anything: detail view with
`--comments` + `diff`/`patch` field + review-comments. Never approve/merge on title alone.

Responding to issues:
```bash
tea issue 12 --comments
tea comments list 12 -o yaml --login <name> --repo owner/repo
```
- Triage first: bug vs feature vs question? Reproducible? Ask for version, steps, expected/actual, logs if missing. Relabel via `tea issues edit 12 --add-labels bug,...` / assignees via `--add-assignees user` (confirm names with `tea labels`).
- Response shape: acknowledge + what you checked + next step or fix. Reference with `Closes #12` in the PR description, not in a drive-by comment.
- Closing: post the reason as a comment first (`tea comments add 12 "..."` or `tea comments add 12 --description "..."`), then `tea issues close 12` (or `reopen`). Confirm with user before closing someone else's issue.
- Never paste secrets from logs - redact first. Use quoted `--description` / positional body defensively.

Responding to pulls:
```bash
tea pull 7 --comments --fields index,title,state,author,base,head,diff
tea pulls review-comments 7 -o yaml
tea pulls checkout 7   # only if you must test locally
```
- Review flow: `diff` field -> `review-comments` thread -> checkout only if needed. Note `tea pulls review <idx>` is interactive - agents should NOT run it; use `approve`/`reject`/comments instead.
- Three response levels, pick deliberately (confirm with user which is wanted):
  - `tea comments add 7 "question or nit..."` : discussion only, no verdict.
  - `tea pulls reply 7 <comment-id> "answer..."` : threaded reply to a specific review comment (get IDs from `review-comments`).
  - `tea pulls approve 7` (lgtm) vs `tea pulls reject 7` : formal verdict with a prior comment explaining specifics (file/line, quoted hunk, suggested fix). Separate must-fix from nits.
- Housekeeping: `tea pulls resolve <comment-id>` / `unresolve <comment-id>` after follow-ups (takes comment ID only); `tea pulls edit 7 --title ... --add-assignees user --add-labels bug` for metadata; `tea pulls clean 7` after close to drop the feature branch.
- Merging: only after approval + green checks; confirm style with user before `tea pulls merge 7 --style squash|merge|rebase|rebase-merge`.

## 4. Setup (user-driven, confirm first)

```bash
tea login add                     # interactive - user runs, never script tokens
tea logout --login <name>         # destructive - confirm
```

Never run `tea login add --token <value>` with a literal token on the command line.

## 5. Common errors

- `no login matched this repository, falling back to ...` -> wrong instance; add `--login <name>` / `--repo <slug>`.
- `404 / 401` on `tea api` or list -> token expired or lacks scope; ask user to re-login, do not dump config.
- Empty list with `--state open` -> try `--state all|closed`.
