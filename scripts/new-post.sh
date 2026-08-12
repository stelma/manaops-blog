#!/usr/bin/env bash
#
# Scaffold a new blog post.
#
# Usage:
#   ./scripts/new-post.sh "Why the tower stands"
#
# Creates src/content/blog/why-the-tower-stands.md with today's date and
# the frontmatter the content schema requires. The filename becomes the
# URL slug: /blog/why-the-tower-stands/
set -euo pipefail

cd "$(dirname "$0")/.."

if [[ $# -lt 1 ]]; then
	echo "usage: $0 \"Post title\"" >&2
	exit 1
fi

TITLE="$*"

# Lowercase, strip anything that isn't a letter/number, collapse to hyphens.
# -E for extended regex: BSD sed on macOS has no \+ in basic mode.
SLUG=$(printf '%s' "$TITLE" \
	| tr '[:upper:]' '[:lower:]' \
	| sed -E -e 's/[^a-z0-9]+/-/g' -e 's/^-+//' -e 's/-+$//')

if [[ -z "$SLUG" ]]; then
	echo "error: could not derive a filename from that title" >&2
	exit 1
fi

FILE="src/content/blog/${SLUG}.md"

if [[ -e "$FILE" ]]; then
	echo "error: $FILE already exists" >&2
	exit 1
fi

TODAY=$(date +%Y-%m-%d)

# Double-quoted YAML scalars, because prose is full of apostrophes and a
# single-quoted scalar would end at the first one. Backslash first, or the
# second substitution would escape the escapes.
YAML_TITLE=${TITLE//\\/\\\\}
YAML_TITLE=${YAML_TITLE//\"/\\\"}

cat > "$FILE" <<EOF
---
title: "${YAML_TITLE}"
description: ""
pubDate: ${TODAY}
---

EOF

echo "Created $FILE"
echo
echo "Next:"
echo "  1. Write it. 'description' is required — it shows on the blog index."
echo "  2. Preview:  npm run dev"
echo "  3. Publish:  git add -A && git commit -m \"${TITLE}\" && git push"
echo "  4. Deploy:   ./scripts/deploy.sh --live"
