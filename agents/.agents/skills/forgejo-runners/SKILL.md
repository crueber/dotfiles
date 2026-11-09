---
name: forgejo-runners
description: Build .forgejo/workflows CI for git.packden.us runners - labels, containers, docker builds, contexts, secrets, and log debugging. Use when writing or fixing Forgejo Actions workflows on this instance.
---

# Forgejo runners (git.packden.us)

Probed 2026-11-09 against `crueber/roundtable`. Four idle runners
(`pve-swarm2-runner`, `-r2`, `pve-swarm3-runner-r1`, `-r2`, v13.2.1) with labels
`docker`, `ubuntu-latest`, `linux_amd64`. There is NO `docker` runs-on label
as a job selector quirk: `runs-on: docker` never matches; always use
`runs-on: ubuntu-latest`.

## 1. Execution model (the cause of most failures)

- Every job's steps execute INSIDE a `node:20-bookworm` container unless the
  job sets its own `container:`. That container has node (JS actions work) but
  NO `docker` CLI and no Go toolchain.
- The Docker daemon socket IS shared from the host, so once a client exists,
  `docker build/push` works from `run:` steps.
- Do NOT set job-level `container:` to a slim image (e.g.
  `golang:1.27-alpine`): node-based actions such as `actions/checkout@v4`
  then fail with `exec: "node": executable file not found in $PATH`.
  Install toolchains on top of the default container instead
  (`actions/setup-go@v5` works on the host-side setup and is fine).

## 2. Workflow template that works

```yaml
name: CI
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      - name: Setup Go
        uses: actions/setup-go@v5
        with:
          go-version: '1.27'
      - name: Vet
        run: go vet ./...
      - name: Test
        run: go test ./...
  release:
    runs-on: ubuntu-latest
    needs: test
    if: github.ref == 'refs/heads/main'
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      - name: Install buildah
        # No docker daemon in job containers (no socket), so build
        # daemonless; vfs driver works unprivileged.
        run: |
          if ! command -v buildah >/dev/null; then
            apt-get update && apt-get install -y buildah
            mkdir -p /etc/containers
            printf '[storage]\ndriver="vfs"\n' > /etc/containers/storage.conf
          fi
          buildah --version
      - name: Build image
        run: |
          buildah bud -t git.packden.us/<owner>/<repo>:${{ github.sha }} -t git.packden.us/<owner>/<repo>:latest .
      - name: Push image
        run: |
          if [ -z "${{ secrets.REGISTRY_USER }}" ] || [ -z "${{ secrets.REGISTRY_PASSWORD }}" ]; then
            echo "REGISTRY_USER/REGISTRY_PASSWORD secrets not set; skipping push."
            exit 0
          fi
          buildah login --username "${{ secrets.REGISTRY_USER }}" --password "${{ secrets.REGISTRY_PASSWORD }}" git.packden.us
          buildah push git.packden.us/<owner>/<repo>:${{ github.sha }}
          buildah push git.packden.us/<owner>/<repo>:latest
```

## 3. Hard rules

- Contexts are `github.*` (`github.ref`, `github.sha`). `gitea.*` fails
  schema validation: `Unknown Variable Access gitea`, `workflow file is not
  usable`. The docker `/*` JS actions (`login-action`, `build-push-action`)
  fail here with `Unable to locate executable file: docker`; use host-docker
  `run:` steps per the template instead.
- Write steps expanded (`- name:` / `uses:` / `run:` / `with:` on own lines),
  not flow-style (`- {uses: ...}`). The parser is picky; expanded form matches
  known-good workflows (e.g. freedom-maps).
- `go.mod` floor must fit available toolchains: `golang:1.27-alpine` ships
  go 1.27.1, so `go 1.27.3` in go.mod breaks local `docker build`. Keep the
  floor at `go 1.27` (runner installs 1.27.3 via setup-go, fine either way).
- Do NOT `apt-get install docker.io` in the job container: it drags a daemon,
  iptables and dbus and fails on post-install triggers. There is also NO
  daemon socket (`/var/run/docker.sock`) in jobs, so a docker CLI alone
  fails with `Cannot connect to the Docker daemon`. Build daemonless with
  buildah (vfs driver) per the template.
- Images land in the Forgejo package (container) registry at
  `git.packden.us/<owner>/<repo>:<tag>`.

## 4. Secrets

- Repo-level: `tea actions secrets add --repo owner/repo NAME` (values are
  never listed back; `tea actions secrets list` shows names only).
- The `release` template pushes only when `REGISTRY_USER`/`REGISTRY_PASSWORD`
  exist; otherwise it logs `skipping push` and stays green. Ask the operator
  to add them (user can add at account level per 2026-11-09; repo-level is the
  verified path).
- NEVER print tokens: read the token from `~/.config/tea/config.yml` only via
  `awk` into a shell variable for `curl -H "Authorization: token $TOKEN"`;
  never `cat` the file or echo the value. See the `tea` skill security rules.

## 5. Debugging runs (tea is half-broken here)

- `tea actions runs list --repo owner/repo` works for status. `tea actions
  runs logs|view` FAILS (`json: cannot unmarshal array ...`) — do not retry it.
- Use the API directly (token via awk as above):
  - List: `GET /api/v1/repos/<owner>/<repo>/actions/runs?limit=1`
  - Jobs: `GET .../actions/runs/<run>/jobs` (name + status per job).
  - Logs: `GET .../actions/runs/<run>/logs` downloads a zip with
    `<job>-<id>-attempt-1.log` files; `unzip -o` then grep.
- Runners (admin token): `GET /api/v1/admin/actions/runners` lists names,
  status and labels. Repo endpoint returns `[]`; that is normal.
- Expect slow first builds: `modernc.org/sqlite` cold compile is ~10 min and
  `setup-go` cache-save `tar` stalls the log tail with no new lines — the job
  is still working. `go vet`/`go test` emit nothing until done.
- Failure signatures seen: `exec: "node": executable file not found` (bad
  `container:`), `Unknown Variable Access gitea` (bad context), `docker:
  command not found` in `/var/run/act/workflow/N.sh` (missing CLI install),
  `Unable to locate executable file: docker` (docker/* JS action).
