# Multi-Agent Orchestration Patterns

*Reference from [learnopenclaw.org/multiagent](https://learnopenclaw.org/multiagent.html)*

---

## Four Core Patterns

### 1. Fan-Out / Fan-In (Parallel)

Orchestrator spawns multiple agents simultaneously, merges results when all complete.

```
ORCHESTRATOR
├── spawn(agent_1, task_A)  ──┐
├── spawn(agent_2, task_B)  ──┼── all run concurrently
└── spawn(agent_3, task_C)  ──┘
         ↓
MERGE: combine results
OUTPUT → final deliverable
```

**Best for:** Research, batch processing, independent subtasks
**Our use:** Potential future — parallel dev tasks on independent features

---

### 2. Pipeline / Chain (Sequential)

Each agent passes output to the next. Linear flow.

```
agent_1 → [output] → agent_2 → [output] → agent_3 → [output] → agent_4
```

**Best for:** Build → Review → Verify → Audit flows
**Our use:** ✅ This is our primary pattern (Riv orchestrates sequentially)

---

### 3. Hierarchical (Nested Orchestrators)

Master orchestrator delegates to sub-orchestrators, each managing their own fleet.

```
MASTER ORCHESTRATOR
├── spawn(orchestrator_A, goal="research")
│   ├── spawn(agent_1, subtask)
│   └── spawn(agent_2, subtask)
│
└── spawn(orchestrator_B, goal="implement")
    ├── spawn(agent_3, subtask)
    └── spawn(agent_4, subtask)
```

**Best for:** Complex multi-phase projects, parallel workstreams
**Our use:** Future — Riv could spawn sub-orchestrators for parallel sprint tracks
**Depth required:** maxSpawnDepth ≥ 3

---

### 4. Competitive (Best-of-N)

Multiple agents attempt the same task, critic scores them, best one wins.

```
ORCHESTRATOR
├── spawn(agent_A, same_task) → output_A (score: 8.2)
├── spawn(agent_B, same_task) → output_B (score: 9.1) ✓ winner
└── spawn(agent_C, same_task) → output_C (score: 7.6)
```

**Best for:** Creative tasks, writing, design where quality varies
**Our use:** Potential — multiple Gizmo variants for design exploration

---

## Key Concepts

### Orchestrator
Top-level agent that decomposes goals, delegates, assembles results. Has `sessions_spawn` tool.

### Sub-Agents
Specialized child instances for individual tasks. Run independently in their own sessions.

### Critic Agent
Optional reviewer that checks sub-agent output for quality before the orchestrator merges.

### Permission Bubbling
If a sub-agent needs a permission not in its scope, it escalates to the orchestrator rather than acting unilaterally.

### Shared Memory
Agents can pass findings via shared storage (files, repos) without passing full context.

---

## Agent Roles Reference

| Role | Can Spawn? | Memory Access | Purpose |
|------|-----------|---------------|---------|
| Orchestrator | ✅ Yes | Full read/write | Decompose, delegate, assemble |
| Research Agent | ❌ No | Write own namespace | Search, retrieve, extract |
| Code Agent | ❌ No | Read shared + write own | Build, test, debug |
| Writer Agent | ❌ No | Read shared | Draft, summarize, document |
| Critic Agent | ❌ No | Read all | Review, score, flag issues |

---

## Safety & Guardrails

- **Agent Timeouts:** Configurable TTL per sub-agent. Orchestrator handles failures.
- **Token Budget Caps:** Prevents runaway costs in large fleets.
- **Permission Scoping:** Sub-agents only get explicitly delegated permissions.
- **Audit Logs:** Every action logged with timestamp and agent ID.
- **Conflict Detection:** Contradictory outputs flagged before merging.
- **Human Checkpoints:** HITL pauses at defined milestones.

---

## Depth Limits (maxSpawnDepth)

| Config | Max Chain | Use Case |
|--------|-----------|----------|
| 1 (default) | Main → Worker | Simple tasks |
| 2 | Main → Orchestrator → Worker | Our pipeline pattern |
| 3 | Main → Master → Sub-orchestrator → Worker | Hierarchical |
| 5 (max) | Deep nesting with review loops | Complex pipelines with error recovery |

**Our config:** `maxSpawnDepth=5` — supports full pipeline + review loops.

---

## How We Use These Patterns

**Primary: Pipeline (Pattern 2)**
```
The Bott → Riv (orchestrator) → Nutts → Boltz → Optic → Specc
```

**With review loop:**
```
Riv → Nutts → Boltz → [comments?] → Nutts fix → Boltz re-review → Optic → Specc
```

**Future: Hierarchical (Pattern 3)**
```
The Bott → Riv → Ett (plan sprint) → Riv → execute pipeline → repeat
```

**Future: Competitive (Pattern 4)**
```
Gizmo_A and Gizmo_B both design a feature → Critic picks the better one
```

---

*Source: [learnopenclaw.org/multiagent](https://learnopenclaw.org/multiagent.html)*
*Adapted for Brott Studio framework context.*
