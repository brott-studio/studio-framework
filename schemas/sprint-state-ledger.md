# Sprint-State Ledger Schema

**Status:** Canonical (S20.2 H3). Schema version: `1`.

## Purpose

Durable per-sub-sprint task state for Riv. Records every task Riv has spawned (Gizmo, Ett, Nutts, Boltz, Optic, Specc) with its current state, so that a **respawned Riv** after OOM, gateway restart, or run-mode end can reconstruct what has already been done and resume cleanly from the next unfinished task.

The ledger is the canonical answer to the question: "When Riv wakes up again, what does it know?" Without it, respawn-Riv has only the arc brief + sprint plan and must re-derive state from artifact scans — which is brittle and expensive.

This is the implementation of FRAMEWORK.md Core Principle #4 ("State lives in files, not in memory") for the Riv orchestration layer.

## Location

```
~/.openclaw/workspace/memory/sprint-state/<arc-name>/<sub-sprint>.json
```

- One file **per sub-sprint**, not per arc. S20.2 gets its own file; S20.3 gets its own.
- `<arc-name>` is kebab-case, e.g. `s20-hardening`.
- `<sub-sprint>` is lowercase, e.g. `s20.2`.
- Example: `~/.openclaw/workspace/memory/sprint-state/s20-hardening/s20.2.json`.

Sibling lock file (see Atomic Write below):
```
~/.openclaw/workspace/memory/sprint-state/<arc-name>/<sub-sprint>.json.lock
```

The ledger file is **workspace-local runtime state**. It is not committed to any repo. Archival happens implicitly: when a sub-sprint closes, the ledger file is left in place under `memory/sprint-state/<arc>/`.

## Top-Level Fields

| Field | Type | Required | Description |
|---|---|---|---|
| `schemaVersion` | int | yes | Always `1` in this revision. Respawn-Riv refuses to read a ledger with `schemaVersion > 1` and escalates to Bott (schema guard). |
| `arc` | string | yes | Arc name, kebab-case (e.g. `"s20-hardening"`). |
| `subSprint` | string | yes | Sub-sprint id (e.g. `"s20.2"`). |
| `sprintPlanRef` | string | yes | Path or URL to Ett's sprint plan (e.g. `memory/ops/2026-04-23-s20.2-sprint-plan.md`). |
| `rivSessionKey` | string | yes | The current Riv session writing the ledger. Rewritten on each respawn. |
| `createdAt` | string | yes | ISO-8601 UTC timestamp of initial write. |
| `updatedAt` | string | yes | ISO-8601 UTC timestamp of most recent write. |
| `tasks` | `Task[]` | yes | Ordered list of all tasks in the sub-sprint. |

## Per-Task Fields (`Task`)

| Field | Type | Required | Description |
|---|---|---|---|
| `task` | string | yes | Deterministic identifier. Must be stable across respawns (e.g. `"T2-nutts-patch"`). |
| `taskType` | enum | yes | One of: `gizmo`, `ett`, `nutts`, `boltz`, `optic`, `specc`, `riv`. |
| `status` | enum | yes | One of: `pending`, `spawned`, `in-flight`, `completed`, `failed`, `declined`. |
| `startedAt` | string \| null | yes | ISO-8601 UTC when Riv spawned the task; `null` until spawned. |
| `endedAt` | string \| null | yes | ISO-8601 UTC when task reached terminal state; `null` otherwise. |
| `childSessionKey` | string \| null | yes | Spawned child's `agent:main:subagent:<uuid>` key; `null` if not yet spawned. |
| `childCompletionEvent` | bool | yes | `true` only when Riv received the auto-announce wake event from the child. Default `false`. |
| `artifactRef` | string \| null | yes | PR URL, audit file path, or ops doc path that this task produces. `null` until verified. |
| `attemptCount` | int | yes | Number of spawn attempts for this task. Default `1`; increments on respawn. |
| `lastError` | string \| null | yes | Terminal-state error message if `status` is `failed` or `declined`; `null` otherwise. |
| `notes` | string \| null | yes | Free-form notes from Riv (decisions made inline, manual overrides, etc.). |

## State Machine

```
        ┌──────────┐
        │ pending  │  (initial)
        └────┬─────┘
             │ sessions_spawn
             ▼
        ┌──────────┐
        │ spawned  │
        └────┬─────┘
             │ (optional progress signal)
             ▼
        ┌──────────┐
        │in-flight │
        └────┬─────┘
             │
     ┌───────┼─────────┬────────────┐
     ▼       ▼         ▼            ▼
┌─────────┐┌──────┐ ┌────────┐
│completed││failed│ │declined│
└─────────┘└──────┘ └────────┘
```

**Transitions (terminal states reached from any non-terminal state):**

- `pending → spawned` on `sessions_spawn` returning a child session key.
- `spawned → in-flight` (optional) when a progress signal is observed (artifact partially built, subagent emits an intermediate status, etc.). Skipping this state is legal.
- `{spawned, in-flight} → completed` on child completion event **AND** artifact verification (see Respawn Decision below).
- `{spawned, in-flight} → failed` on error or artifact-verification failure.
- `{spawned, in-flight} → declined` on an orphan-resume-declined payload from the child (write-phase sentinel tripped).

