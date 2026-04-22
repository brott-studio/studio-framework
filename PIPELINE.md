# Pipeline & Roles

## The Arc + Sprint Model

- **Arc** = the outer strategic unit. HCD delivers an [arc brief](ARC_BRIEF.md); Gizmo + Ett decide when it's complete.
- **Sprint** = one full pipeline iteration inside an arc. Numbered `N.1`, `N.2`, … where `N` is the arc number.

Riv is spawned per arc. Inside the arc, Riv runs the sprint loop until Ett emits the arc-complete marker.

## Sprint Pipeline (Orchestrated by Riv)

```
The Bott (EP) → spawns Riv with arc brief
  │
  Riv (Lead Orchestrator) → sprint loop:
  │
  ├─ Phase 0: AUDIT-GATE (loop precondition)
  │    └─ Skipped on the first sprint of the arc. Otherwise: verify prior Specc audit
  │       exists in `brott-studio/studio-audits`. Missing → STOP, escalate to The Bott.
  │
  ├─ Phase 1: DESIGN INPUT + ARC-INTENT CHECK
  │    └─ GIZMO — always runs first
  │         └─ Reviews game state against GDD
  │         └─ Emits arc-intent verdict (satisfied / progressing / drift) when arc brief provided
  │         └─ If design changes → provides spec + GDD update
  │         └─ If no changes → "No design drift, proceed"
  │         └─ If GDD DRIFT DETECTED → escalate to The Bott
  │         └─ Output goes to ETT
  │
  ├─ Phase 2: CONTINUATION-CHECK + SPRINT PLANNING
  │    └─ ETT (Technical PM) — single spawn per sprint
  │         └─ Inputs: Arc brief + Gizmo's output (incl. arc-intent verdict) + prior Specc audit (if any) + backlog + HCD escalations
  │         └─ Step A — continue-or-complete check:
  │              • Complete → emit arc-complete marker → Riv EXITS loop → REPORT
  │              • Continue → fall through to Step B
  │         └─ Step B — emit unified sprint plan (design + build + infra + cleanup)
  │
  ├─ Phase 3: EXECUTION (sequential)
  │    ├─ NUTTS (Build) → code + tests → PR
  │    ├─ BOLTZ (Review) → approve/merge or request changes
  │    │    └─ If changes needed → NUTTS (Fix) → BOLTZ (Re-review)
  │    │    └─ If rejected twice → escalate to The Bott
  │    ├─ OPTIC (Verify) → tests + Playwright + sims + vision
  │    │    └─ If FAIL → note failure in sprint results; continue to Specc. Ett addresses in the next sprint.
  │    └─ SPECC (Audit) → audit + KB entries (commits to `studio-audits`)
  │
  └─ loop back to Phase 0 (audit-gate → Gizmo → Ett …)

REPORT → Riv → The Bott (fires only when Ett's Phase 2 Step A returns the arc-complete marker)
```

## Continuation-Check + Planning (Phase 2)

**[Compliance-reliant.]** Ett is spawned exactly once per sprint, immediately after Gizmo. Ett's first action is the continue-or-complete check; if continuing, Ett emits the sprint plan that incorporates Gizmo's design input. Riv does not self-decide continue-vs-complete — that's Ett's call.

**Ett's inputs (every spawn):**
- The arc brief (goal, priorities, max-sprints fuse, hard constraints)
- Gizmo's design assessment (spec-delta, scope-rethink, or "no drift") **and** arc-intent verdict when arc context is provided
- The prior Specc audit report (or "first sprint in arc, no audit yet")
- **Current backlog** pulled via GitHub Issues (`GET /repos/<project>/issues?state=open&labels=backlog`, priority-sorted). Cross-referenced against the prior audit's carry-forward section to catch items Specc flagged but didn't file as issues. Gaps reported as `BACKLOG HYGIENE` in the output.
- Any HCD escalations surfaced since the arc started

