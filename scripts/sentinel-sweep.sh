#!/usr/bin/env bash
# sentinel-sweep.sh — weekly cleanup of stale write-phase sentinel files.
#
# Sweeps sentinels older than $AGE_DAYS (default 7) from
#   ~/.openclaw/subagents/*/write-phase-entered.sentinel
#
# Origin: S19.3 wrote the sentinel contract; S20.3 T6 folded this cleanup
# cron into the Hardening Arc. The sentinel latches ephemeral session state;
# once a subagent session has been closed for more than a week, its sentinel
# is no longer protecting anything useful and is safe to remove.
#
# Usage:
#   scripts/sentinel-sweep.sh                # live sweep
#   scripts/sentinel-sweep.sh --dry-run      # report only, no deletions
#   AGE_DAYS=14 scripts/sentinel-sweep.sh    # override age threshold
#   SENTINEL_ROOT=/tmp/test scripts/sentinel-sweep.sh --dry-run
#
# Exit codes:
#   0 — success (including zero-found)
#   2 — argument/environment error

set -euo pipefail

DRY_RUN=0
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    -h|--help)
      sed -n '1,25p' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *)
      echo "unknown arg: $arg" >&2
      exit 2
      ;;
  esac
done

AGE_DAYS="${AGE_DAYS:-7}"
SENTINEL_ROOT="${SENTINEL_ROOT:-$HOME/.openclaw/subagents}"

if ! [[ "$AGE_DAYS" =~ ^[0-9]+$ ]]; then
  echo "AGE_DAYS must be a non-negative integer (got: $AGE_DAYS)" >&2
  exit 2
fi

if [[ ! -d "$SENTINEL_ROOT" ]]; then
  echo "sentinel root does not exist: $SENTINEL_ROOT (nothing to sweep)"
  exit 0
fi

NOW="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
FOUND=0
REMOVED=0

# -mtime +N matches files modified MORE than N*24h ago.
while IFS= read -r -d '' f; do
  FOUND=$((FOUND + 1))
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "[DRY-RUN] would remove: $f"
  else
    rm -f "$f"
    # Also remove the empty per-session parent dir if it has nothing left.
    parent="$(dirname "$f")"
    if [[ -d "$parent" ]] && [[ -z "$(ls -A "$parent" 2>/dev/null)" ]]; then
      rmdir "$parent" 2>/dev/null || true
    fi
    REMOVED=$((REMOVED + 1))
  fi
done < <(find "$SENTINEL_ROOT" -maxdepth 2 -type f -name 'write-phase-entered.sentinel' -mtime "+${AGE_DAYS}" -print0)

if [[ "$DRY_RUN" -eq 1 ]]; then
  printf '{"event":"sentinel-sweep","mode":"dry-run","ts":"%s","ageDays":%s,"root":"%s","found":%s}\n' \
    "$NOW" "$AGE_DAYS" "$SENTINEL_ROOT" "$FOUND"
else
  printf '{"event":"sentinel-sweep","mode":"live","ts":"%s","ageDays":%s,"root":"%s","found":%s,"removed":%s}\n' \
    "$NOW" "$AGE_DAYS" "$SENTINEL_ROOT" "$FOUND" "$REMOVED"
fi
