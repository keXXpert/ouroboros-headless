# Contributing (Fork Policy)

This repository is a deployment-focused fork of
[`joi-lab/ouroboros-desktop`](https://github.com/joi-lab/ouroboros-desktop).

## Branch policy

- `main` is the fork production branch.
- Upstream sync target is `upstream/main`.
- Keep fork-specific changes isolated to:
  - `deploy/docker/**`
  - fork governance docs (`README.md`, `FORK.md`, this file)

## Upstream sync workflow

```bash
git remote add upstream https://github.com/joi-lab/ouroboros-desktop.git
git fetch upstream
git checkout -b upstream-sync/<date> main
git merge upstream/main
```

For shared files, prefer upstream behavior and re-apply fork deltas minimally.

## PR expectations

- Keep PRs narrow and scoped.
- For deploy changes, ensure `Deploy VPS CI` workflow is green.
- Use immutable refs (tag/commit) in docs and operational examples where possible.
