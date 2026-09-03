# project-template

Scaffold for a governed, single-maintainer project. Create new repos from it:

```bash
scripts/new-repo.sh my-service python   # or: typescript
```

## The loop

| Step | Artefact | Where it is recorded |
|---|---|---|
| 1. State the change | Issue | GitHub Issues |
| 2. Branch | `feat/12-thing` | git |
| 3. Commit | Conventional Commits | git history |
| 4. Open PR | `Closes #12` | PR, links issue |
| 5. Gate | CI green + self-review of full diff | Checks tab |
| 6. Merge | Squash to `main` | one commit per change |
| 7. Version | release-please PR bumps version + CHANGELOG | tag + GitHub Release |

The audit trail is a byproduct of working this way. There is nothing extra to write.

## Command contract

`make setup` `make check` `make format` `make test` `make secrets`. CI runs `make check`
and nothing else, so if it passes locally it passes in CI.

## Rules on `main`

Applied from `scripts/ruleset-main.json`: pull request required, `check` status required,
linear history, force-push and deletion blocked, squash-only merge. Approvals are NOT
required — a self-approval gate is theatre. CI is the gate.

## Rollback

Revert the squash commit for the change, or redeploy the previous tag. One commit per
change is what makes this a one-liner.
