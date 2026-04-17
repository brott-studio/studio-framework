# Subagent Playbook

How to spawn effective subagents via OpenClaw `sessions_spawn`. Lessons from calibration work and the 2026-04-17 reliability investigation.

---

## Default Spawn Knobs

```
runtime: "subagent"
mode: "run"
thinking: "medium"
runTimeoutSeconds: 1800  (30 minutes)
model: <inherit from parent, or explicit if needed>
```

### Thinking Level

**Default: `medium`.**

Use `medium` for:
- All pipeline roles by default (Riv, Ett, Gizmo, Nutts, Boltz, Optic, Specc, Patch)
- Research tasks
- Multi-file edits
- Anything involving judgment or calibration

Override up to `high` for:
- Deep retrospectives
- Audits that span many sprints
- Complex debugging sessions where the agent must form hypotheses

Override down to `low` for:
- Mechanical file moves / renames
- Single-file formatter runs
- Well-defined one-shot tasks with no ambiguity

**Why uniform default:** variance per agent is harder to reason about than "all agents default to medium, override for exceptions." Debuggability > latency optimization.

### Timeout

**Default: 1800s (30 min).** Long enough for most research + write tasks with medium thinking.

Shorter (600–900s) for:
- One-shot mechanical tasks
- Quick reviews

Longer (3600s+) for:
- Deep retrospectives
- Multi-file research across many repos
- Tasks with known long reads (e.g., reading entire archive)

---

## Provider / idle timing

Separate from the per-spawn `runTimeoutSeconds` (wall-clock) is OpenClaw's **LLM idle timeout** — a per-chunk cap on the model's streaming response. The wrapper starts a fresh timer on every `iterator.next()`; if no chunk arrives before it fires, the run is aborted with `outcome.status == "timeout"`, even though wall-clock may be nowhere near its cap.

- **OpenClaw default:** 120s.
- **Brott Studio config:** **600s.** Set in `~/.openclaw/openclaw.json` at `agents.defaults.llm.idleTimeoutSeconds`. **[Structural]** — enforced by the config file, applies to every spawn.

### Why 600s

Opus 4.7 does long internal thinking passes between stream chunks — multi-second deliberation, tool-call argument construction, post-tool re-planning. Copilot's proxy doesn't send keepalive chunks during those gaps, so the stream looks idle to the wrapper even though the model is actively reasoning.

The 2026-04-17 investigation measured this directly: 4.7 timeout rate 8.3% vs 4.6's 1.8%, with **every** 4.7 timeout clustering around ~180s runtime, frozen mid-narration right before the write phase ("Time to write the audit." / "Writing the spec now." / "Now let me write the report."). That's the 120s idle cap firing on a single long thinking chunk, not wall-clock exhaustion. 600s gives the model room to finish a reasoning pass without being killed; genuine hangs (10min of zero chunks) still get caught.

### Diagnostic path if a subagent still times out — **[Compliance-reliant]**

1. Open `~/.openclaw/subagents/runs.json`, find the run, inspect `.outcome` and `.frozenResultText`.
2. If `frozenResultText` ends mid-narration right before a write ("Let me write...", "Now I'll...") → it's an **LLM idle timeout**. The 600s cap fired. Raise `agents.defaults.llm.idleTimeoutSeconds` further (900, 1200), or as a last resort set it to `0` to disable the wrapper entirely. Only disable after raising has been exhausted — you lose genuine-hang protection.
3. If `accumulatedRuntimeMs` is close to the spawn's `runTimeoutSeconds` → it's **wall-clock**, not idle. Raise `runTimeoutSeconds` on the spawn (see Timeout section above) and/or tighten the task scope.
4. If neither — check for abort from the parent or upstream error; not an idle issue.

Cross-ref: full diagnosis in the workspace memo `memory/2026-04-17-subagent-timeout-investigation.md` (workspace-local, not in this repo; kept for HCD review).

---

## Task Prompt Template

