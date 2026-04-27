#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/common.sh"

ALLOW_DIRTY=0
TARGET_REF=""
ROLLBACK=0

usage() {
  cat <<'EOF'
Usage: update.sh [options]

Options:
  --ref <tag|commit|branch>  Deploy explicit target ref.
  --rollback                 Deploy previously recorded ref.
  --allow-dirty              Allow update with dirty tracked tree.
  -h, --help                 Show this help.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --ref) TARGET_REF="${2:-}"; shift 2 ;;
    --rollback) ROLLBACK=1; shift ;;
    --allow-dirty) ALLOW_DIRTY=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) die "Unknown argument: $1" ;;
  esac
done

require_root
validate_compose_runtime
[[ -d "${REPO_DIR}/.git" ]] || die "Repository not found at ${REPO_DIR}."
[[ -f "${ENV_FILE}" ]] || die "Missing env file ${ENV_FILE}."
validate_security_contracts

if [[ "${ALLOW_DIRTY}" != "1" ]]; then
  [[ -z "$(git -C "${REPO_DIR}" status --porcelain)" ]] || die "Working tree is dirty. Commit/stash or pass --allow-dirty."
fi

current_ref="$(git_ref)"
prior_previous_ref="$(cat "${DEPLOY_META_DIR}/previous_ref" 2>/dev/null || true)"

if [[ "${ROLLBACK}" == "1" ]]; then
  [[ -n "${prior_previous_ref}" ]] || die "No previous ref recorded for rollback."
  TARGET_REF="${prior_previous_ref}"
  info "Rollback requested. Target ref: ${TARGET_REF}"
fi

[[ -n "${TARGET_REF}" ]] || die "Provide --ref or --rollback."

fetch_deploy_remote
resolved_ref="$(resolve_checkout_ref "${TARGET_REF}")"
git -C "${REPO_DIR}" checkout "${resolved_ref}"

info "Applying update (explicit update-time build)."
compose up -d --build

port="$(effective_server_port)"
if ! wait_for_health "${port}" 30 2; then
  warn "Health check failed after update. Attempting automatic rollback to ${current_ref}."
  git -C "${REPO_DIR}" checkout "${current_ref}"
  compose up -d --build

  rollback_port="$(effective_server_port)"
  if ! wait_for_health "${rollback_port}" 30 2; then
    printf '%s\n' "${TARGET_REF}" > "${DEPLOY_META_DIR}/last_failed_ref"
    die "Rollback recovery failed. Service still unhealthy on ${current_ref}. Manual intervention required. Failed ref: ${TARGET_REF}"
  fi

  printf '%s\n' "${TARGET_REF}" > "${DEPLOY_META_DIR}/last_failed_ref"
  record_ref_metadata "${current_ref}" "${prior_previous_ref}"
  die "Update to ${TARGET_REF} failed (health check). Service reverted to ${current_ref}. See ${DEPLOY_META_DIR}/last_failed_ref."
fi

new_ref="$(git_ref)"
next_previous_ref="${current_ref}"
if [[ "${ROLLBACK}" == "1" ]]; then
  # Keep previous_ref pinned to known-good marker; avoid rollback chain oscillation.
  next_previous_ref="${prior_previous_ref}"
fi
record_ref_metadata "${new_ref}" "${next_previous_ref}"

cat <<EOF
[DONE] Deployment updated.
Current ref: ${new_ref}
Previous ref marker: ${next_previous_ref:-<unset>}
Timestamp: $(cat "${DEPLOY_META_DIR}/last_deploy_utc")
EOF
