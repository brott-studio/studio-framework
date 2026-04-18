# 🏭 AI Agent Studio — Framework v2

Pipeline-driven framework for autonomous game development using AI agents.

> **Mission: Quality over speed. Ship it right, not just fast.**

---

<!-- STATUS:BEGIN -->
## 📊 Studio Portfolio

Projects powered by this framework. Each project's own README has a live status block (sprint, backlog, PRs, audits).

### [BattleBrotts v2](https://github.com/brott-studio/battlebrotts-v2)
_Autobattler roguelike — current active project_

<img alt="ci" src="https://img.shields.io/github/actions/workflow/status/brott-studio/battlebrotts-v2/verify.yml?branch=main&label=CI"> <img alt="prs" src="https://img.shields.io/github/issues-pr/brott-studio/battlebrotts-v2?label=open%20PRs"> <img alt="backlog" src="https://img.shields.io/github/issues-search/brott-studio/battlebrotts-v2?query=label%3Abacklog+is%3Aopen&label=backlog">

**Details:** [README status](https://github.com/brott-studio/battlebrotts-v2#-status) · [open PRs](https://github.com/brott-studio/battlebrotts-v2/pulls) · [backlog](https://github.com/brott-studio/battlebrotts-v2/issues?q=is%3Aissue+label%3Abacklog+is%3Aopen) · [audits](https://github.com/brott-studio/studio-audits/tree/main/audits/battlebrotts-v2)

---

**Framework repo:** [brott-studio/studio-framework](https://github.com/brott-studio/studio-framework) · **Audits:** [brott-studio/studio-audits](https://github.com/brott-studio/studio-audits)

_Last updated: 2026-04-18 05:21 UTC · [update workflow](../../actions/workflows/readme-status.yml)_
<!-- STATUS:END -->

## Cold-Start: read these in order

If you're a fresh agent session spawned against this repo, read the framework in this order:

1. **[FRAMEWORK.md](FRAMEWORK.md)** — What the studio is. Principles. Leadership. Core rules inline.
2. **[PIPELINE.md](PIPELINE.md)** — How a sprint runs. Phases. Gates. Communication.
3. **[agents/\<your-role>.md](agents/)** — Your specific profile.
4. **Any policy your profile cross-references** — see below.

---

## Root Policy Docs

| File | Purpose |
|---|---|
| [FRAMEWORK.md](FRAMEWORK.md) | Studio operating manual — principles, leadership, pipeline, core rules |
| [PIPELINE.md](PIPELINE.md) | Sprint flow, phases, orchestration, sprint Specc gate |
| [ARC_BRIEF.md](ARC_BRIEF.md) | Arc brief pattern — what HCD writes to direct an arc |
| [SPAWN_PROTOCOL.md](SPAWN_PROTOCOL.md) | Per-agent spawn templates, preamble, credential handling |
| [ORCHESTRATION_PATTERNS.md](ORCHESTRATION_PATTERNS.md) | Multi-agent patterns (pipeline, fan-out, spike sprint) |
| [SUBAGENT_PLAYBOOK.md](SUBAGENT_PLAYBOOK.md) | Spawn knobs (thinking, timeout), incremental-write protocol |
| [ESCALATION.md](ESCALATION.md) | 🟢🟡🔴🚨 autonomy tiers, reversibility principle, two-approvals-unlock |
| [COMMS.md](COMMS.md) | Channel-not-DM rule, mention discipline, subagent summary format |
| [SECRETS.md](SECRETS.md) | PAT location, credential helper, never-in-prompts rule, rotation |
| [REPO_MAP.md](REPO_MAP.md) | Three-repo architecture (framework / project / audits), who writes where |
| [CONVENTIONS.md](CONVENTIONS.md) | Branch names, commit messages, PR titles, task IDs, file naming |

## Agent Profiles

All under [agents/](agents/). Each profile starts with a Core Rules inline block (autonomy / comms / secrets / framework-first) so load-bearing rules are visible at decision time without link-chasing.

- [agents/riv.md](agents/riv.md) — Lead Orchestrator
- [agents/ett.md](agents/ett.md) — Technical PM
- [agents/gizmo.md](agents/gizmo.md) — Game Designer
- [agents/nutts.md](agents/nutts.md) — Developer
- [agents/boltz.md](agents/boltz.md) — Lead Dev / Reviewer
- [agents/optic.md](agents/optic.md) — Verifier
- [agents/specc.md](agents/specc.md) — Inspector (independent)
- [agents/patch.md](agents/patch.md) — DevOps (on-demand)

---

## Key Concepts (one-liners)

- **Pipeline-driven** — sprints follow a defined flow: Design → Plan → Build → Review → Verify → Deploy → Audit
- **Riv orchestrates** — Lead Orchestrator spawned by The Bott per sprint; runs the pipeline
- **Structural > compliance (where possible)** — every rule tagged [Structural] or [Compliance-reliant]
- **Verification over trust** — Playwright visual testing, headless sims, mocked gameplay
- **Learning extraction** — Specc reads agent transcripts and writes KB entries
- **Reversibility trumps permission** — reversible decisions are made, not asked; see [ESCALATION.md](ESCALATION.md)
- **State lives in files, not memory** — every agent is replaceable at any moment

---

## History

This is v2, evolved from [v1 (archived)](archived/v1/).

See v1's `KEY_LEARNINGS.md` for the 11 foundational lessons. Notable evolutions:

- **Rivett → Riv + Ett.** The original PM+orchestrator role was initially retired due to orchestration failures (later root-caused to a `maxSpawnDepth` config issue, not a design flaw). Brought back split into Riv (orchestrator) and Ett (project manager). Both are active canon.
- **Glytch retired into Optic.** One strong Verify stage beats two weak separate stages.
- **Dashboard as framework infrastructure, not project deliverable.**

---

*Maintained by The Bott (Executive Producer). Designed for AI agents. Learned from 16 sprints of v1.*
