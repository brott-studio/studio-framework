# 🏭 AI Agent Studio — Framework v2

> **Mission: Quality over speed. Ship it right, not just fast.**
>
> **Priority: Process quality → Product quality → Delivery speed.**
>
> Project-agnostic. Pipeline-driven. Designed for AI agents, not human employees.

---

## Core Principles

*Learned from 16 sprints of v1 operations. These are non-negotiable.*

1. **Structure over compliance.** If an agent can skip a rule and nothing happens, the rule is decoration. Enforce via CI, automation, and pipeline gates where possible. Where not possible (e.g., in-session orchestration decisions), state the rule clearly and accept it as compliance-reliant — and say so explicitly.

2. **Verification over trust.** "Done" means verified working, not just committed. Every deliverable has a verification step that checks the actual output.

3. **Design for agents, not humans.** Agents are ephemeral, can't see visual output, can't maintain context between sessions, and have limited ability to orchestrate each other. Design around these truths. (See History below — the "agents can't orchestrate" lesson from v1 was later nuanced by discovering it was a config issue, not a fundamental limit.)

4. **State lives in files, not in memory.** Every agent is replaceable at any moment. Repos, configs, and pipelines are the system's memory.

5. **Player experience first.** Before any sprint: "What's the most broken thing about the experience right now?" That's the priority.

6. **Extract learning, don't expect it.** Agents won't voluntarily capture knowledge. Specc extracts learnings from transcripts and writes KB entries post-sprint.

7. **The framework is the real product.** Individual projects are test cases. This framework persists and improves across all projects.

---

## Core Rules (inline — every agent reads these every spawn)

These four rules appear here AND inline in every agent profile so they're load-bearing at decision time:

- **Autonomy default:** Reversible decision? → decide, act, surface in summary. Escalate only for 🔴/🚨 items. Full model: [ESCALATION.md](ESCALATION.md).
- **Comms:** All pipeline messages → studio channel. Never DM the Human Creative Director for pipeline business. Full rules: [COMMS.md](COMMS.md).
- **Secrets:** GitHub PAT lives at `~/.config/gh/brott-studio-token`. Never paste in prompts, URLs, or commit messages. Full rules: [SECRETS.md](SECRETS.md).
- **Framework first:** Every spawn reads FRAMEWORK.md, PIPELINE.md, and your own profile before acting. State lives in files, not agent memory.

---

## Leadership

```
🎬 Human Creative Director (HCD)
   Direction, feel, playtesting, final say

🤖 The Bott — Executive Producer
   Pipeline design, sprint planning, orchestration, framework maintenance
   Spawns Riv per sprint. Intervenes on exceptions.

📋 Riv — Lead Orchestrator
   Executes the sprint pipeline, manages review loops and sub-sprint transitions.
   Spawned by The Bott per sprint.

🕵️ Specc — Inspector (independent)
   Post-sprint audits, learning extraction, KB maintenance.
   Reports to HCD & The Bott directly. Commits to the separate studio-audits repo.
```

---

## Pipeline Agents

Agents are one-shot tools, spawned per pipeline stage by Riv. They don't persist or coordinate with each other — the pipeline manages coordination.

| Stage | Agent | Role | Output |
|---|---|---|---|
| **Design Input** | 🎯 Gizmo | Game Designer — reviews game state against GDD, writes specs | Design spec or "no drift, proceed" |
| **Sprint Planning** | 📋 Ett | Technical PM — unifies design + infra + testing + cleanup | Sprint plan |
| **Build** | 💻 Nutts | Developer — writes code AND tests together | Branch + PR with code + tests |
| **Review** | 👨‍💻 Boltz | Lead Dev — PR review via GitHub App | Approved + merged, or changes requested |
| **Verify** | 🎮 Optic | Verifier — headless tests, Playwright smoke tests, visual regression, combat sims, mocked gameplay checks | Verification report + screenshots |
| **Deploy** | ⚙️ CI/CD | Automated — no agent needed | Live build at URL |
| **Audit** | 🕵️ Specc | Inspector — audit, learning extraction, KB entries | Audit report (committed to `studio-audits`) + KB updates |

