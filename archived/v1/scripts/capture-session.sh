#!/usr/bin/env bash
# capture-session.sh — Post-session log capture for Rivett (PM) to call
# Usage: ./capture-session.sh <agent_name> <role> <task_id> <branch> <work_repo_path> [pr_url]
#
# Clones game-dev-studio, runs auto-log.sh to append the entry, commits, and pushes.

set -euo pipefail

AGENT_NAME="${1:?Usage: capture-session.sh <agent_name> <role> <task_id> <branch> <work_repo_path> [pr_url]}"
ROLE="${2:?Missing role}"
TASK_ID="${3:?Missing task_id}"
BRANCH="${4:?Missing branch}"
WORK_REPO="${5:?Missing work_repo_path}"
PR_URL="${6:-none}"

STUDIO_REPO_URL="${STUDIO_REPO_URL:-https://github.com/blor-inc/game-dev-studio.git}"
TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

echo "📦 Cloning game-dev-studio..."
git clone "$STUDIO_REPO_URL" "$TMPDIR/game-dev-studio" --depth=1 -q

cd "$TMPDIR/game-dev-studio"
git config user.name "Patch"
git config user.email "patch@blor-inc.studio"

echo "📝 Generating log entry..."
bash scripts/auto-log.sh "$AGENT_NAME" "$ROLE" "$TASK_ID" "$BRANCH" "$WORK_REPO" "$PR_URL"

LOG_FILE="agents/$ROLE/log.md"
if git diff --quiet "$LOG_FILE" 2>/dev/null; then
  echo "ℹ️  No changes to log file."
  exit 0
fi

git add "$LOG_FILE"
git commit -m "log($ROLE): auto-capture session for $AGENT_NAME — $TASK_ID" -q
git push origin main -q

echo "✅ Session log pushed to game-dev-studio."
