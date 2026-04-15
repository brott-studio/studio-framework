# 🏭 AI Agent Studio — Framework v2

> **Mission: Quality over speed. Ship it right, not just fast.**
>
> **Priority: Process quality → Product quality → Delivery speed.**
>
> Project-agnostic. Pipeline-driven. Designed for AI agents, not human employees.

---

## Core Principles

*Learned from 16 sprints of v1 operations. These are non-negotiable.*

1. **Structure over compliance.** If an agent can skip a rule and nothing happens, the rule is decoration. Enforce via CI, automation, and pipeline gates — not instructions.

2. **Verification over trust.** "Done" means verified working, not just committed. Every deliverable has a verification step that checks the actual output.

3. **Design for agents, not humans.** Agents are ephemeral, can't see visual output, can't maintain context between sessions, and can't orchestrate each other reliably. Design around these truths.

4. **State lives in files, not in memory.** Every agent is replaceable at any moment. Repos, configs, and pipelines are the system's memory.

5. **Player experience first.** Before any sprint: "What's the most broken thing about the experience right now?" That's the priority.

6. **Extract learning, don't expect it.** Agents won't voluntarily capture knowledge. Specc extracts learnings from transcripts and writes KB entries post-sprint.

7. **The framework is the real product.** Individual projects are test cases. This framework persists and improves across all projects.

---

## Leadership

```
🎬 Eric — Creative Director
   Direction, feel, playtesting, final say

🤖 The Bott — Executive Producer
   Pipeline design, sprint planning, orchestration, framework maintenance
   Spawns all agents directly. No intermediary orchestrator.

🕵️ Specc — Inspector (independent)
   Post-sprint audits, learning extraction, KB maintenance
   Reports to Eric & The Bott directly. Separate audit repo.
```

---

## Pipeline Agents

Agents are one-shot tools, spawned per pipeline stage. They don't persist, coordinate with each other, or manage state. The pipeline manages them.

| Stage | Agent | Role | Output |
|---|---|---|---|
| **Design** | 🎯 Gizmo | Game Designer — specs, balance decisions, GDD updates | Design spec for the sprint |
| **Build** | 💻 Nutts | Developer — writes code AND tests together | Branch + PR with code + tests |
| **Review** | 👨‍💻 Boltz | Lead Dev — PR review via GitHub App | Approved + merged, or changes requested |
| **Verify** | 🎮 Optic | Verifier — headless tests, Playwright smoke tests, visual regression, combat sims, mocked gameplay checks | Verification report + screenshots |
| **Deploy** | ⚙️ CI/CD | Automated — no agent needed | Live build at URL |
| **Audit** | 🕵️ Specc | Inspector — audit, learning extraction, KB entries | Audit report + KB updates |

**On-demand:** 🔧 Patch (DevOps) — called only when infrastructure breaks.

### Retired Roles
- ~~Rivett (Head of Operations)~~ — agents can't reliably orchestrate other agents. The Bott orchestrates directly.
- ~~Glytch (QA)~~ — merged into Optic. One strong Verify stage beats two weak separate stages.

---

## Sprint Pipeline

Each sprint follows this pipeline. The Bott executes it step by step.

```
Sprint N Pipeline
═══════════════════

1. PLAN        The Bott defines sprint goals based on:
               - Eric's direction / playtest feedback
               - Specc's audit findings
               - Backlog priorities
               
2. DESIGN      Gizmo writes specs (if needed — skip for pure bugfix sprints)

3. BUILD       Nutts implements code + tests on a branch, opens PR
               PR title must include [SN-XXX] task ID

4. REVIEW      Boltz reviews PR via GitHub App
               Must use review checklist
               Approve + merge, or request changes → back to BUILD

5. VERIFY      Optic runs:
               - All headless tests (must pass)
               - Playwright smoke tests (page loads, elements render)
               - Visual regression (screenshots vs baseline)
               - Combat sims if balance-relevant (1000+ matches)
               - Mocked gameplay sequence checks
               Output: verification report + screenshots

6. DEPLOY      CI/CD auto-builds and deploys on merge
               Post-deploy smoke test verifies live URL

7. AUDIT       Specc audits the sprint:
               - Code quality, process compliance
               - Compliance-reliant process detection
               - Learning extraction from agent transcripts
               - Writes KB entries (mandatory, not advisory)
               Output: audit report + KB updates

8. REPORT      The Bott updates dashboard, saves memory
               Pings Eric only if: playtest-ready, decision needed, or issue flagged
```

