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
  │    │    └─ If FAIL → escalate to The Bott
  │    └─ SPECC (Audit) → audit + KB entries
  │
  └─ REPORT → results back to The Bott
```

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
2. **Structure over compliance** — enforce via CI, not instructions
3. **Verification over trust** — "done" means verified working
4. **Process quality → Product quality → Speed**
5. **Player experience first**
6. **Single responsibility per agent**
7. **Before concluding a design doesn't work, verify the infrastructure supports it**

## Sprint Communication

- Pipeline updates stay within Riv's orchestration (not in main channel)
- The Bott receives Riv's final report only
- CD gets pinged only for: playtest-ready builds, decisions needed, critical issues

## Pipeline Completion Rule

Never notify CD for playtesting until the FULL pipeline has completed (Design → Plan → Build → Review → Verify → Audit). No shortcuts.

*Full details: [FRAMEWORK.md](FRAMEWORK.md)*
