# Write-Phase Sentinel — OpenClaw Plugin

Harness-level enforcement of the S19.3 write-phase sentinel contract.

## Why

Prior to S20.3, every write-phase role (Specc, Nutts, Boltz) carried ~55 lines of duplicated sentinel-block text in its role profile. Each spawned subagent had to execute that block as its first tool call to latch the session against orphan-resume re-execution.

Duplicating the contract as role-profile prose violates single-source-of-truth:
- Drift between role profiles.
- Every new write-phase role inherits the copy-paste cost.
- The model can skip or mis-execute the block; the harness cannot verify.

Moving enforcement to the harness via this plugin:
- Sentinel write is plugin-owned on `subagent:before-write-tool`.
- Resume-decline is plugin-owned on `subagent:before-resume`.
- Role profiles carry a single one-line reference.

## Contract

- Sentinel path: `~/.openclaw/subagents/<session-id>/write-phase-entered.sentinel`
- Sentinel content: ISO-8601 UTC timestamp of first write-phase entry.
- Trigger: subagent is spawned with spawn-config `writePhase: true`.
- Semantics:
  - First write-tool call → create sentinel atomically (`wx` flag).
  - Subsequent write-tool calls → no-op for sentinel.
  - Orphan-resume attempt with sentinel present → harness declines resume, emits `resumeDeclined` event to parent with `{ sessionId, role, sentinelPath, firstEntryAt, declinedAt, reason }`.

## Install (workspace)

The canonical source lives in the `studio-framework` repo at `plugins/write-phase-sentinel/`. OpenClaw loads plugins from `~/.openclaw/plugins/`. Install via symlink:

```bash
ln -sfn "$PWD/plugins/write-phase-sentinel" ~/.openclaw/plugins/write-phase-sentinel
```

Or copy if symlinks are not supported in your environment:

```bash
cp -r plugins/write-phase-sentinel ~/.openclaw/plugins/write-phase-sentinel
```

Then enable in `~/.openclaw/openclaw.json`:

```json
{
  "plugins": {
    "entries": {
      "write-phase-sentinel": { "enabled": true }
    },
    "allow": ["write-phase-sentinel"]
  }
}
```

Restart the OpenClaw gateway: `openclaw gateway restart`.

## Harness API dependency

This plugin uses `api.registerSubagentHook({ when, match, handler })`. If your OpenClaw version does not yet expose that hook surface, the plugin logs a warning and falls back to role-profile reference mode. In that mode, role profiles still point to this plugin as the canonical semantic source; the write itself happens via the legacy role-profile bash block, retained as a fallback.

Tracked as a carry-forward in the S20.3 PR body. When the harness API lands, remove the fallback notes in the role profiles and let the plugin take over fully.

## Files

- `openclaw.plugin.json` — plugin manifest (OpenClaw convention).
- `package.json` — npm package metadata.
- `index.js` — entry + hook handlers + sentinel IO.
- `hooks/first-write.sh` — reference bash implementation of the first-entry semantic (kept as a verifiable stub).
- `hooks/resume-decline.sh` — reference bash implementation of the resume-decline semantic.
- `test/sentinel.test.mjs` — unit tests for `recordFirstEntry` and `shouldDeclineResume`.

## Tests

```bash
cd plugins/write-phase-sentinel
node --test test/sentinel.test.mjs
```

## Origin

- S19.3 sentinel design: `studio-framework/FRAMEWORK.md § Interrupt Safety — Write-Phase Sentinel` (role-profile era).
- S19.3.1 carry-forward: "Riv-profile resume-declined handler — S19.4+ candidate" — resolved here.
- S20.3 plan: `memory/2026-04-23-s20.3-plan.md` T1–T3.
- Arc brief: `memory/2026-04-23-arc-brief-hardening.md` §H4.
