---
name: request-opencode-code-review
description: Request a code review from opencode via opencode run. Use when the omp harness or user says omp review, request opencode review, review diff/PR/branch/worktree, and needs a structured verdict plus findings.
---

# Request Opencode Code Review

This skill runs inside **opencode**. The **omp harness** invokes it via
`opencode run` with a diff or file set attached. Perform a read-only,
language-agnostic code review and print a stable, machine-parseable result
that omp can parse.

## 0. Security and scope rules (always follow)

- Read-only by default: inspect with `read`, `glob`, `grep`, `bash` (for
  `git diff` / `git status` / test commands only). Do NOT edit, commit,
  merge, push, or publish a review to a forge without explicit instruction.
- NEVER print, log, or exfiltrate tokens or secrets. Redact suspected
  secrets in quoted code. Never `cat` credential files or dump env.
- Review what is attached or checked out — do not walk the whole fleet or
  network. A test that needs the network or a real provider login is out
  of scope; say so instead of failing silently.

## 1. omp -> opencode invocation contract

omp invokes opencode non-interactively with `opencode run`. The review
request arrives as the message plus attached files. Supported shapes:

```bash
# Review uncommitted / branch changes in a repo
opencode run "Use request-opencode-code-review: review uncommitted changes" --dir /path/to/repo

# Review an explicit diff file (preferred for large or generated diffs)
git diff main...HEAD > /tmp/review.patch
opencode run "Use request-opencode-code-review: review the attached diff" -f /tmp/review.patch --dir /path/to/repo

# Review with CI/check output attached
opencode run "Use request-opencode-code-review: review HEAD vs main" -f /tmp/review.patch -f /tmp/checks.log --dir /path/to/repo

# Machine-readable transport (omp parses stdout as JSON events)
opencode run --format json "Use request-opencode-code-review: review uncommitted changes" --dir /path/to/repo
```

Useful flags: `message` positional (the request), `-f/--file` (repeatable
attachments), `--dir` (repo to review in), `--format default|json`,
`--title`, `-m/--model`, `--agent`. Do not invent other flags.

## 2. Request parsing (what omp sends)

Extract from the message + attachments:

1. **Target**: uncommitted changes, branch vs base (`main...HEAD`), a
   patch file, a PR number/URL, or an explicit file list. If ambiguous,
   run `git status --short` and `git log --oneline -5` in `--dir` to infer.
2. **Base/head**: default base is the merge-base with `main` (or `master`
   if `main` is absent). Prefer the attached diff over re-deriving it.
3. **Checks**: attached test/lint/CI output, if any. Treat failing checks
   as must-mention.
4. **Scope hint**: full review vs focused question (security, correctness,
   perf). Default to full review.

If there is no diff and the tree is clean, say so and stop: print
`VERDICT: CLEAN` with an empty findings list.

## 3. Review procedure

1. **Get the diff first**: prefer the `-f` attachment. Otherwise:
   ```bash
   git status --short
   git diff --stat
   git diff -- main...HEAD  # or plain `git diff` for uncommitted changes
   ```
2. **Read every changed hunk** plus enough surrounding context (the full
   function, not just the hunk). Use `read` on each changed file.
3. **Check tests/checks**: if checks are attached, read them. Otherwise
   run only the cheap, local signal that the repo advertises (e.g.
   language formatter/linter on changed files). Do not install deps or
   hit the network.
4. **Judge against the rubric** (§4), not personal style. Separate
   must-fix from opinion. One finding per real issue; do not repeat the
   same point per occurrence — list all locations under one finding.
5. **Write the output** exactly per §5. Nothing outside the contract
   except the findings themselves.

## 4. Rubric (language-agnostic)

- **Correctness**: logic errors, off-by-one, error-path handling, API
  misuse, broken edge cases, data races / async hazards.
- **Security**: injection, auth/authz gaps, secret handling, unsafe
  deserialization, path traversal, SSRF, over-broad permissions.
- **Scope discipline**: unrelated drive-by changes, dead code, debug
  leftovers, TODOs without owners.
- **Tests**: missing coverage for the change, flaky patterns, assertions
  that cannot fail.
- **Readability/maintainability**: naming, control-flow clarity, error
  messages a future reader can act on.
- **Performance**: algorithmic regressions, N+1 patterns, unbounded work
  on hot paths. Flag only with evidence, not speculation.

Severity levels: `MUST-FIX` (ship-blocker), `SHOULD-FIX` (fix or justify),
`NIT` (optional polish). No other severities.

## 5. Output contract (stable for omp parsing)

Print exactly this shape in `default` format (Markdown). Keep the
`VERDICT:` first line byte-stable — omp greps for it:

```markdown
VERDICT: APPROVE | REQUEST-CHANGES | CLEAN
SUMMARY: <2-4 sentences: what changed, overall state, biggest risk>
CHANGED: <n> files, +<a>/−<d> (or `unknown` if no diffstat available)
CHECKS: <pass|fail|not-run|not-provided> — <one-line detail>

FINDINGS:
- [MUST-FIX] path/to/file:line — <title>
  <1-3 sentences: why it matters, evidence from the diff>
  Suggestion: <concrete fix or diff sketch>
- [SHOULD-FIX] path/to/file:line — <title>
  ...
- [NIT] path/to/file:line — <title>
  ...
(no findings: write `(none)` under FINDINGS:)

TEST-NOTES: <what checks were read/run and their result, or what to run next>
```

Rules: `APPROVE` means no MUST-FIX; `REQUEST-CHANGES` means ≥1 MUST-FIX;
`CLEAN` means no diff at all. Cite `file:line` from the new side of the
diff. Quote the hunk briefly when the title alone is ambiguous.

## 6. Common errors

- Empty review on a dirty tree -> you read the wrong `--dir` or ignored
  the `-f` attachment. Re-check `pwd` / `git status` before concluding.
- `not a git repository` -> the `--dir` is wrong; review the attached
  files literally and mark `CHECKS: not-provided`.
- Huge diff (>~500 lines): review the full diff once, then go deep on
  the riskiest files (security, concurrency, migrations, public APIs).
  Say explicitly what was skimmed.
