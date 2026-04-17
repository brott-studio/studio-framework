# Pipeline & Roles

## Sprint Pipeline (Orchestrated by Riv)

```
The Bott (EP) → spawns Riv with sprint tasks
  │
  Riv (Lead Orchestrator) → executes pipeline sequentially:
  │
  ├─ Phase 1: DESIGN INPUT
  │    └─ GIZMO (Design Review) — ALWAYS runs first
  │         └─ Reviews game state against GDD
  │         └─ If design changes → provides spec + GDD update
  │         └─ If no changes → "No design drift, proceed"
  │         └─ If DRIFT DETECTED → escalate to The Bott
  │         └─ Output goes to ETT (not directly to Nutts)
  │
  ├─ Phase 2: SPRINT PLANNING
  │    └─ ETT (Technical PM)
  │         └─ Reads: Gizmo's output + Specc's last audit + backlog + infra needs
  │         └─ Produces unified sprint plan (design tasks + infra + testing + cleanup)
  │         └─ DECISION: continue or escalate
  │
  ├─ Phase 3: EXECUTION (sequential)
  │    ├─ NUTTS (Build) → code + tests → PR
  │    ├─ BOLTZ (Review) → approve/merge or request changes
  │    │    └─ If changes needed → NUTTS (Fix) → BOLTZ (Re-review)
  │    │    └─ If rejected twice → escalate to The Bott
  │    ├─ OPTIC (Verify) → tests + Playwright + sims + vision
  │    │    └─ If FAIL → note failure in sprint results; continue to Specc. Ett addresses in next sub-sprint.
  │    └─ SPECC (Audit) → audit + KB entries
  │
  ├─ Phase 4: CONTINUATION DECISION
  │    └─ ETT (Continuation Mode) — spawned by Riv after Specc commits audit
  │         └─ Inputs: sprint plan, Specc audit, backlog, any HCD escalations
  │         └─ DECISION: continue (queue next sub-sprint) | complete (sprint done)
  │         └─ If continue → Riv loops back to Gizmo (design changes) or Nutts (more build)
  │         └─ If complete → proceed to REPORT
  │
  └─ REPORT → Riv → The Bott (only after Ett signals sprint-complete)
```

## Continuation Decision (After Audit)

**[Compliance-reliant.]** After Specc commits the audit, Riv pauses the pipeline and spawns Ett in **continuation mode**. Riv does not self-decide continue-vs-complete — that's Ett's call.

**Ett's inputs (continuation mode):**
- The active sprint plan (with original scope + any deltas)
- The Specc audit report just committed
- The current backlog
- Any HCD escalations since the sprint started

**Ett's outputs:** one of two things —
- **(a) Sprint-plan addendum** — delta/addendum describing the next sub-sprint's scope. Signals continue.
- **(b) Sprint-complete marker** — explicit "sprint has converged" signal. Signals complete.

**Loop-back routing:**
- If (a) **and** the addendum includes design changes → Riv re-enters the pipeline at **Gizmo** (Phase 1), then Ett (Phase 2) re-plans with the design input, then execution.
- If (a) **and** the addendum is build-only (no design delta) → Riv re-enters at **Nutts** (Step 3a) with the addendum as the build spec.
- If (b) → Riv produces its final report per the Reporting to The Bott section in [agents/riv.md](agents/riv.md).

Riv's final report to The Bott fires on **sprint-complete**, not on audit-commit.

## Roles

| Agent | Role | What They Do |
|---|---|---|
| 🎬 **Human** | Creative Director | Direction, feel, playtesting, final say |
| 🤖 **The Bott** | Executive Producer | Sprint planning, product vision, framework |
| 📋 **Riv** | Lead Orchestrator | Executes pipeline, handles review loops |
| 📋 **Ett** | Technical PM | Sprint planning — integrates design + infra + cleanup |
| 🎯 **Gizmo** | Game Designer | Design input — game state review, specs, GDD updates |
| 💻 **Nutts** | Developer | Code + tests, opens PRs |
| 👨‍💻 **Boltz** | Lead Dev | PR review, sole merger |
| 🎮 **Optic** | Verifier | Tests, Playwright, sims, vision screenshots |
| 🕵️ **Specc** | Inspector | Audits, learning extraction, KB |
| 🔧 **Patch** | DevOps | Infrastructure (on-demand) |

## Repos

| Repo | Purpose | Who Writes |
|---|---|---|
| [studio-framework](https://github.com/brott-studio/studio-framework) | Framework, profiles, pipeline, dashboard | The Bott |
| [studio-audits](https://github.com/brott-studio/studio-audits) | Audit reports by project | Specc |
| [battlebrotts-v2](https://github.com/brott-studio/battlebrotts-v2) | Current game project | Agents via PRs |

## Core Principles

1. **Design drives planning** — Gizmo reviews first, Ett plans based on design input
2. **Structure over compliance where possible; explicit compliance-reliance where not.** Tag every rule as [Structural] or [Compliance-reliant] so it's clear which is which. See [FRAMEWORK.md](FRAMEWORK.md) "Enforcement Mechanisms".
3. **Verification over trust** — "done" means verified working
4. **Process quality → Product quality → Speed**
5. **Player experience first**
6. **Single responsibility per agent**
7. **Before concluding a design doesn't work, verify the infrastructure supports it**

## Sprint Communication

See [COMMS.md](COMMS.md) for full rules.

- Pipeline chatter stays in-session: subagents report to Riv, Riv reports to The Bott's session. No agent posts to the Discord studio channel.
- The Bott is the sole channel voice. For every Riv completion, The Bott posts a curated summary to the channel.
- HCD gets @-mentioned (via The Bott's channel post) only for: playtest-ready builds, merge calls needing HCD signoff, or escalations per [ESCALATION.md](ESCALATION.md) 🔴/🚨 criteria

## Sub-Sprint Audit Gate (HARD RULE)

**[Compliance-reliant.]** Sub-sprint N+1 MUST NOT begin until Specc's sprint-N audit is committed to `brott-studio/studio-audits` at `audits/<project>/sprint-<N>.md`.

Redundant compliance surfaces:
- **Riv** verifies via `gh api` check before spawning any agent for sub-sprint N+1. If missing, STOP and escalate to The Bott.
- **Ett** verifies when planning; refuses to plan next sprint without prior audit.
- **The Bott** monitors for sub-sprint transitions without matching audit commit and intervenes.

Specc has been invaluable to pipeline quality. Skipping Specc between sub-sprints has caused real problems — this gate exists because of that history.

## Pipeline Completion Rule

Never notify HCD for playtesting until the FULL pipeline has completed (Design → Plan → Build → Review → Verify → Audit). No shortcuts.

## Cross-references

- Full framework: [FRAMEWORK.md](FRAMEWORK.md)
- Per-agent spawn templates: [SPAWN_PROTOCOL.md](SPAWN_PROTOCOL.md)
- Subagent knobs & incremental-write protocol: [SUBAGENT_PLAYBOOK.md](SUBAGENT_PLAYBOOK.md)
- Escalation tiers: [ESCALATION.md](ESCALATION.md)
- Repo map + who writes where: [REPO_MAP.md](REPO_MAP.md)
- Comms routing: [COMMS.md](COMMS.md)
- Secrets handling: [SECRETS.md](SECRETS.md)
- Conventions: [CONVENTIONS.md](CONVENTIONS.md)