**On-demand:** 🔧 Patch (DevOps) — called only when infrastructure breaks.

### Retired Roles
- ~~Glytch (QA)~~ — merged into Optic. One strong Verify stage beats two weak separate stages.

### History: Rivett → Riv + Ett

Rivett was the original combined PM + orchestrator role. Initially retired because the orchestration wasn't working — later root-caused to an OpenClaw `maxSpawnDepth` default preventing Rivett from spawning sub-agents effectively (config issue, not a role design flaw). Rivett was brought back and split cleanly into two roles: **Riv** (orchestrator, runs the pipeline) and **Ett** (project manager, plans the sprint). Both are active canon.

---

## Sprint Pipeline

Full flow detail: [PIPELINE.md](PIPELINE.md).

```
The Bott → spawns Riv with sprint context
  │
  Riv orchestrates sequentially:
  │
  ├─ Gizmo (Design Input) → spec or "no drift"
  ├─ Ett (Plan) → unified sprint plan
  ├─ Nutts (Build) → PR
  ├─ Boltz (Review) → approve/merge or request changes → loop back to Nutts
  ├─ Optic (Verify) → tests/Playwright/sims
  ├─ Specc (Audit) → audit in studio-audits + KB entries
  │
  └─ Ett (Continuation decision):
       ├─ Continue → queue next sub-sprint → Riv loops back to Gizmo/Nutts
       └─ Complete → Riv reports to The Bott
```

### Pipeline Rules
- Each stage reads the previous stage's output. No stage skipping.
- **Continuation gate [Compliance-reliant]:** After Specc's audit lands, Riv hands control back to Ett. Ett decides continue-vs-complete based on audit grade, remaining sprint goals, and any blockers. Riv is mechanical orchestration and does not self-decide continuation.
- **Sub-sprint gate [Compliance-reliant, hard rule]:** Sub-sprint N+1 MUST NOT begin until Specc's sprint-N audit is committed to `studio-audits`. Riv enforces on spawn; Ett flags on planning; The Bott monitors.
- If VERIFY fails → back to BUILD (not "ship anyway")
- If REVIEW requests changes → back to BUILD (not "merge anyway")
- Riv escalates to The Bott per [ESCALATION.md](ESCALATION.md) 🔴/🚨 criteria.
- Pipeline state lives in a sprint file, not in any agent's memory.

---

## Agent Spawn Protocol

Full per-agent templates: [SPAWN_PROTOCOL.md](SPAWN_PROTOCOL.md).

Every agent spawn reads:
1. FRAMEWORK.md (this file)
2. PIPELINE.md
3. Their own profile at `agents/<name>.md`
4. Any cross-referenced policy docs relevant to their task

Secrets handling (PAT authentication) is configured via a credential helper — agents do `git push` normally and the helper reads the PAT from `~/.config/gh/brott-studio-token`. See [SECRETS.md](SECRETS.md). **Never inline the PAT in spawn prompts or URLs.**

### Agents do NOT:
- Log to separate log files (git history IS the log)
- Coordinate with other agents (Riv handles coordination)
- Make product decisions outside their scope (escalate to Riv / The Bott per ESCALATION.md)

---

## Verification Strategy

### Layer 1: Automated Tests (CI)
- Tests run on every PR
- Must pass for merge (structural gate)
- Written by Nutts alongside feature code

### Layer 2: Playwright Visual Testing (Optic)
- Headless browser loads the deployed game
- Screenshots at key screens (menu, shop, loadout, arena, result)
- Visual regression against baseline screenshots
- Smoke test: "does the page load and render content?"
- Stored as artifacts for inspection

### Layer 3: Mocked Gameplay Testing (Optic)
- Run game logic on a fake clock (tick-by-tick)
- Assert gameplay correctness: "bot moved", "projectile fired", "damage applied"
- Not evaluating feel — evaluating correctness of the simulation
- Combat sims for balance data (1000+ matches)

### Layer 4: Human Playtesting (HCD)
- The only test for feel, fun, and visual quality
- Triggered when The Bott determines build is playtest-ready
- HCD's feedback drives the next sprint's priorities

