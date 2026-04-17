# Pipeline & Roles

## Sprint Pipeline (Orchestrated by Riv)

```
The Bott (EP) → spawns Riv with sprint tasks
  │
  Riv (Lead Orchestrator) → sub-sprint loop:
  │
  ├─ Phase 0: AUDIT-GATE (loop precondition)
  │    └─ Skipped on the first iteration. Otherwise: verify prior Specc audit
  │       exists in `brott-studio/studio-audits`. Missing → STOP, escalate to The Bott.
  │
  ├─ Phase 1: DESIGN INPUT
  │    └─ GIZMO (Design Review) — always runs first
  │         └─ Reviews game state against GDD
  │         └─ If design changes → provides spec + GDD update
  │         └─ If no changes → "No design drift, proceed"
  │         └─ If DRIFT DETECTED → escalate to The Bott
  │         └─ Output goes to ETT
  │
  ├─ Phase 2: CONTINUATION-CHECK + SPRINT PLANNING
  │    └─ ETT (Technical PM) — single spawn per iteration
  │         └─ Inputs: Gizmo's output + prior Specc audit (if any) + backlog + HCD escalations
  │         └─ Step A — continue-or-complete check:
  │              • Complete → emit sprint-complete marker → Riv EXITS loop → REPORT
  │              • Continue → fall through to Step B
  │         └─ Step B — emit unified sprint plan (design + build + infra + cleanup)
  │
  ├─ Phase 3: EXECUTION (sequential)
  │    ├─ NUTTS (Build) → code + tests → PR
  │    ├─ BOLTZ (Review) → approve/merge or request changes
  │    │    └─ If changes needed → NUTTS (Fix) → BOLTZ (Re-review)
  │    │    └─ If rejected twice → escalate to The Bott
  │    ├─ OPTIC (Verify) → tests + Playwright + sims + vision
  │    │    └─ If FAIL → note failure in sprint results; continue to Specc. Ett addresses in next sub-sprint.
  │    └─ SPECC (Audit) → audit + KB entries (commits to `studio-audits`)
  │
  └─ loop back to Phase 0 (audit-gate → Gizmo → Ett …)

REPORT → Riv → The Bott (fires only when Ett's Phase 2 Step A returns "complete")
```

## Continuation-Check + Planning (Phase 2)

**[Compliance-reliant.]** Ett is spawned exactly once per sub-sprint iteration, immediately after Gizmo. Ett's first action is the continue-or-complete check; if continuing, Ett emits the sprint plan that incorporates Gizmo's design input. Riv does not self-decide continue-vs-complete — that's Ett's call.

**Ett's inputs (every spawn):**
- Gizmo's design assessment (spec-delta, scope-rethink, or "no drift")
- The prior Specc audit report (or "first iteration, no audit yet")
- The active sprint plan / sprint goal from The Bott
- The current backlog
- Any HCD escalations surfaced since the sprint started

**Ett's outputs — one of two things:**
- **(a) Sprint plan** (continue) — the plan for this iteration's execution phase (design tasks + build + infra + cleanup), incorporating Gizmo's output. Riv proceeds to Nutts.
- **(b) Sprint-complete marker** (complete) — explicit "sprint has converged" signal with one-line rationale. Riv exits the loop and produces its final report to The Bott.

Do not return both. Do not leave the decision implicit.

Riv's final report to The Bott fires on **sprint-complete**, not on audit-commit.

**Final-iteration trade-off:** On the iteration where Ett decides "complete," Gizmo still ran (Phase 1 precedes Phase 2). This is accepted: the wasted-spawn cost is trivial and Gizmo's final-state design assessment becomes useful audit context for The Bott and for Specc retrospectives.

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

**[Compliance-reliant.]** At the top of each sub-sprint iteration (skipped on the first), the prior Specc audit MUST exist in `brott-studio/studio-audits` at `audits/<project>/sprint-<N>.md` before any agent for sub-sprint N+1 is spawned. This gate is a **loop precondition**, not a post-Specc check — its natural home is at the start of each iteration.

Redundant compliance surfaces:
- **Riv** verifies via `gh api` check at the top of each iteration (Phase 0) before spawning Gizmo. If missing, STOP and escalate to The Bott.
- **Ett** re-verifies during its Step A continuation check; refuses to plan without prior audit data.
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
