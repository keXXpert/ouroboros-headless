# Fork Maintenance Guide

This repository is a regular fork of [joi-lab/ouroboros-desktop](https://github.com/joi-lab/ouroboros-desktop) with deployment-focused additions for headless VPS operations.

## Remotes

- `origin` -> `keXXpert/ouroboros-headless`
- `upstream` -> `joi-lab/ouroboros-desktop`

One-time setup:

```bash
git remote -v
git remote add upstream https://github.com/joi-lab/ouroboros-desktop.git
git fetch upstream
```

Branch policy:

- `main` tracks fork production branch.
- upstream sync target is `upstream/main`.
- VPS/fork-specific work stays isolated under `deploy/docker/**` and fork governance docs.

## Sync workflow

```bash
git fetch upstream
git checkout -b upstream-sync/<date> main
git merge upstream/main
```

Conflict policy:

- Keep fork-owned surfaces:
  - `deploy/docker/**`
  - fork governance docs
- For shared files, prefer upstream behavior and re-apply fork deltas minimally.

After merge:

```bash
make test
git checkout main
git merge upstream-sync/<date>
```

Contributor expectations for fork-scoped changes are documented in `CONTRIBUTING.md`.

## Release policy

- Prefer immutable deployment refs (`tag` or `commit`) for production.
- Record deployed refs in `/opt/ouroboros-headless/.deploy`.
- Use fork tags like `vX.Y.Z-headless.N` for fork-specific releases.