Terminal states (`completed`, `failed`, `declined`) do not transition further in the same ledger entry. A bounded-respawn retry creates a **new attempt on the same task entry** (increments `attemptCount`, rewrites `startedAt`/`endedAt`/etc.) rather than appending a new row.

## Respawn Decision Table

When respawn-Riv reads the ledger at startup, it walks `tasks[]` in order and applies:

| `status` | `artifactRef` | Action |
|---|---|---|
| `completed` | — | Skip; do not respawn. |
| `pending` | — | Spawn now (fresh start). |
| `spawned` | present | Verify artifact exists in source-of-truth (GitHub / workspace). If yes → mark `completed` in place, skip. |
| `spawned` | null | Respawn; increment `attemptCount`. |
| `in-flight` | present | Verify artifact exists. If yes → mark `completed`, skip. |
| `in-flight` | null | Respawn; increment `attemptCount`. |
| `failed` | — | Respawn if `attemptCount < 3`; else escalate to Bott. |
| `declined` | — | **ALWAYS escalate to Bott.** Never auto-respawn. |

**Attempt cap:** if any task has `attemptCount > 3`, respawn-Riv escalates to Bott and does **not** auto-respawn, regardless of status.

## Atomic Write Pattern

All writes to `<sub-sprint>.json` are atomic and serialized against concurrent writers.

1. Acquire `flock(2)` on `<sub-sprint>.json.lock` (a separate sibling lock file). The lock file is created if absent.
2. Read current ledger (`<sub-sprint>.json`) into memory. If absent, initialize.
3. Mutate in memory.
4. Write to `<sub-sprint>.json.tmp.<pid>.<rand>` in the same directory.
5. `fsync(2)` the tmp file.
6. `rename(2)` the tmp file onto `<sub-sprint>.json` (atomic on POSIX same-filesystem).
7. Release the flock.

**Shell idiom:**

```bash
ledger="$HOME/.openclaw/workspace/memory/sprint-state/$ARC/$SUB.json"
lock="$ledger.lock"
mkdir -p "$(dirname "$ledger")"
touch "$lock"

(
  flock -x 9

  current='{}'
  [[ -f "$ledger" ]] && current=$(cat "$ledger")

  # ... jq mutation producing $updated ...

  tmp="$ledger.tmp.$$.$RANDOM"
  printf '%s\n' "$updated" > "$tmp"
  sync "$tmp"          # best-effort fsync in shell
  mv -f "$tmp" "$ledger"
) 9>"$lock"
```

The lock file is **sibling**, not the data file itself — opening the data file for flock would race with the rename step.

## Schema-Version Guard

Respawn-Riv reads `schemaVersion` first. If it exceeds the version Riv understands (currently `1`), Riv **does not attempt to interpret the ledger**. It escalates to Bott with:

```
RIV-SCHEMA-GUARD
arc: <arc-name>
subSprint: <sub-sprint>
ledgerPath: memory/sprint-state/<arc>/<sub-sprint>.json
observedSchemaVersion: <int>
supportedSchemaVersion: 1
recommendedAction: manual-inspection
```

Rationale: a newer ledger written by a future Riv carries semantics this Riv doesn't know. Forging ahead with a partial read would corrupt state.

## Example

```json
{
  "schemaVersion": 1,
  "arc": "s20-hardening",
  "subSprint": "s20.2",
  "sprintPlanRef": "memory/ops/2026-04-23-s20.2-sprint-plan.md",
  "rivSessionKey": "agent:main:subagent:abcd-1234-...",
  "createdAt": "2026-04-23T12:00:00Z",
  "updatedAt": "2026-04-23T13:15:00Z",
  "tasks": [
    {
      "task": "T1-gizmo-design",
      "taskType": "gizmo",
      "status": "completed",
      "startedAt": "2026-04-23T12:02:00Z",
      "endedAt": "2026-04-23T12:18:00Z",
      "childSessionKey": "agent:main:subagent:1111-...",
      "childCompletionEvent": true,
      "artifactRef": "memory/ops/2026-04-23-s20.2-gizmo-design.md",
      "attemptCount": 1,
      "lastError": null,
      "notes": null
    },
    {
      "task": "T3-nutts-build-h3",
      "taskType": "nutts",
      "status": "spawned",
      "startedAt": "2026-04-23T13:10:00Z",
      "endedAt": null,
      "childSessionKey": "agent:main:subagent:4e1f-...",
      "childCompletionEvent": false,
      "artifactRef": null,
      "attemptCount": 1,
      "lastError": null,
      "notes": "H3 combined build: T1 schema + T2 Riv patch + T3 reconciler docs"
    }
  ]
}
```

## See Also

- `agents/riv.md` § Task-Ledger Protocol (S20.2 H3) — how Riv writes and reads this file.
- `docs/active-arc-reconciler.md` — the watchdog that verifies arc artifacts independently.
- `FRAMEWORK.md` § Core Principles #4 — "State lives in files, not in memory" (motivating principle).
