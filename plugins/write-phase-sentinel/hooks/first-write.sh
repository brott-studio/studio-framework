#!/usr/bin/env bash
# Reference implementation of the first-write sentinel semantic.
# The JS plugin is source-of-truth in production; this script documents
# the exact semantic for auditability and can be used as a fallback.
set -euo pipefail

SESSION_ID="${1:-${SESSION_ID:-}}"
if [[ -z "$SESSION_ID" ]]; then
  echo "usage: $0 <session-id>" >&2
  exit 2
fi

SENTINEL_DIR="$HOME/.openclaw/subagents/${SESSION_ID}"
SENTINEL="${SENTINEL_DIR}/write-phase-entered.sentinel"
NOW="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

mkdir -p "$SENTINEL_DIR"

# Atomic create via noclobber.
if ( set -o noclobber; printf '%s\n' "$NOW" > "$SENTINEL" ) 2>/dev/null; then
  printf '{"status":"first-entry","sessionId":"%s","sentinel":"%s","ts":"%s"}\n' \
    "$SESSION_ID" "$SENTINEL" "$NOW"
  exit 0
else
  FIRST="$(cat "$SENTINEL" 2>/dev/null || echo unknown)"
  printf '{"status":"already-entered","sessionId":"%s","sentinel":"%s","firstEntryAt":"%s","ts":"%s"}\n' \
    "$SESSION_ID" "$SENTINEL" "$FIRST" "$NOW"
  exit 0
fi
