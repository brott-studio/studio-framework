# Pipeline & Roles

## Sprint Pipeline (Orchestrated by Riv)

```
The Bott (EP) → spawns Riv with sprint tasks
  │
  Riv (Lead Orchestrator) → executes pipeline sequentially:
  │
  ├─ Step 1: GIZMO (Design Review) — ALWAYS runs
  │    └─ If design decisions → writes spec for Nutts
  │    └─ If no decisions → reviews sprint vs GDD for drift
  │    └─ If DRIFT DETECTED → escalate to The Bott
  │
  ├─ Step 2: NUTTS (Build) → code + tests → PR
  │
  ├─ Step 3: BOLTZ (Review) → approve/merge or request changes
  │    └─ If changes needed → NUTTS (Fix) → BOLTZ (Re-review)
  │    └─ If rejected twice → escalate to The Bott
  │
  ├─ Step 4: OPTIC (Verify) → tests + Playwright + sims + vision
  │    └─ If FAIL → escalate to The Bott
  │
  ├─ Step 5: SPECC (Audit) → audit + KB entries
  │
  └─ Step 6: REPORT → results back to The Bott
```

## Roles

| Agent | Role | What They Do |
|---|---|---|
| 🎬 **Human** | Creative Director | Direction, feel, playtesting, final say |
| 🤖 **The Bott** | Executive Producer | Sprint planning, product vision, framework |
| 📋 **Riv** | Lead Orchestrator | Executes pipeline, handles review loops |
| 📋 **Ett** | Technical PM | Sprint planning, task breakdown (inactive — future) |
| 🎯 **Gizmo** | Game Designer | Specs, balance decisions, GDD |
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

1. **Structure over compliance** — enforce via CI, not instructions
2. **Verification over trust** — "done" means verified working
3. **Process quality → Product quality → Speed**
4. **Player experience first**
5. **Single responsibility per agent**
6. **Before concluding a design doesn't work, verify the infrastructure supports it**

## Sprint Communication

- Pipeline updates stay within Riv's orchestration (not in main channel)
- The Bott receives Riv's final report only
- CD gets pinged only for: playtest-ready builds, decisions needed, critical issues

## Pipeline Completion Rule

Never notify CD for playtesting until the FULL pipeline has completed (Build → Review → Verify → Deploy → Audit). No shortcuts.

*Full details: [FRAMEWORK.md](FRAMEWORK.md)*
