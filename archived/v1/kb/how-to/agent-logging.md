# Agent Logging — How It Works

Two systems enforce agent logging in the studio: **automatic post-task log injection** and **CI gates**.

## System D: Automatic Post-Task Log Injection

### `scripts/auto-log.sh`

Generates a structured log entry from git history and appends it to the agent's `log.md`.

```bash
# Usage (run from game-dev-studio repo):
./scripts/auto-log.sh <agent_name> <role> <task_id> <branch> <repo_path> [pr_url]

# Example:
./scripts/auto-log.sh "Boltz" "game-dev" "TASK-042" "boltz/new-ability" "/tmp/battlebrotts" "https://github.com/blor-inc/battlebrotts/pull/12"
```

**What it captures:** session timestamp, task ID, files changed (git diff), commits made, PR URL.

### `scripts/capture-session.sh`

Wrapper for Rivett (PM) to call after any agent session ends. Clones game-dev-studio, runs `auto-log.sh`, commits, and pushes — so the log gets recorded even if the agent forgot.

```bash
# Usage:
./scripts/capture-session.sh <agent_name> <role> <task_id> <branch> <work_repo_path> [pr_url]

# Requires: STUDIO_REPO_URL env var or defaults to game-dev-studio GitHub URL
# Requires: git credentials configured for push access
```

## System B: CI Gates

### `game-dev-studio` — `.github/workflows/check-logs.yml`

- Triggers on PRs to `main`
- Checks if any `agents/*/log.md` file was modified
- **FAILS** the check with a comment if no log update is included
- **PASSES** if a log file was modified

### `battlebrotts` — `.github/workflows/check-agent-logs.yml`

- Triggers on PRs to `main`
- Checks if the PR description references an agent or log entry (keywords: `agent:`, `logged in`, `log entry`, `agents/*/log`)
- **FAILS** with a reminder comment if no agent attribution is found
- **PASSES** if attribution is present

## For Agents

**Always include a log update in your PRs.** The CI will block your PR if you don't.

For game repo PRs (battlebrotts), mention which agent did the work in the PR description, e.g.:
```
Agent: Boltz (game-dev)
Logged in: game-dev-studio agents/game-dev/log.md
```

## For Rivett (PM)

After any agent session, run `capture-session.sh` as a safety net. Even if the agent logged properly, the auto-capture won't duplicate — it adds a clearly marked "Auto-Generated" entry.
