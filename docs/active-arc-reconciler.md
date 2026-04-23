# Active-Arc Reconciler

**Type:** Watchdog (workspace-local cron job).
**Script location:** `~/.openclaw/workspace/scripts/active-arc-reconciler.sh` (workspace-local, **not** tracked in this repo).
**Cron cadence:** every 30 min.
**Origin:** S18.3 silent-outage postmortem (see `SOUL.md` \u00a7 Long-running arc verification) + S20.2 `sprintShape` extension.

## Purpose

For each arc in `~/.openclaw/workspace/memory/active-arcs.json`, verify that the sub-sprint currently in flight has either:

- **Structurally closed** (the expected artifact exists in its source-of-truth), OR
- **Is still legitimately in-progress** (recent `lastReportedAt`, no artifact yet).

When neither is true, emit an alert so The Bott can intervene instead of discovering the outage hours later. Artifact-based verification is the canonical close-out signal, **not** completion-event propagation, because multi-level subagent spawns can silently drop events between levels.

## Data Contract

### `active-arcs.json` \u2014 per-arc fields the reconciler reads

| Field | Type | Required | Description |
|---|---|---|---|
| `name` | string | yes | Arc display name. |
| `currentSubSprint` | string | yes | String containing the current sub-sprint id (e.g. `"S18.3 (Phase 3 build)"`, `"S20.2 in flight"`). The reconciler extracts `S<N>.<M>` via regex. |
| `sprintShape` | enum \| absent | no | One of `"build"` / `"spike"` / `"infra"`. Default `"build"` when absent (backward-compatible). Describes the expected-artifact shape for the **current** sub-sprint; rewrite on sub-sprint boundary. See table below. |
| `lastReportedAt` | ISO-8601 | yes | When the arc was last reported on. Staleness is computed from this. |
| `lastReportedEvent` | string | yes | Free-form last-event text; scanned for close-out markers (`grade`, `closed`, `A-`, `A\u2212`, `B+`, `CLOSED`). |

### `sprintShape` values

| Value | Expected artifact | Source of truth | API/check |
|---|---|---|---|
| `"build"` (default) | Audit file at `audits/<project>/v2-sprint-<N>.<M>.md` on `studio-audits/main` | GitHub Contents API | `GET /repos/brott-studio/studio-audits/contents/<path>?ref=main` |
| `"spike"` | Ops doc matching `memory/ops/<N.M>-*.md` in the workspace | Workspace filesystem | `ls ~/.openclaw/workspace/memory/ops/<N.M>-*.md` |
| `"infra"` | Same as `"build"` \u2014 audit on `studio-audits/main` | GitHub Contents API | `GET /repos/brott-studio/studio-audits/contents/<path>?ref=main` |

`"infra"` is a distinct taxonomy value (not merged into `"build"`) so dashboards and future logic can treat infrastructure sub-sprints differently even though the current artifact location is identical.

## Alert Classes

| Class | Trigger | Action expected |
|---|---|---|
| `closed-unreported` | Artifact exists in source-of-truth **AND** `lastReportedEvent` does not contain a close-out marker. | The Bott updates `active-arcs.json.lastReportedEvent` and pings the studio channel with grade + carry-forwards. |
| `stale-no-artifact` | Artifact absent **AND** `lastReportedAt` older than the staleness window. | The Bott inspects the Riv subtree (`subagents list`), checks the retired Riv's final state, respawns Specc-audit directly if needed (see S18.3 retry pattern). |
| `api-error-<code>` | GitHub API returned non-200/404 (only for `build`/`infra`). | Usually self-heals next cycle. If persistent, investigate token/auth. |

## Staleness Window

**45 minutes.** Sub-sprint close-out normally happens in 40\u2013150 min; 45 min mid-build without progress is within normal noise, but >45 min **with no artifact landed** is real signal.

## Alert Dedupe (Cooldown)

Alerts for the same `(arc, status)` pair are suppressed within `COOLDOWN_MINUTES` (default 180 = 3h). Cooldown state lives in `~/.openclaw/workspace/memory/arc-reconciler-cooldown.json`. This prevents the 30-min cron from pinging the channel every cycle while an outage is being diagnosed.

## Exit Codes

- `0` \u2014 all arcs healthy (in-progress or closed cleanly), OR alerts suppressed by cooldown.
- `2` \u2014 at least one arc has an alert-worthy discrepancy that was **not** suppressed.

## Example `active-arcs.json` Fragment

```json
{
  "activeArcs": [
    {
      "name": "S20 Hardening Arc",
      "currentSubSprint": "S20.2 (H3 in flight)",
      "sprintShape": "build",
      "lastReportedAt": "2026-04-23T13:10:00Z",
      "lastReportedEvent": "S20.2 H3 Nutts spawned"
    },
    {
      "name": "Orphan-Recovery Durability Arc",
      "currentSubSprint": "S19.5 (ops-only spike)",
      "sprintShape": "spike",
      "lastReportedAt": "2026-04-22T20:58:00Z",
      "lastReportedEvent": "S19.5 spike in progress; ops doc pending"
    }
  ]
}
```

In the first entry, the reconciler queries GitHub for `audits/battlebrotts-v2/v2-sprint-20.2.md` on `studio-audits/main`. In the second, it globs `~/.openclaw/workspace/memory/ops/19.5-*.md`.

## Manual Invocation

```bash
bash ~/.openclaw/workspace/scripts/active-arc-reconciler.sh | jq .
```

Exit 0 = healthy; exit 2 = alert. JSON output is always emitted to stdout regardless.

## See Also

- `SOUL.md` \u00a7 Long-running arc verification \u2014 why artifact-based verification beats event propagation.
- `schemas/sprint-state-ledger.md` \u2014 Riv's per-sub-sprint task-ledger, which complements this watchdog at the orchestration layer.
- `FRAMEWORK.md` \u00a7 Repo Structure \u2192 Workspace State \u2014 where `active-arcs.json` lives in the overall state model.