**Ett's outputs — one of two things:**
- **(a) Sprint plan** (continue) — the plan for this sprint's execution phase (design tasks + build + infra + cleanup), incorporating Gizmo's output. Every task references its source issue (`[#NNN]`) or is marked `new this sprint`. Includes a `BACKLOG HYGIENE` block reporting whether all prior-audit carry-forward items are filed as issues. Riv proceeds to Nutts.
- **(b) Arc-complete marker** (complete) — explicit "the arc has converged" signal with one-line rationale (citing Gizmo's arc-intent verdict, audit trend, or fuse). Riv exits the loop and produces its final report to The Bott.

Do not return both. Do not leave the decision implicit.

Riv's final report to The Bott fires on **arc-complete**, not on audit-commit.

**Last-sprint trade-off:** On the sprint where Ett decides "complete," Gizmo still ran (Phase 1 precedes Phase 2). This is accepted: the wasted-spawn cost is trivial and Gizmo's final-state design assessment becomes useful audit context for The Bott and for Specc retrospectives.

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

## Sprint Audit Gate (HARD RULE)

**[Compliance-reliant.]** At the top of each sprint in an arc (skipped on the very first sprint of the arc), the prior Specc audit MUST exist in `brott-studio/studio-audits` at `audits/<project>/sprint-<N.M>.md` before any agent for sprint N.M+1 is spawned. This gate is a **loop precondition**, not a post-Specc check — its natural home is at the start of each sprint.

Redundant compliance surfaces:
- **Riv** verifies via `gh api` check at the top of each sprint (Phase 0) before spawning Gizmo. If missing, STOP and escalate to The Bott.
- **Ett** re-verifies during its Step A continuation check; refuses to plan without prior audit data.
- **The Bott** monitors for sprint transitions without matching audit commit and intervenes.

Specc has been invaluable to pipeline quality. Skipping Specc between sprints has caused real problems — this gate exists because of that history.

### Sub-sprint close-out invariant

The audit-gate is also a **close-out invariant**, not just a loop precondition. A sub-sprint N.M is NOT considered closed until the following has landed:

- [ ] **Audit landed on `studio-audits/main`** at `audits/<project>/v2-sprint-<N.M>.md`. A sub-sprint is NOT considered closed without this file merged. (Earned S16.1→S16.3; see `v2-sprint-16-arc-complete.md`.) **[Structural — enforced by audit-presence CI check.]** `Audit Gate` CI check on `battlebrotts-v2` (and on future projects wired per [BOOTSTRAP_NEW_PROJECT.md](BOOTSTRAP_NEW_PROJECT.md)) fails any planning PR that touches `sprints/sprint-<N>.<M>.md` when `audits/<project>/v2-sprint-<N>.<M-1>.md` is absent from `studio-audits/main`. Added in S18.2; wired into branch protection in S18.2 post-merge. First-sprint-of-arc (`M==1`) is exempt and instead requires `arcs/arc-<N>.md` in the PR tree.

**Why this is mandatory (history — originally compliance-reliant):** three consecutive sub-sprints (S16.1, S16.2, S16.3) closed without their audit file landing on `studio-audits/main`; each was flagged by the next sprint's audit. The Riv/Ett/Bott three-surface compliance belt below was introduced to catch the drift. S18.2's `Audit Gate` CI check makes the rule structural — the three compliance surfaces remain as defense-in-depth, but the primary enforcement is now a required status check that cannot be silently skipped.

**Enforcement (three surfaces, one rule):**
- **Riv** at end of Phase 3 (Step 3e): spawns Specc once for the sub-sprint as a whole, then verifies the audit file is merged on `studio-audits/main` before spawning Ett for the next sub-sprint.
- **Ett** at **Step 0** (before Step A continuation decision): verifies the prior sub-sprint's audit file exists on `studio-audits/main`; refuses to run the continuation check or emit a plan if missing.
- **Riv** at Phase 0 (loop precondition at the top of each sub-sprint): re-verifies the prior audit before spawning Gizmo.

## Pipeline Completion Rule

Never notify HCD for playtesting until the FULL pipeline has completed (Design → Plan → Build → Review → Verify → Audit). No shortcuts.

## Cross-references

- Full framework: [FRAMEWORK.md](FRAMEWORK.md)
- Arc brief pattern: [ARC_BRIEF.md](ARC_BRIEF.md)
- Per-agent spawn templates: [SPAWN_PROTOCOL.md](SPAWN_PROTOCOL.md)
- Subagent knobs & incremental-write protocol: [SUBAGENT_PLAYBOOK.md](SUBAGENT_PLAYBOOK.md)
- Escalation tiers: [ESCALATION.md](ESCALATION.md)
- Repo map + who writes where: [REPO_MAP.md](REPO_MAP.md)
- Comms routing: [COMMS.md](COMMS.md)
- Secrets handling: [SECRETS.md](SECRETS.md)
- Conventions: [CONVENTIONS.md](CONVENTIONS.md)