### Pipeline Rules
- Each stage reads the previous stage's output. No stage skipping.
- If VERIFY fails → back to BUILD (not "ship anyway")
- If REVIEW requests changes → back to BUILD (not "merge anyway")
- The Bott handles exceptions (failures, blockers, escalations)
- Pipeline state lives in a sprint file, not in any agent's memory

---

## Agent Spawn Protocol

Every agent gets this preamble:

```
Before starting:
1. Clone the framework repo and read your profile:
   git clone https://[PAT]@github.com/brott-studio/studio-framework.git /tmp/framework
   Read: /tmp/framework/agents/[your-name].md
2. You are [Agent Name], [Role] for [Project Name]
3. Your task: [specific task with clear deliverables]
4. Write code + tests together (if applicable)
5. PR title must include [SN-XXX] task ID
6. Git config: user.name "[Name]", user.email "[name]@brott-studio.studio"
7. [GitHub PAT and any auth needed]
```

### Why agents clone their profile
- Profiles are the **single source of truth** for role behavior
- Updates to profiles take effect immediately (no need to update spawn prompts)
- Specc can verify agents read their profiles
- State in files, not in memory — consistent with Core Principle #4

### Agents do NOT:
- Log to separate log files (git history IS the log)
- Coordinate with other agents (pipeline handles coordination)
- Make product decisions (escalate to The Bott)

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

### Layer 4: Human Playtesting (Eric)
- The only test for feel, fun, and visual quality
- Triggered when The Bott determines build is playtest-ready
- Eric's feedback drives the next sprint's priorities

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

| Repo | Owner | Purpose | Access |
|---|---|---|---|
| `studio-framework` | The Bott | This framework, agent profiles, pipeline templates | Private, leadership only |
| `[project-repo]` | The Bott | Game code, GDD, KB, dashboard, sprint history | Public or private per project |
| `studio-audits` | Specc | Audit reports, independent from project | Private, leadership reads |

---

## Enforcement Mechanisms

| What | How | Type |
|---|---|---|
| Tests must pass | CI gate on PR | Structural |
| PR review required | Branch protection | Structural |
| Visual verification | Playwright in pipeline | Structural |
| Agent logging | Git history IS the log | Structural (no separate log files) |
| Dashboard freshness | Generated after sprint, not maintained live | Structural |
| Role boundaries | Pipeline stages (agents only do their stage) | Structural |
| Learning capture | Specc extracts from transcripts | Process (reliable — Specc's primary job) |

### What We Accept (not enforced)
- KB contributions from non-Specc agents (aspirational)
- Perfect sprint-config tracking (git history is the real record)
- Message logs between agents (pipeline stages don't communicate)

---

## Lessons From v1

See [archived game-dev-studio repo](https://github.com/brott-studio/game-dev-studio) for:
- `KEY_LEARNINGS.md` — 11 deep learnings from 16 sprints
- `FRAMEWORK.md` — v1 framework (human-org-chart model)
- Full sprint history and evolution

Key v1 failures that drove v2 design:
1. Agents can't orchestrate other agents → pipeline-driven, EP orchestrates
2. "Fixed" without verification → mandatory Verify stage with Playwright
3. Dashboard as project deliverable → framework infrastructure
4. Separate QA + Playtest roles → merged into single Verify role (Optic)
5. Behavioral compliance → structural enforcement or accept the risk
6. State in agent memory → state in files

---

*Framework v2. Maintained by The Bott (Executive Producer).*
*Designed for AI agents. Learned from 16 sprints of v1.*
