# 3. The public-safety denylist lives outside the repo

Date: 2026-09-04
Status: Accepted

## Context

Repos default to private, but some are deliberately public, and the judgement about which is
which was being made from memory. It failed once: a repo reached the point of being pushed
carrying a work email, the employer's email domain and an internal ticket key, and was caught
only because someone happened to scan it by hand.

The obvious fix is a denylist of work identifiers checked automatically. The non-obvious
problem is that the denylist is itself sensitive. Committing `employer-name`, a work email and
an internal project key into a public template publishes precisely the set of terms the check
exists to keep unpublished. The control would leak the thing it protects.

## Decision

The check ships; the list does not.

`scripts/check-public-safe.sh` reads patterns from the first of `$PUBLIC_DENYLIST_FILE`,
`~/.config/public-denylist`, `<parent of the repo>/.public-denylist`, or a gitignored
`.public-denylist`. The parent-directory location means one list covers every repo in a folder
of repos. Only `.public-denylist.example`, containing generic placeholders, is committed. With
no list present the check passes with a warning, so a fresh clone of this template is never
blocked.

It runs as a pre-commit hook, not in CI. CI cannot read the list without either committing it
or managing it as a secret, and blocking before the push is strictly better than detecting
after: once content reaches a public repo it has been scraped, and making the repo private
afterwards does not unpublish it.

## Consequences

The check is local and bypassable with `--no-verify`, which is correct - it guards against
forgetting, not against a determined author. A new machine needs the list copied to it, and a
machine without one is silently unguarded; the warning on a missing list is the only signal.
False positives are narrowed by editing the list rather than by disabling the hook.
