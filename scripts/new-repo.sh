#!/usr/bin/env bash
# Create a governed repo from this template.
#   scripts/new-repo.sh my-service [python|typescript|both]
set -euo pipefail
NAME="${1:?usage: new-repo.sh <name> [python|typescript|both]}"
STACK="${2:-both}"
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(dirname "$DIR")"
PARENT="$(dirname "$ROOT")"
OWNER="$(gh api user --jq .login)"

cd "$PARENT"
gh repo create "$NAME" --private --template "$OWNER/project-template" --clone
cd "$NAME"

case "$STACK" in
  python)     make prune-js ;;
  typescript) make prune-py ;;
  both)       ;;
  *) echo "unknown stack: $STACK" >&2; exit 1 ;;
esac

# Rename the project inside the scaffold
[ -f pyproject.toml ] && sed -i.bak "s/^name = \"project-template\"/name = \"$NAME\"/" pyproject.toml && rm -f pyproject.toml.bak
[ -f package.json ]   && sed -i.bak "s/\"name\": \"project-template\"/\"name\": \"$NAME\"/" package.json && rm -f package.json.bak
sed -i.bak "1s/.*/# $NAME/" README.md && rm -f README.md.bak

git add -A
git commit -m "chore: initialise $NAME from template ($STACK)"
git push

gh repo edit "$OWNER/$NAME" \
  --enable-squash-merge \
  --enable-merge-commit=false \
  --enable-rebase-merge=false \
  --delete-branch-on-merge \
  --enable-issues \
  --enable-wiki=false

# release-please cannot open its version PR without this
gh api --method PUT "repos/$OWNER/$NAME/actions/permissions/workflow" \
  -f default_workflow_permissions=write -F can_approve_pull_request_reviews=true >/dev/null

# Free plan enforces rulesets on public repos only
gh api --method PATCH "repos/$OWNER/$NAME" \
  -F 'security_and_analysis[secret_scanning][status]=enabled' \
  -F 'security_and_analysis[secret_scanning_push_protection][status]=enabled' >/dev/null 2>&1 || true

"$DIR/apply-ruleset.sh" "$OWNER/$NAME" || true

echo
echo "Repo ready: https://github.com/$OWNER/$NAME"
echo "Next: cd $NAME && make setup"
