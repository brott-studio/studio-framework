// Unit tests for the write-phase-sentinel plugin.
// Run: node --test test/sentinel.test.mjs
import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import os from "node:os";
import { recordFirstEntry, shouldDeclineResume } from "../index.js";

// Redirect HOME to a temp dir per test so we don't touch the real workspace.
function withTempHome(fn) {
  const prev = process.env.HOME;
  const tmp = fs.mkdtempSync(path.join(os.tmpdir(), "wps-test-"));
  process.env.HOME = tmp;
  // Monkey-patch os.homedir via env override. The plugin uses os.homedir(),
  // which on Linux reads from HOME. We re-import is not needed; homedir()
  // re-evaluates $HOME each call on Linux.
  try {
    fn(tmp);
  } finally {
    process.env.HOME = prev;
    fs.rmSync(tmp, { recursive: true, force: true });
  }
}

test("recordFirstEntry creates sentinel atomically on first call", () => {
  withTempHome((home) => {
    const sid = "test-session-111";
    const outcome = recordFirstEntry(sid);
    assert.equal(outcome.status, "first-entry");
    assert.equal(outcome.sessionId, sid);
    const p = path.join(home, ".openclaw", "subagents", sid, "write-phase-entered.sentinel");
    assert.ok(fs.existsSync(p), "sentinel file should exist");
    const content = fs.readFileSync(p, "utf8").trim();
    assert.match(content, /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$/);
  });
});

test("recordFirstEntry is one-shot — second call returns already-entered without overwrite", () => {
  withTempHome(() => {
    const sid = "test-session-222";
    const first = recordFirstEntry(sid);
    const second = recordFirstEntry(sid);
    assert.equal(first.status, "first-entry");
    assert.equal(second.status, "already-entered");
    assert.equal(second.firstEntryAt, first.ts, "second call must preserve original timestamp");
  });
});

test("shouldDeclineResume returns decline:false when no sentinel", () => {
  withTempHome(() => {
    const out = shouldDeclineResume("unknown-session", "nutts");
    assert.equal(out.decline, false);
  });
});

test("shouldDeclineResume returns decline:true + resumeDeclined event when sentinel present", () => {
  withTempHome(() => {
    const sid = "test-session-333";
    recordFirstEntry(sid);
    const out = shouldDeclineResume(sid, "boltz");
    assert.equal(out.decline, true);
    assert.equal(out.event, "resumeDeclined");
    assert.equal(out.payload.sessionId, sid);
    assert.equal(out.payload.role, "boltz");
    assert.match(out.payload.sentinelPath, /write-phase-entered\.sentinel$/);
    assert.match(out.payload.firstEntryAt, /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$/);
    assert.match(out.payload.declinedAt, /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$/);
  });
});
