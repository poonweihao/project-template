# 2. Release PRs require a manual approval click

Date: 2026-09-04
Status: Accepted

## Context

release-please opens its version-bump PR using the built-in `GITHUB_TOKEN`. GitHub does not
trigger workflows on PRs created by that token, so the required status checks never start and
the PR cannot be merged. It sits at `action_required` until someone presses "Approve and run".

Two ways to remove the friction were considered:

- Give release-please a personal access token so its PRs are attributed to a user and trigger
  CI normally. Removes the click, adds a long-lived credential to store and rotate, and makes
  the release path depend on one person's token.
- Add a ruleset bypass for the GitHub Actions app. Removes the click, but opens a hole any
  workflow in the repo could walk through, and `default_workflow_permissions` is `write`.

## Decision

Neither. Keep the click.

The release PR changes only `CHANGELOG.md` and `version.txt`, both generated from commits that
already passed CI on `main`. The click is not redundant verification - it is a human deciding
that this set of merged changes should become a released version, recorded with a timestamp and
an actor. That is precisely the approval evidence a change process is supposed to produce, and
it is the one gate a single maintainer can hold without it being self-approval theatre.

## Consequences

One click per release. No extra credential exists to leak or rotate, and no bypass actor exists
on `main`. If releases ever become frequent enough that the click is a real cost, revisit with
a fine-grained PAT scoped to this repo and supersede this ADR.
