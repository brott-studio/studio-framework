#!/usr/bin/env bash
# auto-log.sh — Automatically generate a log entry for an agent session
# Usage: ./auto-log.sh <agent_name> <role> <task_id> <branch> <repo_path> [pr_url]
#
# Appends a structured log entry to agents/<role>/log.md based on git history.

set -euo pipefail

AGENT_NAME="${1:?Usage: auto-log.sh <agent_name> <role> <task_id> <branch> <repo_path> [pr_url]}"
ROLE="${2:?Missing role}"
TASK_ID="${3:?Missing task_id}"
BRANCH="${4:?Missing branch}"
REPO_PATH="${5:?Missing repo_path}"
PR_URL="${6:-none}"

TIMESTAMP_END="$(date -u '+%Y-%m-%d %H:%M UTC')"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
STUDIO_ROOT="$(dirname "$SCRIPT_DIR")"
LOG_FILE="$STUDIO_ROOT/agents/$ROLE/log.md"

# Ensure log file exists
mkdir -p "$(dirname "$LOG_FILE")"
touch "$LOG_FILE"

# Gather git info from the work repo
cd "$REPO_PATH"

# Files changed on branch vs main
FILES_CHANGED=$(git diff --name-only main..."$BRANCH" 2>/dev/null || echo "(unable to diff against main)")

# Commits on branch not in main
COMMITS=$(git log main.."$BRANCH" --oneline 2>/dev/null || echo "(unable to get commits)")

# Build the log entry
{
  echo ""
  echo "---"
  echo "### Auto-Generated Log Entry"
  echo "- **Agent:** $AGENT_NAME"
  echo "- **Task:** $TASK_ID"
  echo "- **Branch:** \`$BRANCH\`"
  echo "- **Repo:** $REPO_PATH"
  echo "- **Session end:** $TIMESTAMP_END"
  echo "- **PR:** $PR_URL"
  echo ""
  echo "**Files changed:**"
  if [ -n "$FILES_CHANGED" ]; then
    echo "$FILES_CHANGED" | sed 's/^/- /'
  else
    echo "- (none)"
  fi
  echo ""
  echo "**Commits:**"
  if [ -n "$COMMITS" ]; then
    echo "$COMMITS" | sed 's/^/- /'
  else
    echo "- (none)"
  fi
  echo ""
} >> "$LOG_FILE"

echo "✅ Log entry appended to $LOG_FILE"
