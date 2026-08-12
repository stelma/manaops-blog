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
#   ./scripts/deploy.sh --build-only # build and stop, no connection made
#   ./scripts/deploy.sh --live --delete   # also remove remote files that
#                                         # no longer exist locally
set -euo pipefail

cd "$(dirname "$0")/.."

# Astro needs Node >=22.12. Rather than depend on whatever the shell's nvm
# default happens to be, find a version that qualifies and use it.
select_node() {
	version_ok() {
		local v="${1#v}" maj min rest
		maj="${v%%.*}"
		rest="${v#*.}"
		min="${rest%%.*}"
		[[ -z "$maj" || -z "$min" ]] && return 1
		((maj > 22)) && return 0
		((maj == 22 && min >= 12)) && return 0
		return 1
	}

	if command -v node >/dev/null 2>&1 && version_ok "$(node -v 2>/dev/null)"; then
		return 0
	fi

	local candidates=(/usr/local/bin/node /opt/homebrew/bin/node)
	local nvm_dir="${NVM_DIR:-$HOME/.nvm}"
	if [[ -d "$nvm_dir/versions/node" ]]; then
		local d
		while IFS= read -r d; do
			candidates+=("$d/bin/node")
		done < <(find "$nvm_dir/versions/node" -maxdepth 1 -type d -name 'v*' 2>/dev/null | sort -Vr)
	fi

	local c
	for c in "${candidates[@]}"; do
		if [[ -x "$c" ]] && version_ok "$("$c" -v 2>/dev/null)"; then
			PATH="$(dirname "$c"):$PATH"
			export PATH
			echo "==> Using Node $("$c" -v) from $(dirname "$c")"
			return 0
		fi
	done

	echo "error: Astro needs Node >=22.12.0 and no suitable version was found." >&2
	echo "       Install one with:  nvm install 22" >&2
	exit 1
}

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
BUILD_ONLY=0
for arg in "$@"; do
	case "$arg" in
		--live) LIVE=1 ;;
		--delete) DELETE=1 ;;
		--build-only) BUILD_ONLY=1 ;;
		*) echo "unknown option: $arg" >&2; exit 1 ;;
	esac
done

select_node

echo "==> Building"
npm run build

if [[ $BUILD_ONLY -eq 1 ]]; then
	echo "==> Build complete. Stopping before upload (--build-only)."
	exit 0
fi

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
