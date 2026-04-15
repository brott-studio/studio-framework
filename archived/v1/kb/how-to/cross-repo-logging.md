# How-To: Cross-Repo Logging

**Date:** 2026-04-14
**Author:** Patch (DevOps)

## Problem
Agent work often spans both repos (`blor-inc/battlebrotts` for game code, `blor-inc/game-dev-studio` for studio operations). It's hard to trace decisions from one repo to the other.

## Convention
When referencing work or decisions from the other repo, use an HTML comment tag:

```
<!-- xref: game-dev-studio#abc1234 -->
<!-- xref: battlebrotts#PR-15 -->
<!-- xref: game-dev-studio/kb/decisions/test-gate-enforcement.md -->
```

### In Commit Messages
Add the xref as a trailer:
```
[S6-001] feat: campaign controller integration

Implements the full game loop per Sprint 6 plan.
xref: game-dev-studio/kb/decisions/test-gate-enforcement.md
```

### In PR Descriptions
Include xrefs in the body:
```
## References
<!-- xref: game-dev-studio#Sprint-6-planning -->
- Architecture decisions in game-dev-studio kb/decisions/
```

### In Agent Logs
When logging work that spans repos:
```
[2026-04-14T18:00Z] Created CI workflows in battlebrotts.
  xref: battlebrotts/.github/workflows/test-gate.yml
  Documented rationale: game-dev-studio/kb/decisions/test-gate-enforcement.md
```

## Why Not a Tool?
This is deliberately a convention, not automation. Cross-repo references are occasional and context-dependent. A simple text pattern is easier to maintain than a complex linking system.
