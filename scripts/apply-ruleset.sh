#!/usr/bin/env bash
# Apply the standard main-branch ruleset to a repo.
#   scripts/apply-ruleset.sh owner/repo
set -euo pipefail
REPO="${1:?usage: apply-ruleset.sh <owner/repo>}"
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

existing=$(gh api "repos/$REPO/rulesets" --jq '.[] | select(.name=="main-protection") | .id' 2>/dev/null || true)
if [ -n "$existing" ]; then
  echo "updating existing ruleset $existing on $REPO"
  gh api --method PUT "repos/$REPO/rulesets/$existing" --input "$DIR/ruleset-main.json"
else
  echo "creating ruleset on $REPO"
  gh api --method POST "repos/$REPO/rulesets" --input "$DIR/ruleset-main.json"
fi
echo "done"
