# Changelog (fork: keXXpert/ouroboros-headless)

This file tracks fork-specific releases. Each entry records the upstream base commit/tag and the fork-only changes.

Upstream changelog lives at [joi-lab/ouroboros-desktop](https://github.com/joi-lab/ouroboros-desktop).

---

## [Unreleased] — headless docker-host deploy profile

**Upstream base:** `76bf13c` (`fix(build): use headless-shell Chromium on macOS`)

**Fork-only changes:**

- `deploy/docker/` — deployment script surface: `install.sh`, `update.sh`, `backup.sh`, `restore.sh`, `doctor.sh`, `enable-browser-tools.sh`, `common.sh`
- `deploy/docker/docker-compose.vps.yml` — VPS-oriented compose: lean-by-default browser profile, log rotation, healthcheck with effective-port detection
- `deploy/docker/ouroboros-headless.service` — systemd unit with health gate and restart policy
- `deploy/docker/.env.example` — operator env template
- `deploy/docker/README.md` — operator quickstart
- `Dockerfile` — `OUROBOROS_INSTALL_BROWSER_TOOLS` build arg (lean VPS default, backward-compatible)
- `.gitignore` — unignore `deploy/docker/.env.example`, ignore `.deploy/` local runtime metadata
- `README.md` — fork notice at top, Headless VPS section
- `FORK.md` — upstream sync policy, remote topology, release tag convention
- `CONTRIBUTING.md` — fork PR expectations and sync workflow
- `.github/workflows/deploy-docker-ci.yml` — CI checks for `deploy/docker/**` scripts and compose

**Planned tag:** `v4.44.0-headless.1`

---

## Format

Entries use the format:

```
## [fork-tag] — short title
Upstream base: <commit-or-tag>
Fork-only changes: <bullet list>
```

Fork tags follow `vX.Y.Z-headless.N` where `X.Y.Z` matches the upstream base version.