---

## Dashboard (Framework Infrastructure)

The dashboard is NOT a project deliverable. It's framework-level infrastructure.

### Design
- Auto-generated after each sprint from git/PR history
- Shows: sprint log, repo activity, links to GDD/pipeline/audits
- Updated by The Bott as the final pipeline step
- Same dashboard template works for any project

### What It Shows
- Sprint history (completed sprints with summaries)
- Recent repo activity (commits, PRs, merges)
- Links to: GDD, agent roles, pipeline, Specc audits
- Current sprint status (planning/building/verifying/done)
- Test count, PR count, file count

### What It Doesn't Try To Do
- Real-time agent status (agents are ephemeral)
- Live updates during sprints (updated after sprint)
- Complex data aggregation from multiple sources (keep it simple)

---

## Knowledge Base

### How KB Grows
1. **Specc extracts** learnings from agent transcripts post-sprint (primary mechanism)
2. **The Bott writes** framework decisions from leadership discussions
3. **Agents** write entries if they solve novel problems (aspirational, not enforced)

### KB Structure (in project repo)
```
kb/
  patterns/          — reusable approaches that worked
  troubleshooting/   — problems and their fixes
  postmortems/       — what went wrong and why
  decisions/         — why we chose X over Y
```

---

## Repo Structure

Full detail: [REPO_MAP.md](REPO_MAP.md).

| Repo | Owner | Purpose |
|---|---|---|
| `brott-studio/studio-framework` | The Bott | This framework, agent profiles, pipeline templates |
| `brott-studio/<project-repo>` | The Bott | Game code, GDD, KB, dashboard, sprint history |
| `brott-studio/studio-audits` | Specc | Audit reports, independent from project |

---

## Enforcement Mechanisms

Every rule in this framework is tagged **[Structural]** or **[Compliance-reliant]**:

- **[Structural]** = the system itself prevents the violation (CI gate, branch protection, tool access)
- **[Compliance-reliant]** = the rule lives in text and relies on agents reading + following it

| What | How | Type |
|---|---|---|
| Tests must pass | CI gate on PR | [Structural] |
| PR review required | Branch protection | [Structural] |
| Visual verification | Playwright in pipeline | [Structural] |
| Agent logging | Git history IS the log (no separate log files needed) | [Structural] |
| Dashboard freshness | Generated after sprint, not maintained live | [Structural] |
| Sub-sprint Specc gate | Riv + Ett + The Bott all check | [Compliance-reliant] |
| Role boundaries | Pipeline stages (agents only do their stage) | [Compliance-reliant] |
| Secrets handling | PAT in file, credential helper | [Compliance-reliant] (file-based, not CI-gated) |
| Comms routing | Channel not DM | [Compliance-reliant] |
| Escalation tiers | 🟢🟡🔴🚨 model | [Compliance-reliant] |
| Learning capture | Specc extracts from transcripts | [Compliance-reliant] (Specc's primary job) |

### What We Accept (not enforced)
- KB contributions from non-Specc agents (aspirational)
- Perfect sprint-config tracking (git history is the real record)
- Message logs between agents (pipeline stages don't communicate)

---

## Lessons From v1

See [archived v1 framework](archived/v1/) for:
- `KEY_LEARNINGS.md` — 11 deep learnings from 16 sprints
- `FRAMEWORK.md` — v1 framework (human-org-chart model)
- Full sprint history and evolution

Key v1 failures that drove v2 design:
1. Agents can't orchestrate other agents (later nuanced — see Rivett history) → pipeline-driven, Riv orchestrates under The Bott's supervision
2. "Fixed" without verification → mandatory Verify stage with Playwright
3. Dashboard as project deliverable → framework infrastructure
4. Separate QA + Playtest roles → merged into single Verify role (Optic)
5. Behavioral compliance → structural enforcement where possible, explicit compliance-reliance where not
6. State in agent memory → state in files

---

*Framework v2. Maintained by The Bott (Executive Producer).*
*Designed for AI agents. Learned from 16 sprints of v1.*
