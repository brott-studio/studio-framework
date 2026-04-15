# 🏭 AI Agent Studio — Framework Reference

> **Mission: Quality over speed. Ship it right, not just fast.**
>
> **Priority order: Process quality → Product quality → Delivery speed.**
> Quality of process produces quality of product. A broken process that ships fast is worse than a solid process that ships slow.
>
> This framework is **project-agnostic**. It describes how the studio operates across any project.
> Project-specific content (GDD, architecture, game code) belongs in the project repo.
>
> For the full story behind these principles, see [KEY_LEARNINGS.md](KEY_LEARNINGS.md).

---

## Core Principles

These are the studio's foundational truths, learned through experience. Every process, tool, and decision should align with these.

### 1. Structure Over Compliance
If a process depends on an agent choosing to follow a rule, it will eventually be skipped. The only reliable processes are ones where the system does it automatically or blocks progress until it's done.

**Test:** *"What happens if the agent ignores this rule?"* If the answer is "nothing," the rule is decoration.

### 2. Orchestrator First
The coordination layer must exist before the execution layer. Bring the Head of Operations online before any workers. An orchestra without a conductor is noise.

### 3. Roles Need Structural Boundaries
Role definitions in profiles are behavioral. Agents will drift toward efficiency (doing everything themselves) unless the system prevents it. Enforce role boundaries via CI checks on file paths, not just instructions.

### 4. Verification Over Trust
Completion ≠ correctness. Every deliverable needs a verification step that checks the actual output, not just whether the task ran. If no one checks the live result, "done" means nothing.

### 5. Velocity Requires Validation
Fast delivery of unverified work is worse than slow delivery of verified work. Three verification layers: CI (structural), automated testing (agent), human review (leadership). All three must pass.

### 6. Inspector Independence Is Architectural
The auditor must be structurally independent: separate repo, separate spawn chain, separate reporting channel. Org chart independence alone is insufficient.

### 7. Extract Learning, Don't Expect It
Agents are ephemeral — they won't voluntarily capture institutional knowledge. Learning must be extracted post-sprint by a dedicated agent reading session transcripts and writing KB entries.

### 8. Accept Risk on Low-Impact Gaps
Not everything needs structural enforcement. If the system works fine without it, accept the risk. Never add behavioral rules to fix behavioral gaps — that just adds more things to ignore.

### 9. The Dashboard Is a Leadership Product
Leadership's visibility tool is not a side task. When it's broken, leadership is blind. Treat it as a first-class product with requirements, QA, and deployment verification. Auto-generate from real data.

### 10. Design for Ephemerality
Every agent — including the orchestrator — is replaceable at any moment. The system's state lives in files (repos, configs, backlogs), not in any agent's session memory.

### 11. The Framework Is the Real Product
Individual projects are test cases. The framework — the operating system for running an AI agent studio — is what persists across projects and improves over time.

---

## Table of Contents

