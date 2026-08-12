#!/usr/bin/env bash
#
# Build the site and sync it to IONOS webhosting over SSH.
#
# Config comes from .deploy.env (gitignored) so no host details or
# credentials ever land in the repository. Copy .deploy.env.example to
# .deploy.env and fill it in.
#
# Usage:
#   ./scripts/deploy.sh              # dry run — shows what WOULD change
#   ./scripts/deploy.sh --live       # actually upload
#   ./scripts/deploy.sh --live --delete   # also remove remote files that
#                                         # no longer exist locally
set -euo pipefail

cd "$(dirname "$0")/.."

if [[ ! -f .deploy.env ]]; then
	echo "error: .deploy.env not found. Copy .deploy.env.example and fill it in." >&2
	exit 1
fi

# shellcheck disable=SC1091
source .deploy.env

: "${SSH_HOST:?set SSH_HOST in .deploy.env}"
: "${SSH_USER:?set SSH_USER in .deploy.env}"
: "${REMOTE_DIR:?set REMOTE_DIR in .deploy.env}"
SSH_PORT="${SSH_PORT:-22}"

LIVE=0
DELETE=0
for arg in "$@"; do
	case "$arg" in
		--live) LIVE=1 ;;
		--delete) DELETE=1 ;;
		*) echo "unknown option: $arg" >&2; exit 1 ;;
	esac
done

echo "==> Building"
npm run build

RSYNC_ARGS=(-rlvz --human-readable --checksum -e "ssh -p ${SSH_PORT}")

if [[ $DELETE -eq 1 ]]; then
	# Only ever prunes inside REMOTE_DIR. Check that path carefully before
	# using this — it removes anything there that the build did not produce.
	RSYNC_ARGS+=(--delete)
fi

if [[ $LIVE -eq 0 ]]; then
	RSYNC_ARGS+=(--dry-run)
	echo "==> DRY RUN (no changes will be made). Re-run with --live to upload."
fi

echo "==> Syncing dist/ -> ${SSH_USER}@${SSH_HOST}:${REMOTE_DIR}"
rsync "${RSYNC_ARGS[@]}" dist/ "${SSH_USER}@${SSH_HOST}:${REMOTE_DIR}"

if [[ $LIVE -eq 0 ]]; then
	echo "==> Dry run complete. Nothing was uploaded."
else
	echo "==> Deployed."
fi
