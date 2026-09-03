---
name: gh
description: Use gh CLI for GitHub access - auth, repos, issues, PRs, releases, actions, api. Use when user says gh, GitHub CLI, github.com, or asks to list/create/view/merge PRs and issues.
---

# gh - GitHub CLI

Use `gh` for all github.com access. Prefer `gh` over `git` remotes, curl, or browser instructions.

## 0. Security rules (always follow)

- NEVER print, log, or exfiltrate tokens: do NOT run `gh auth token`, `cat ~/.config/gh/hosts.yml`, `gh config get`, or `env | grep -i token` to show secrets. `hosts.yml` must stay mode `600`.
- NEVER pass a token as a CLI argument (visible in `ps`, shell history). For auth, use `gh auth login` (interactive, user runs) or `GH_TOKEN` / `GITHUB_TOKEN` env var piped via stdin (`echo "$TOKEN" | gh auth login --with-token` is user-only; agents must ask, never invent tokens).
- NEVER run `gh auth refresh`, `gh auth logout`, or change `git` protocol without explicit user confirmation.
- Verify auth read-only first: `gh auth status`. It redacts the token (`ghp_****`). If it fails, stop and ask the user to re-login - do not retry with flags like `--with-token` on your own.
- Least privilege: prefer read commands (`view`, `list`, `status`, `diff`, `checks`) before any write (`create`, `comment`, `merge`, `close`, `edit`). Confirm destructive/visible actions (merge, close, release publish, secret/variable set) with the user first.
- `gh api` is powerful: default to `GET`. For `POST/PUT/PATCH/DELETE`, state the exact endpoint + payload and get confirmation. Never dump secrets via `gh secret list` values or `gh api ...secrets` plaintext.
- Avoid `--debug` / `GH_DEBUG=1` in shared logs - it can leak headers.

## 1. Context discovery

```bash
gh auth status                          # who is logged in, protocol
gh repo view --json nameWithOwner,url --jq .  # current repo (fails outside a repo - then require -R)
gh pr status --json title,number,headRefName  # quick PR context
```

Always scope with `-R [HOST/]OWNER/REPO` when outside the repo dir or operating on another repo.

## 2. Common workflows

```bash
# Issues / PRs - read first
gh issue list --limit 30 --json number,title,state,labels,updatedAt
gh issue view 123 --comments
gh pr list --limit 30 --json number,title,state,author,checks
gh pr view 123 --comments             # add --json for scripting
gh pr diff 123                        # review changes without checkout
gh pr checks 123
gh pr status

# Write (confirm first)
gh issue create --title "..." --body "..."
gh pr create --fill                   # or --title/--body, --draft
gh pr comment 123 --body "..."
gh pr review 123 --approve --body "..."   # --request-changes / --comment
gh pr merge 123 --squash --delete-branch  # --merge/--rebase variants
gh pr checkout 123

# Repos / releases / actions
gh repo view OWNER/REPO --json url,defaultBranchRef
gh repo clone OWNER/REPO
gh release list --limit 10
gh release view v1.2.3
gh run list --limit 20
gh run view RUN_ID --log-failed
gh workflow list
gh search repos "topic:cli stars:>1000" --limit 10
gh browse --repo OWNER/REPO --no-browser  # print URL only
```

## 3. Responding to issues and PRs

Golden rule: read everything before writing anything:
`view --comments` + `diff` + `checks`. Never approve/merge on title alone.

Responding to issues:
```bash
gh issue view 123 --comments
gh issue list --label "needs-triage" --limit 20 --json number,title,labels
```
- Triage first: bug vs feature vs question? Reproducible? Ask for version, steps, expected/actual, logs if missing. Apply labels via `gh issue edit 123 --add-label "bug"` (confirm label names with `gh label list`).
- Response shape: acknowledge + what you checked + next step or fix. Link related code/PRs (`Closes #123` in PR body, not in a comment).
- Closing: explain why in one step with `gh issue close 123 --comment "..." --reason "completed"` (or `"not planned"`). Confirm with user before closing someone else's issue.
- Posting: `gh issue comment 123 --body "..."` or `--body-file -` (stdin, best for multiline, avoids shell quoting). Never paste secrets from logs - redact first.

Responding to PRs:
```bash
gh pr view 123 --comments
gh pr diff 123
gh pr checks 123
```
- Review flow: diff -> checks -> comments thread -> local checkout (`gh pr checkout 123`) only if you must test. Check CI status; if failing, point at `gh run view --log-failed` output.
- Three response levels, pick deliberately (confirm with user which is wanted):
  - `gh pr comment 123 --body "..."` : discussion only, no verdict.
  - `gh pr review 123 --comment -b "..."` : formal review without approval.
  - `gh pr review 123 --approve -b "LGTM, ..."` vs `gh pr review 123 -r -b "..."` : approval or request-changes with specific file/line refs and suggested fix.
- Be specific: cite `file:line`, quote the hunk, propose the change, separate must-fix from nits. One review per round; use `--edit-last` to fix your own typo, not to change a verdict silently.
- Merging: only after approval + green checks; confirm strategy with user (`--squash` vs `--merge` vs `--rebase`, plus `--delete-branch`).

## 4. Scripting

- Use `--json <fields> --jq <expr>` for machine output; avoid scraping human tables.
- Example: `gh pr list --json number,title,headRefName --jq '.[] | "\(.number) \(.title)"'`
- For `gh api`: `gh api repos/OWNER/REPO/pulls/123 --jq .title` (GET). Quote payloads defensively.

## 5. Common errors

- `failed to run git: not a git repository` -> add `-R OWNER/REPO` or cd to checkout.
- `Resource not accessible by integration` -> token lacks scope; ask user to `gh auth refresh -s <scope>` themselves.
- `PR ... not found` -> PR may be by head-branch name; use number or URL.