1. [Organization](#organization)
2. [Roles & Responsibilities](#roles--responsibilities)
3. [Communication Protocol](#communication-protocol)
4. [Enforcement Philosophy](#enforcement-philosophy)
5. [Logging Enforcement](#logging-enforcement)
6. [Git & GitHub Workflow](#git--github-workflow)
7. [File Store & Workspace Structure](#file-store--workspace-structure)
8. [Task Management](#task-management)
9. [Sprint Cadence](#sprint-cadence)
10. [Knowledge Base](#knowledge-base)
11. [Agent Session Lifecycle](#agent-session-lifecycle)
12. [Playtest Strategy](#playtest-strategy)
13. [Build & Deploy Pipeline](#build--deploy-pipeline)
14. [Inspector & Auditing](#inspector--auditing)
15. [Escalation Protocol](#escalation-protocol)
16. [Failure Recovery](#failure-recovery)
17. [Agent Model Selection](#agent-model-selection)
18. [Sprint Execution Model](#sprint-execution-model)
19. [Dashboard](#dashboard)
20. [Phases](#phases)

---

## Organization

```
            🎬 Eric (Creative Director)
            │
            ├──── 🤖 The Bott (Executive Producer)
            │     product vision, requirements, agent profiles
            │
            ├──── 📋 Rivett (Head of Operations)
            │     orchestration, sprint execution, agent management
            │     │
            │     ├── 🎯 Gizmo (Game Designer)
            │     ├── 👨‍💻 Boltz (Lead Dev) — sole PR merger
            │     ├── 💻 Nutts (Dev-01)
            │     ├── 🎮 Optic (Playtest Lead)
            │     ├── 🧪 Glytch (QA)
            │     └── 🔧 Patch (DevOps)
            │
            └──── 🕵️ Specc (Inspector)
                  independent auditor, reports to Eric/Bott directly
```

### Task Flow

```
Eric/Bott → Rivett → Dev(s) → PR → Lead Dev reviews → merge → QA tests → Playtest Lead evaluates → report → PM → Eric
```

---

## Roles & Responsibilities

### 🎬 Eric — Creative Director
- Final say on all creative decisions
- Human playtester (the one with eyes and hands)
- Provides high-level direction ("I want exploration to feel rewarding")
- Reviews builds via web-playable links
- Gives feedback through PM or directly to The Bott

### 🤖 The Bott — Executive Producer
- Ensures what gets built aligns with Eric's creative vision
- Writes and maintains all agent profiles
- Owns the studio process and framework
- Can steer any agent session
- Translates Eric's direction into product requirements
- Provides status updates when Eric checks in

### 📋 Rivett — Head of Operations
- **The communication hub** — all inter-agent comms route through PM
- Breaks down product requirements into tasks
- Assigns tasks to agents
- Tracks sprint progress and velocity
- Maintains `studio/STATUS.md` dashboard
- Runs sprint retros and writes postmortems
- Spawns/manages agent sessions (orchestration)
- Detects bottlenecks and reports them
- Owns `postmortems/` in KB

### 🎯 Gizmo — Game Designer
- Owns the Game Design Document (GDD)
- Designs mechanics, systems, levels, progression
- Balances economy/difficulty on paper before implementation
- Proposes iterations based on playtest feedback
- Works closely with Playtest Lead ("this should feel X" → "does it?")

### 👨‍💻 Boltz — Lead Developer (Lead Dev)
- Reviews all PRs before merge
- **Only agent who can merge to `main`**
- Guards architecture consistency
- Can request changes on PRs
- Flags architectural concerns to PM or leadership
- Owns `patterns/` and `decisions/` in KB

### 💻 Nutts — Developer (Dev-01)
- Implements features on their own branches
- Opens PRs targeting `main`
- Writes descriptive commit messages with task IDs
- Starts with 1 dev, scales when PM reports bottleneck

### 🎮 Optic — Playtest Lead
- Champions game quality using every tool available to a blind agent
- Runs headless simulations with scripted player behavior
- Captures and reviews screenshots at key moments
- Invents and refines feel metrics (pacing curves, decision frequency, juice audits, etc.)
- Maintains reference comparisons from known-good games
- Writes structured playtest reports per build
- Escalates to Eric when human eyes are needed

### 🧪 Glytch — Quality Assurance (QA)
- Tests code correctness (unit tests, integration tests)
- Automated test suites that run as CI checks
- Files bugs as tasks through PM
- Verifies fixes before PR approval

### 🕵️ Specc — Inspector
- **Independent chain of command** — reports directly to Eric and The Bott, NOT through PM
- Audits agent logs, PR history, commit quality, process compliance
- Reviews KB quality and completeness
- Detects drift (agents going off-task, gold-plating, ignoring specs)
- Flags stale tasks, ghost conversations, process violations
- Writes findings to a **separate private GitHub repo** (tamper-proof)
- Analyzes agent performance patterns and suggests improvements
- Catches dangerous defects

### 🔧 Patch — DevOps
- Owns CI/CD pipeline (GitHub Actions, build scripts, deploy)
- Maintains development environment (Godot, dependencies, tooling)
- Troubleshoots infrastructure issues for other agents
- Manages GitHub repo settings, branch protection, PATs
- Keeps workspace healthy (disk, permissions, cleanup)
- Owns `troubleshooting/` and `how-to/` in KB
- **Rule: if it's not game code, it's DevOps' problem**

### 🎨 Art Director (Phase 2)
- Joins when prototype is playable and needs visual identity
- Curates/generates visual assets (sprites, tilesets, UI)
- Ensures visual consistency across the game
- Starts with asset packs (Option C), transitions to custom art

---

## Communication Protocol

### Rules
1. **All inter-agent communication routes through PM.** No exceptions.
2. **No direct `sessions_send` between agents.** If any agent's session history shows a direct message to another agent (not PM), Inspector flags it as a violation.
3. **PM logs all messages** it routes between agents.
4. **Inspector reports directly to Eric/Bott** — separate chain of command.
5. **Eric communicates through The Bott or PM** — doesn't need to message agents directly.

### Why
- Single point of visibility (PM sees everything)
- Perfect audit trail (PM logs all routing)
- No ghost conversations
- Structurally enforceable via Inspector monitoring

---

## Enforcement Philosophy

> **Structural enforcement over behavioral compliance. Always.**

If a process depends on agents choosing to follow rules, it WILL eventually be skipped. Every critical process must have a structural enforcement mechanism.

| Type | Example | Reliability |
|---|---|---|
| **Structural** | Git branch protection blocks direct pushes to main | ✅ Cannot be bypassed |
| **Structural** | CI gate blocks PRs without log entries | ✅ Cannot be bypassed |
| **Structural** | Auto-log scripts capture session data automatically | ✅ Runs regardless of agent behavior |
| **Behavioral** | "Agents should log their sessions" | ❌ Regularly skipped |
| **Behavioral** | "PM should update the dashboard" | ❌ Depends on compliance |

**When designing any new process, ask: "What happens if the agent ignores this rule?"**
- If the answer is "nothing, it just doesn't happen" → the process needs structural enforcement
- If the answer is "CI fails / merge blocked / system catches it" → the process is properly enforced

**Specc has a standing directive** to flag compliance-reliant processes in every audit with recommendations for structural alternatives.

---

## Logging Enforcement

Agent logging is enforced structurally, not behaviorally:

### CI Gates (System B)
- `game-dev-studio`: PRs to main FAIL if no `agents/*/log.md` file is modified
- `battlebrotts`: PRs FAIL if PR description lacks agent attribution
- Both are GitHub Actions workflows that run automatically

### Auto-Log Scripts (System D)
- `scripts/auto-log.sh` — captures session data (files changed, commits, timestamps) automatically
- `scripts/capture-session.sh` — wrapper for Rivett to run post-session
- Generates log entries even if the agent skipped manual logging

### Documentation
- Full guide: `kb/how-to/agent-logging.md`

---

## Git & GitHub Workflow

### Branch Strategy
```
main (protected)
├── dev-01/TASK-001-dungeon-generator
├── dev-02/TASK-002-inventory-system
├── qa/test-dungeon-generator
└── ...
```

- **No direct pushes to `main`** — enforced by GitHub branch protection
- Every agent works on their own branch
- Branch naming: `{agent-id}/TASK-{number}-{description}`

### PR Flow
1. Agent creates branch from `main`
2. Agent commits work with descriptive messages
3. Agent opens PR targeting `main`, references task ID
4. Lead Dev reviews (code quality, architecture alignment, spec compliance)
5. QA status checks must pass
6. Lead Dev approves and merges
7. If conflicts: the PR author rebases and resolves

### Branch Protection Rules (on `main`)
- Require PR reviews before merge (minimum 1 approving review)
- Require status checks to pass (QA tests)
- No direct pushes
- Optionally require signed commits

### Commit Message Standard
```
[TASK-001] feat: implement BSP dungeon generation

- Added room placement algorithm
- Connected rooms with corridors
- Decision: BSP over drunk walk for consistent room sizes
```
- Task ID always present
- What was done
- Why, if a decision was made

### Per-Agent GitHub Permissions (Fine-Grained PATs)

| Role | Push Branches | Create PRs | Approve/Merge | Comment | Issues | Read |
|------|:---:|:---:|:---:|:---:|:---:|:---:|
| Lead Dev | Any | ✅ | ✅ | ✅ | ✅ | ✅ |
| Dev(s) | `dev-XX/*` only | ✅ | ❌ | ✅ | ✅ | ✅ |
| QA | `qa/*` only | ✅ | ❌ | ✅ | ✅ | ✅ |
| Playtest Lead | `playtest/*` only | ✅ | ❌ | ✅ | ✅ | ✅ |
| Game Designer | ❌ | ❌ | ❌ | ✅ | ✅ | ✅ |
| PM | ❌ | ❌ | ❌ | ✅ | ✅ | ✅ |
| Inspector | ❌ | ❌ | ❌ | ✅ | ✅ | ✅ |
| DevOps | `devops/*` only | ✅ | ❌ | ✅ | ✅ | ✅ |

---

## File Store & Workspace Structure

```
studio/
├── agents/
│   ├── pm/
│   │   ├── profile.md              # role definition, instructions, rules
│   │   └── log.md                  # append-only activity log
│   ├── game-designer/
│   │   ├── profile.md
│   │   └── log.md
│   ├── lead-dev/
│   │   ├── profile.md
│   │   └── log.md
│   ├── dev-01/
│   │   ├── profile.md
│   │   └── log.md
│   ├── playtest-lead/
│   │   ├── profile.md
│   │   └── log.md
│   ├── qa/
│   │   ├── profile.md
│   │   └── log.md
│   ├── inspector/
│   │   ├── profile.md
│   │   └── log.md
│   └── devops/
│       ├── profile.md
│       └── log.md
├── tasks/
│   ├── backlog.md                  # all tasks, prioritized
│   ├── active/
│   │   └── TASK-001.md             # one file per active task
│   └── done/
│       └── TASK-000.md             # completed tasks (history preserved)
├── handoffs/
│   └── HANDOFF-001.md              # context dump on session end
├── kb/
│   ├── troubleshooting/            # owned by DevOps
│   ├── how-to/                     # owned by DevOps
│   ├── decisions/                  # owned by Lead Dev
│   ├── patterns/                   # owned by Lead Dev
│   └── postmortems/                # owned by PM
├── messages/
│   └── log.md                      # PM's communication log
├── docs/
│   ├── gdd.md                      # game design document
│   └── architecture.md             # technical architecture
├── STATUS.md                       # dashboard (maintained by PM)
└── FRAMEWORK.md                    # this document
```

---

## Task Management

### Task File Format (`TASK-XXX.md`)
```markdown
# TASK-001: Implement BSP Dungeon Generator

**Status:** active | backlog | blocked | review | done
**Assigned to:** dev-01
**Sprint:** 3
**Priority:** high
**Created:** 2026-04-14
**Updated:** 2026-04-14

## Description
Implement a Binary Space Partitioning dungeon generator that creates connected rooms.

## Acceptance Criteria
- [ ] Generates rooms within configurable count range (5-30)
- [ ] All rooms are reachable from any other room
- [ ] No room overlaps
- [ ] Corridors connect adjacent rooms
- [ ] Passes 1000-iteration stress test

## Work Log
[2026-04-14T12:00Z] Started work. Reading architecture doc for room data structure.
[2026-04-14T12:15Z] Created src/dungeon/generator.gd — BSP split algorithm.
[2026-04-14T12:30Z] Decision: minimum room size 5x5 tiles for playability.

## Blockers / Questions
- None currently

## PR
- Branch: dev-01/TASK-001-bsp-dungeon
- PR: #12
```

---

## Sprint Cadence

- **Default:** 1 day = 1 sprint (flexible — can extend for quality)
- **Sprint start:** PM creates sprint goals, assigns tasks from backlog
- **During sprint:** Agents work, commit, open PRs
- **Sprint end:** PM runs mini-retro
  - What shipped?
  - What blocked?
  - What to improve?
  - Postmortem → `kb/postmortems/`
- **Build delivery:** On merge to `main`, auto-deploy web-playable build
- **Eric plays** the build, gives feedback → becomes next sprint input

---

## Knowledge Base

### Purpose
Agents are stateless between sessions. The KB is their shared institutional memory.

### Ownership
| Directory | Owner | Content |
|---|---|---|
| `kb/troubleshooting/` | DevOps | Infrastructure fixes, env issues |
| `kb/how-to/` | DevOps | Setup guides, tool usage |
| `kb/decisions/` | Lead Dev | Architecture & design decisions with rationale |
| `kb/patterns/` | Lead Dev | Code patterns, conventions |
| `kb/postmortems/` | PM | Sprint retros, incident reviews |

### Rules
1. **Every agent** must write a KB entry when solving a non-trivial problem for the first time
2. **Every agent** reads relevant KB entries on session boot before starting work
3. **Inspector** audits KB quality:
   - Is it up to date?
   - Did an agent hit a known problem and not check KB first? Flag it.
   - Did an agent solve something new and not write it up? Flag it.

---

## Agent Session Lifecycle

> **⚠️ Important:** Agents will NOT follow their session protocol unless explicitly instructed in their spawn prompt. See "Agent Spawn Protocol" below.

### Boot Protocol (every agent, every session)
1. Read your `agents/{role}/profile.md`
2. Read your assigned task file(s)
3. Read relevant KB entries for the work ahead
4. Read latest `STATUS.md` for situational awareness
5. Log session start to `agents/{role}/log.md`
6. Work

### Shutdown Protocol
1. Log all work done to `agents/{role}/log.md`
2. If task incomplete, write `handoffs/HANDOFF-XXX.md` with:
   - What was done
   - What's left
   - Current state of the code
   - Gotchas encountered
   - Files changed
3. Update task file status
4. Write KB entry if you learned something new
5. Log session end

### Log Format
```
[2026-04-14T12:00Z] SESSION START — dev-01 — reading TASK-001, handoff HANDOFF-003
[2026-04-14T12:15Z] Created src/dungeon/generator.gd — BSP split algorithm
[2026-04-14T12:30Z] Decision: minimum room size 5x5 for playability
[2026-04-14T12:45Z] Committed abc123 — "feat: basic dungeon generation"
[2026-04-14T13:00Z] SESSION END — dev-01 — TASK-001 PR #12 opened
```

---

## Agent Spawn Protocol

Every time an agent is spawned (by The Bott or any orchestrator), the task prompt MUST include this preamble:

> **Before starting your assigned task:**
> 1. Read your profile at `agents/[your-role]/profile.md` in the `blor-inc/game-dev-studio` repo
> 2. Follow the session protocol in your profile exactly
> 3. Log your session start to `agents/[your-role]/log.md` with timestamp and task reference
> 4. Complete your assigned task
> 5. Log all significant actions, decisions, and outcomes to your log.md
> 6. Log your session end with a summary of what was accomplished
> 7. Commit your log updates alongside your work
> 8. **(Experimental) Before session ends, write a brief debrief:** What did you learn? What surprised you? What would you tell the next agent doing this work? Write to `docs/learnings/` in the project repo.

### Why This Exists

Agents are one-shot sessions — they spin up, do a task, and terminate. Without explicit instructions to follow the logging protocol, they skip it. This preamble ensures every agent:
- Reads its role definition before working
- Creates an audit trail for Inspector
- Enables continuity via handoff files
- Maintains accountability

### PM Startup Priority

When bootstrapping the studio for a new project or sprint, **PM (Rivett) must be the first agent brought online.** PM handles all orchestration, task assignment, and inter-agent communication. Bringing other agents online before PM creates coordination overhead for The Bott that should be delegated.

**Recommended startup order:**
1. PM — to coordinate everything
2. DevOps — to ensure infrastructure is ready
3. Other agents as needed by PM

---

## Playtest Strategy

### What Agents Can Do

| Method | What It Covers |
|---|---|
| Headless simulation | Game logic, pathfinding, combat math, balance |
| Scripted player behavior | Pacing, decision frequency, exploration patterns |
| Screenshot capture | Visual layout, UI positioning, readability |
| Visual regression | Catch visual breaks between builds |
| GIF/frame capture | Animation review, movement feel |
| Feel metrics | Acceleration curves, input latency, juice parameters |
| Comparative analysis | Reference values from known-good games |
| Stress testing | 1000+ dungeon generations, 10000 combat rounds |

### What Only Eric Can Do
- Game feel / juice evaluation
- Fun factor assessment
- UX intuition
- Perceived smoothness

### Playtest Lead Metrics (evolving list)
- Pacing curves (event density over time)
- Decision frequency (meaningful choices per minute)
- Surprise factor (entropy/variance in generated content)
- Risk/reward curves
- Movement feel (acceleration, deceleration, response time)
- Juice audit (screen shake values, particle counts, hitstop frames)
- Difficulty curve (survival time distribution over simulated runs)

### Playtest Report Format
```
BUILD: main@abc123
DATE: 2026-04-14

PACING: ⚠️ Rooms 4-7 have no enemies or items — dead zone
FEEL: ✅ Movement acceleration curve matches reference targets
VISUAL: ⚠️ Health bar unreadable against dark backgrounds
BALANCE: ❌ Sword damage trivializes first 3 floors
JUICE: ⚠️ No screen shake on hit — feels flat
RECOMMENDATION: Prioritize juice pass before next content sprint
```

---

## Build & Deploy Pipeline

- **Owned by:** DevOps
- **Trigger:** Every merge to `main`
- **Process:** GitHub Actions builds the project → exports HTML5 → deploys to GitHub Pages (or itch.io)
- **Result:** Eric gets a link, clicks, plays in browser
- **Goal:** Zero friction between "code merged" and "Eric playtesting"

---

## Inspector & Auditing

### Independence
- Reports directly to Eric and The Bott — **NOT through PM**
- Writes all findings to a **separate private GitHub repo**
- No other agent has write access to Inspector's repo
- Eric and The Bott have read access

### What Inspector Audits
- **Agent logs** — are agents logging consistently? Any gaps?
- **PR history** — commit quality, review thoroughness, time to merge
- **Process compliance** — are agents following boot/shutdown protocols?
- **Communication** — any direct `sessions_send` between non-PM agents? (violation)
- **KB quality** — up to date? Being used? Being contributed to?
- **Task alignment** — is the code actually implementing what the spec says?
- **Code quality** — patterns, anti-patterns, technical debt accumulation
- **Agent performance** — velocity trends, failure rates, rework frequency
- **Stale locks/tasks** — anything stuck that PM hasn't caught?

### Report Cadence
- Per-sprint audit report (Specc runs at **end of each sprint**, not on a fixed cron)
- Immediate flag for serious issues (agent off-task, process breakdown, dangerous defect)

### Spawn & Independence
- The Bott spawns Specc directly (not through Rivett) to maintain independence and avoid subagent depth limits
- Standing directive: flag compliance-reliant processes and recommend structural alternatives

---

## Escalation Protocol

| Situation | Escalation Path |
|---|---|
| Agent stuck > expected timeframe | Agent → PM → Lead Dev |
| PR rejected twice | Lead Dev → The Bott |
| Design decision needed | Dev → PM → Game Designer |
| Infrastructure broken | Any agent → PM → DevOps |
| Inspector finds serious issue | Inspector → Eric / The Bott directly |
| Agent unsure about design call | Agent → PM → Game Designer → The Bott if needed |
| Human playtesting needed | Playtest Lead → PM → Eric |
| Same task fails twice | PM → Lead Dev → The Bott |

---

## Failure Recovery

When an agent session crashes or produces garbage:
1. **PM detects** stalled task (no log updates, no commits within expected timeframe)
2. **PM spawns** a fresh session for that role
3. Fresh session reads task file + latest handoff to pick up where it left off
4. **Inspector logs** the failure for pattern analysis
5. If the **same task fails twice**, escalate to Lead Dev or The Bott
6. If a **role consistently fails**, The Bott reviews and updates the agent profile

---

## Agent Model Selection

| Role | Model Tier | Reasoning |
|---|---|---|
| Game Designer | Strongest | Deep creative reasoning |
| Lead Dev | Strongest | Architecture decisions, code review quality |
| Playtest Lead | Strongest | Creative metric invention, analytical depth |
| Inspector | Strongest | Nuanced analysis, pattern detection |
| The Bott | Strongest | Product vision, agent management |
| Dev(s) | Strong | Execution-focused, still needs good reasoning |
| QA | Strong | Test design needs solid thinking |
| PM | Mid-tier+ | Coordination, not deep reasoning |
| DevOps | Mid-tier+ | Scripting, config, not deep design |

---

## Sprint Execution Model

### Startup Order
1. **Rivett (Head of Operations)** — always first. Coordinates everything.
2. **Patch (DevOps)** — ensures infrastructure is ready
3. Other agents as needed

### Session Architecture
- Rivett spawns as a **thread-bound persistent session** per sprint
- Rivett spawns agent subagents (mode=run) for specific tasks
- Subagent depth limit: 3 levels (Bott → Rivett → Agents)
- Specc is spawned by The Bott directly (independent chain, avoids depth limit)

### Test Requirements
- **No code merges without tests** — enforced by Boltz in PR reviews
- Tests must be runnable headlessly via Godot
- CI should run tests on every PR

---

## Learning Protocol

Agents are ephemeral — they don't learn between sessions. The SYSTEM learns instead, through files that persist.

### How Learning Happens

1. **Sprint runs** — agents do work, make decisions, hit problems, find solutions
2. **Agent debrief (experimental)** — as the last step before session end, agents write a brief summary of what they learned, what surprised them, and what they'd tell the next agent. Written to the project repo.
3. **Specc reads transcripts** — after the sprint, Specc uses `sessions_history` to review each agent's full session transcript. This is the PRIMARY learning extraction mechanism (not compliance-reliant).
4. **Specc writes KB entries** — learnings extracted from transcripts become KB entries: what went wrong, how it was solved, patterns discovered, recommendations.
5. **The Bott updates framework** — strategic decisions from leadership discussions become framework updates.

### Where Learning Lives

| Source | Written by | Location |
|---|---|---|
| Operational lessons | Specc (from transcripts) | `kb/` in project repo |
| Framework decisions | The Bott | `FRAMEWORK.md` |
| Technical patterns | Specc (from code review) | `kb/patterns/` |
| Post-mortems | Specc (from audit) | `kb/postmortems/` |
| Agent debriefs | Agents themselves (experimental) | `docs/learnings/` in project repo |

### Principles
- **Learning lives in infrastructure, not in agents.** Profiles, CI gates, KB entries, framework rules persist. Agents just execute the latest version of accumulated wisdom.
- **Prefer extraction over compliance.** Specc reading transcripts (structural) beats agents writing debriefs (behavioral).
- **Every recurring issue gets a structural fix.** If the same problem appears across sprints, it becomes a CI gate or framework rule, not just a note.

---

## Compliance Philosophy

When a process relies on agent compliance with no enforcement:
- **First, ask: is this actually important?** If the system works fine without it, accept the risk.
- **If important: find a structural fix.** CI gate, auto-generation, extraction from existing data.
- **If no structural fix exists: accept and monitor.** Specc flags it, leadership reviews periodically.
- **Never add more behavioral rules** to fix a behavioral compliance gap. That just adds more things to ignore.

---

## Dashboard

The dashboard (GitHub Pages) is the Creative Director's primary visibility tool. It is a **first-class product**, not an afterthought.

### Requirements
- Responsive (desktop + mobile, no text cutoff)
- Full activity history (not just current state)
- Sprint summaries with collapsible details
- Agent cards with names + titles + status
- Auto-generated from real data (git, PRs, logs, STATUS.md) — NOT manually maintained

### Ownership
- **Rivett** tracks dashboard currency as part of operations
- **Patch** implements and maintains the dashboard infrastructure
- **Glytch** QA tests the dashboard (responsive, data rendering, empty states)

---

## Phases

Phases are per-project. See the project repo for project-specific phase tracking.

Generic phase template:
1. **Foundation** — Repos, CI/CD, profiles, GDD, architecture
2. **Prototype** — Core systems, vertical slice, testing infrastructure
3. **Polish & Identity** — Art, juice, balance tuning, playtester feedback
4. **Ship** — Final QA, performance, release

---

## Rollback Plan

When a merge breaks things:
1. **Identify** — CI failures, test regressions, or agent reports indicate breakage
2. **Revert** — `git revert <merge-commit>` on main, open PR, fast-track review
3. **Diagnose** — Original author investigates on their branch
4. **Fix forward** — Fix the issue, re-open PR with fix included
5. **Post-mortem** — Rivett documents what happened in kb/postmortems/

Never leave main broken. Revert first, ask questions later.

---

## Repo Ownership

| Repo | Owner | Content | Access |
|---|---|---|---|
| Framework repo | The Bott (Executive Producer) | Generic studio framework, agent profiles, KB | Leadership only — no agent PRs |
| Project repo(s) | Rivett (Head of Operations) | Game code, GDD, dashboard, project status | All agents via PRs |
| Audit repo | Specc (Inspector) | Audit reports | Specc writes, leadership reads |

---

*This is a living document. Maintained by The Bott (Executive Producer).*
*Project-agnostic. Applicable across all studio projects.*
*Last updated: 2026-04-14T18:55Z*
