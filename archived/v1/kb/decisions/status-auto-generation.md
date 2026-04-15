# Decision: Auto-Generated STATUS.md

**Date:** 2026-04-14
**Author:** Patch (DevOps)
**Sprint:** 6

## Decision
STATUS.md in the battlebrotts repo is auto-generated from git history, PRs, and test counts via GitHub Actions. It is overwritten on every push to main.

## Why
- Manual STATUS.md goes stale within hours
- Agents forget to update it, or update it with subjective interpretations
- Auto-generation ensures STATUS.md always reflects reality: actual commits, actual PRs, actual test counts
- No one can accidentally write misleading status claims — it's all derived from facts

## What It Contains
- Total commit count, script count, test count
- Recent 15 commits (from git log)
- Recent 10 PRs with state (open/merged/closed)
- Current sprint goal (from PLAN.md if it exists)

## What It Does NOT Contain
- Agent opinions or progress claims
- Task assignments (that's PLAN.md's job)
- Subjective assessments of completion

## Trade-offs
- Less human-readable narrative
- Cannot include context that isn't in git/PRs
- PLAN.md handles the "what we're doing" narrative separately
