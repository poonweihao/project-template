#!/usr/bin/env bash
# Advisory guard: refuse to push from main. Bypassable with --no-verify by design;
# it exists to stop the accidental push, not to be a security control.
set -euo pipefail
branch="$(git rev-parse --abbrev-ref HEAD)"
if [ "$branch" = "main" ]; then
  echo "" >&2
  echo "  Refusing to push directly from main." >&2
  echo "  Branch first:  git switch -c feat/<issue>-<slug>" >&2
  echo "" >&2
  exit 1
fi
