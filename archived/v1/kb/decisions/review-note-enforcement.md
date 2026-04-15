# Decision: PR Review Note Enforcement

**Date:** 2026-04-14
**Author:** Patch (DevOps)
**Sprint:** 6

## Decision
PR reviews that approve or request changes must include at least 20 characters of substantive feedback. An advisory comment is posted on the PR if the review body is empty or low-effort (e.g., just "LGTM").

## Why
- Code review is meaningless if it's just a rubber stamp
- In our studio, Boltz (Lead Dev) is the sole merger — his reviews are the last line of defense
- Empty approvals give false confidence that code was actually reviewed
- Review notes create a record of what was checked and why it was approved
- Future sessions benefit from review rationale when debugging issues

## How It Works
- `review-check.yml` triggers on `pull_request_review` events
- Checks review body length and matches against known low-effort patterns
- Posts an advisory comment if review is thin — does NOT block the review
- Advisory, not blocking, because sometimes a genuine one-liner is fine

## Low-Effort Patterns Detected
- Empty body
- "LGTM", "looks good", "approved", "ok", "nice", "ship it", 👍
- Any body under 20 characters

## Trade-offs
- Advisory only — doesn't prevent merges with thin reviews
- Could annoy reviewers on simple/obvious PRs
- Balanced by being non-blocking: it's a nudge, not a gate
