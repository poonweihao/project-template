#!/usr/bin/env bash
# Apply the standard main-branch ruleset to a repo.
#   scripts/apply-ruleset.sh owner/repo
# Requires GitHub Pro for private repos; free on public repos.
set -euo pipefail
REPO="${1:?usage: apply-ruleset.sh <owner/repo>}"
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! rulesets=$(gh api "repos/$REPO/rulesets" 2>/dev/null); then
  echo "WARNING: cannot read rulesets on $REPO." >&2
  echo "  GitHub enforces branch rules on private repos only with Pro or above." >&2
  echo "  The local pre-push guard is active, but it is advisory, not a gate." >&2
  exit 2
fi

existing=$(echo "$rulesets" | jq -r '.[] | select(.name=="main-protection") | .id' 2>/dev/null || true)
if [ -n "$existing" ] && [ "$existing" != "null" ]; then
  echo "updating ruleset $existing on $REPO"
  gh api --method PUT "repos/$REPO/rulesets/$existing" --input "$DIR/ruleset-main.json" >/dev/null
else
  echo "creating ruleset on $REPO"
  gh api --method POST "repos/$REPO/rulesets" --input "$DIR/ruleset-main.json" >/dev/null
fi
echo "ruleset applied to $REPO"
