# 1. Record architecture decisions

Date: 2026-09-03
Status: Accepted

## Context

Decisions made while building get forgotten, and the reasoning is not recoverable from the
code. With an agent doing much of the writing this is worse: without the recorded reason it
re-derives a rationale, usually a different one, and changes direction silently.

## Decision

Every non-obvious technical decision gets a numbered file in `docs/adr/`. Context, decision,
consequences. Ten lines is a normal length. Never edit an accepted ADR - supersede it with a
new one that references it.

## Consequences

One more small file per real decision. In exchange, both you and any agent working here read
the same history instead of guessing at it.
