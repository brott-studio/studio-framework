# Decision: Test Gate Enforcement

**Date:** 2026-04-14
**Author:** Patch (DevOps)
**Sprint:** 6

## Decision
Every PR that adds or modifies `.gd` files under `godot/game/` must have corresponding test files under `godot/tests/`. This is enforced by CI (`test-gate.yml`).

## Why
- Tests are the only way to verify game logic without running the full game
- Without enforcement, test coverage erodes over time as "quick fixes" skip tests
- In a multi-agent studio, tests are the contract between developers — they prove the code works
- Data files (`godot/game/data/`) are exempted since they contain static constants

## How It Works
- CI checks `git diff` for changed files matching `godot/game/**/*.gd`
- For each changed file, looks for `godot/tests/test_<name>.gd` or grep-matches for import references
- Fails the PR if any game script lacks test coverage
- Data files are automatically skipped

## Trade-offs
- Slightly more work per PR (must write tests)
- May slow down rapid prototyping
- Worth it for stability in a headless-first development environment
