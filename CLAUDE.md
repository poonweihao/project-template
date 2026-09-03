# Working agreement

## Commands
- `make setup` once per clone. `make check` before any commit. `make format` to fix style.
- Never invent a command. If it is not a make target, it is not part of this project.

## Change process (non-negotiable)
- Every change starts from a GitHub issue. Branch name: `<type>/<issue-number>-<slug>`.
- Conventional Commits: `feat:`, `fix:`, `chore:`, `docs:`, `refactor:`, `test:`. `feat!:` for breaking.
  Commit messages drive the version bump and CHANGELOG. Getting the prefix wrong ships the wrong version.
- One issue, one PR. If a change grows past ~400 lines of diff, stop and split it.
- Never commit directly to `main`. Never force-push a shared branch.

## Definition of done
`make check` passes, the PR body states how the change was verified, and the diff contains
nothing outside the scope of its issue.

## Gotchas
- Secrets live in `.env` (gitignored). `.env.example` lists the keys with no values.
- Architecture decisions go in `docs/adr/` as a new numbered file, not in commit messages.

## Optional stricter hook
To block a turn from ending while checks fail, add to `.claude/settings.json`:
`"Stop": [{"hooks": [{"type": "command", "command": "make check"}]}]`
Useful for unattended runs, slow for interactive work.
