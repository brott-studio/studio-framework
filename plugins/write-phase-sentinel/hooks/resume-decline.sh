#!/usr/bin/env bash
# Reference implementation of the resume-decline semantic.
# Checks for sentinel presence; if present, prints a resumeDeclined payload
# to stdout and exits 42 so the caller knows to abort resume.
set -euo pipefail

SESSION_ID="${1:-${SESSION_ID:-}}"
ROLE="${2:-${ROLE:-unknown}}"
if [[ -z "$SESSION_ID" ]]; then
  echo "usage: $0 <session-id> [role]" >&2
  exit 2
fi

SENTINEL="$HOME/.openclaw/subagents/${SESSION_ID}/write-phase-entered.sentinel"
NOW="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

if [[ -f "$SENTINEL" ]]; then
  FIRST="$(cat "$SENTINEL" 2>/dev/null || echo unknown)"
  cat <<JSON
{"event":"resumeDeclined","sessionId":"$SESSION_ID","role":"$ROLE","sentinelPath":"$SENTINEL","firstEntryAt":"$FIRST","declinedAt":"$NOW","reason":"Write-phase sentinel present — prior execution of this session already entered write phase."}
JSON
  exit 42
else
  printf '{"event":"resumeAllowed","sessionId":"%s","role":"%s","ts":"%s"}\n' "$SESSION_ID" "$ROLE" "$NOW"
  exit 0
fi
