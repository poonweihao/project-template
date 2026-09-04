#!/usr/bin/env bash
# Refuse to commit content matching a private denylist of work identifiers.
#
# The denylist is NEVER committed: a list of the terms you are hiding is itself a
# disclosure. It is read from the first of these that exists:
#   $PUBLIC_DENYLIST_FILE
#   ~/.config/public-denylist
#   <one directory above the repo>/.public-denylist   (covers a folder of repos)
#   ./.public-denylist                                (gitignored)
#
# Format: one extended-regex per line. Blank lines and lines starting with # ignored.
# No list found means the check passes with a warning - a fresh clone of this template
# is not blocked from committing.
set -uo pipefail

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

list=""
for candidate in \
  "${PUBLIC_DENYLIST_FILE:-}" \
  "$HOME/.config/public-denylist" \
  "$(dirname "$repo_root")/.public-denylist" \
  "$repo_root/.public-denylist"
do
  if [ -n "$candidate" ] && [ -f "$candidate" ]; then list="$candidate"; break; fi
done

if [ -z "$list" ]; then
  echo "check-public-safe: no denylist found; skipping." >&2
  echo "  Create one from .public-denylist.example - see docs/adr/0003." >&2
  exit 0
fi

patterns="$(grep -vE '^\s*(#|$)' "$list" || true)"
[ -z "$patterns" ] && exit 0

# Files to scan: staged when run as a hook, otherwise everything tracked.
if git diff --cached --quiet 2>/dev/null; then
  files="$(git ls-files)"
else
  files="$(git diff --cached --name-only --diff-filter=ACM)"
fi
[ -z "$files" ] && exit 0

found=0
while IFS= read -r pat; do
  [ -z "$pat" ] && continue
  while IFS= read -r file; do
    [ -f "$file" ] || continue
    if hits="$(grep -nEIi -- "$pat" "$file" 2>/dev/null)"; then
      if [ "$found" -eq 0 ]; then
        echo "" >&2
        echo "  BLOCKED: content matches your private denylist." >&2
        echo "" >&2
        found=1
      fi
      while IFS= read -r hit; do
        echo "    $file:${hit%%:*}  (pattern: $pat)" >&2
      done <<< "$hits"
    fi
  done <<< "$files"
done <<< "$patterns"

if [ "$found" -eq 1 ]; then
  echo "" >&2
  echo "  Remove the content, or add a narrower pattern to $list." >&2
  echo "  Deliberate exception: git commit --no-verify" >&2
  echo "" >&2
  exit 1
fi
exit 0
