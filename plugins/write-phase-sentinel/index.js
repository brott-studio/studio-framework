// Write-Phase Sentinel — OpenClaw plugin
//
// Harness-level enforcement of the write-phase sentinel contract originally
// defined in S19.3 as role-profile text. This plugin replaces the duplicated
// role-profile sentinel block with a single harness-owned hook.
//
// Contract:
//   - When a subagent is spawned with spawn-config `writePhase: true`,
//     the plugin registers a before-write-tool handler for that session.
//   - On the FIRST write-tool call (or first exec-heredoc write to disk),
//     the handler atomically creates:
//         ~/.openclaw/subagents/<session-id>/write-phase-entered.sentinel
//     with the entry timestamp as content.
//   - Subsequent write-tool calls in the same session are no-ops for the
//     sentinel (one-shot per-session latch).
//   - On orphan-resume attempts where the sentinel file already exists,
//     the plugin declines the resume and emits a `resumeDeclined` event to
//     the parent session with shape:
//         { sessionId, sentinelPath, firstEntryAt, declinedAt, role }
//
// This is a SCAFFOLD. The actual OpenClaw hook API surface for
// `subagent:before-write-tool` and `subagent:before-resume` is under
// discussion with the harness team; the plugin ships with documented
// intent and a reference implementation of the sentinel IO so that the
// harness wiring is the only missing piece. See PR body + README.md.

import fs from "node:fs";
import path from "node:path";
import os from "node:os";

const SENTINEL_FILENAME = "write-phase-entered.sentinel";

function sentinelPath(sessionId) {
  return path.join(os.homedir(), ".openclaw", "subagents", sessionId, SENTINEL_FILENAME);
}

function nowIso() {
  return new Date().toISOString().replace(/\.\d+Z$/, "Z");
}

/**
 * Atomically record first-entry for a session. Returns an outcome object.
 * outcome.status === "first-entry"       → proceed with the write
 * outcome.status === "already-entered"   → sentinel already existed (resumed session)
 */
export function recordFirstEntry(sessionId) {
  const p = sentinelPath(sessionId);
  const dir = path.dirname(p);
  fs.mkdirSync(dir, { recursive: true });
  const ts = nowIso();
  // Atomic create via wx; if file exists, read existing ts.
  try {
    fs.writeFileSync(p, ts + "\n", { flag: "wx" });
    return { status: "first-entry", sessionId, sentinel: p, ts };
  } catch (err) {
    if (err.code === "EEXIST") {
      const firstEntryAt = fs.readFileSync(p, "utf8").trim();
      return { status: "already-entered", sessionId, sentinel: p, firstEntryAt, ts };
    }
    throw err;
  }
}

/**
 * Called on orphan-resume attempt. If sentinel exists, decline.
 */
export function shouldDeclineResume(sessionId, role) {
  const p = sentinelPath(sessionId);
  if (!fs.existsSync(p)) return { decline: false };
  const firstEntryAt = fs.readFileSync(p, "utf8").trim();
  return {
    decline: true,
    event: "resumeDeclined",
    payload: {
      sessionId,
      role,
      sentinelPath: p,
      firstEntryAt,
      declinedAt: nowIso(),
      reason:
        "Write-phase sentinel present — prior execution of this session already entered write phase. Declining re-execution to prevent duplicate side effects.",
    },
  };
}

/**
 * OpenClaw plugin entry.
 */
const plugin = {
  id: "write-phase-sentinel",
  name: "Write-Phase Sentinel",
  description:
    "Harness-level interrupt-safety latch for subagent write phases (S19.3 contract, harness-owned).",
  register(api) {
    // Subagent spawn hook: when spawn config has writePhase: true, attach
    // a before-write-tool handler that calls recordFirstEntry on first invocation.
    if (typeof api.registerSubagentHook === "function") {
      api.registerSubagentHook({
        when: "before-write-tool",
        match: (ctx) => ctx?.spawnConfig?.writePhase === true,
        handler: (ctx) => {
          const outcome = recordFirstEntry(ctx.sessionId);
          if (outcome.status === "already-entered") {
            // Should not happen mid-flow — but if it does, emit a warning event
            // and let the write proceed (primary enforcement is at resume time).
            api.emit?.("write-phase-sentinel.duplicate-entry", outcome);
          } else {
            api.emit?.("write-phase-sentinel.first-entry", outcome);
          }
          return { allow: true };
        },
      });
      api.registerSubagentHook({
        when: "before-resume",
        match: (ctx) => ctx?.spawnConfig?.writePhase === true,
        handler: (ctx) => {
          const decision = shouldDeclineResume(ctx.sessionId, ctx.role);
          if (decision.decline) {
            api.emit?.("resumeDeclined", decision.payload);
            return { allow: false, reason: decision.payload.reason };
          }
          return { allow: true };
        },
      });
    } else {
      // Harness does not yet expose the hook API surface. Plugin still loads
      // for inspection; the fallback is the role-profile reference line that
      // points to this plugin as the canonical source.
      api.log?.(
        "[write-phase-sentinel] registerSubagentHook not available; falling back to role-profile reference mode (see studio-framework/plugins/write-phase-sentinel/README.md)."
      );
    }
  },
};

export default plugin;