```
You are <Role> for <Project>.

Before starting:
<spawn preamble from SPAWN_PROTOCOL.md>

Your task: <one-sentence clear goal>

Deliverable: <specific file path and format>

Approach (incremental-write protocol):
1. Open the deliverable file first. Write the skeleton (headers only).
   This guarantees SOMETHING lands even if you're cut off.
2. Do initial research (read 2–5 key files, not everything).
3. Write section 1 of the deliverable. SAVE THE FILE.
4. Do next research pass for section 2.
5. Write section 2. SAVE.
6. Continue until all sections are done.
7. Final pass: re-read the deliverable top-to-bottom, tighten, save.

DO NOT:
- Spend your first 10+ minutes on "let me read one more file" without writing.
- Produce planning as output tokens. Produce the deliverable.
- Try to read everything before writing anything.

DO:
- Write early, write often.
- Save the file after each section.
- Prefer 80%-correct-and-saved over 100%-planned-and-lost-to-timeout.
```

### Why incremental-write

The 2026-04-17 investigation found 4.7-based subagents getting stuck in research loops, producing 8k+ output tokens of planning before any tool call that wrote to disk. They'd hit the runtime cap before the write phase began. Skeleton-first + save-after-each-section ensures partial progress survives the cut-off.

---

## Common Failure Modes & Fixes

### "Stuck in research"
**Symptom:** Subagent produces lots of reasoning tokens but no file writes, then times out.

**Fix:** Force skeleton-first in the task prompt. Set timeout lower (900s) if possible to get faster feedback on the pattern.

### "Peeks at one more file forever"
**Symptom:** Agent keeps saying "let me also check X" and never commits to writing.

**Fix:** In the task, explicitly bound the research phase: "Read at most 5 files before starting to write. After that, read only to answer specific questions that arise during writing."

### "Writes a plan instead of the deliverable"
**Symptom:** Output file contains "Step 1: I will do X. Step 2: I will do Y." instead of X and Y themselves.

**Fix:** Task prompt must say "Execute, don't plan in the deliverable. The deliverable is the FINAL output, not a description of what you'll do."

### "Runs out of runtime during final polish"
**Symptom:** All sections are written but agent times out during the final re-read pass.

**Fix:** Accept 80% — the content is saved. Parent session does the polish pass.

---

## Recommended Spawn Patterns

### Research + write report
```
sessions_spawn({
  task: <role preamble> + incremental-write template + "Report goes to
         /home/openclaw/.openclaw/workspace/memory/<slug>.md",
  runtime: "subagent",
  mode: "run",
  thinking: "medium",
  runTimeoutSeconds: 1800,
})
```

### Multi-file edit
```
sessions_spawn({
  task: <role preamble> + "Edit the following files: <list>. For each:
         read, apply <transformation>, save. Don't batch — one file at a
         time, save after each.",
  thinking: "medium",
  runTimeoutSeconds: 1800,
})
```

### Parallel sprint work (Riv orchestrating)
Spawn multiple Nutts in parallel if tasks are independent. Each in its own worktree. See [SPAWN_PROTOCOL.md](SPAWN_PROTOCOL.md) and [ORCHESTRATION_PATTERNS.md](ORCHESTRATION_PATTERNS.md) for the hard-gate-between-slices rule.

---

## Monitoring

When a spawned subagent is running:
- Don't poll `subagents list` in a loop. Wait for completion events.
- If you suspect stuck (no completion in 2× expected time), use `subagents action=list` once to check status.
- Kill + respawn with adjusted knobs (longer timeout, different thinking) rather than waiting indefinitely.

---

## Cross-references

- [SPAWN_PROTOCOL.md](SPAWN_PROTOCOL.md) — per-agent prompt templates
- [ORCHESTRATION_PATTERNS.md](ORCHESTRATION_PATTERNS.md) — parallel slice patterns, hard gates
- [ESCALATION.md](ESCALATION.md) — when a subagent failure requires escalation

---

*[Compliance-reliant.] These are authoring conventions, not enforced by OpenClaw. The Bott and Riv follow them when spawning. Track failures against these conventions in the next audit cycle.*
