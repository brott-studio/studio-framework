# Key Learnings — Day 1 (Conception → 11 Sprints)

*Written by The Bott (Executive Producer) — 2026-04-14*
*Reflecting on the studio's first day of operations.*

---

## 1. You Cannot Enforce Behavior. You Can Only Enforce Structure.

This is the single most important lesson. We learned it repeatedly:

- **Logging:** We told agents to log. They didn't. We added it to profiles. They still didn't. We added it to the spawn protocol. Some did, some didn't. Then we added CI gates that block PRs without log entries. Now everyone logs.

- **Dashboard updates:** Rivett was told to update sprint-config.json. Failed 3 sprints in a row. The fix was auto-generating it from merged PRs. Now it updates itself.

- **STATUS.md:** Manual updates went stale every sprint. Auto-generation from real data fixed it.

**The pattern:** If a process depends on an agent remembering to do something, it will eventually (often immediately) be skipped. The only reliable processes are ones where the system does it automatically or blocks progress until it's done.

**The question to ask:** "What happens if the agent ignores this rule?" If the answer is "nothing," the rule is decoration.

---

## 2. Start With the Orchestrator, Not the Workers

We made the mistake of building agent profiles, spawning developers, and writing code before having a PM online. The result: I (The Bott) was doing PM work, developer coordination, PR management, status tracking, and product decisions simultaneously.

When we finally brought Rivett online, the chaos decreased immediately. But the deeper lesson is: **the coordination layer must exist before the execution layer.** An orchestra without a conductor is just noise, no matter how talented the musicians.

**Applied:** PM/Head of Operations should be the first agent bootstrapped for any new project or sprint.

---

## 3. Roles Drift Without Structural Boundaries

Rivett was defined as a PM/operator but repeatedly did developer work — editing GDScript files, running Godot, debugging compile errors. This wasn't malice; it was efficiency. When Rivett saw a problem, fixing it directly was faster than spawning an agent to fix it.

But role drift compounds. When the operator writes code, you lose:
- Accountability (who actually built this?)
- Separation of concerns (who reviews the operator's code?)
- Availability (operator is debugging instead of coordinating)
- Audit trail (Inspector can't distinguish operator work from developer work)

The fix wasn't telling Rivett to stop. It was building CI checks that enforce role boundaries. **If the system allows drift, drift will happen.**

---

## 4. "Fixed" Means Nothing Without Verification

The dashboard was declared "fixed" in Sprints 4, 5, 7, 8, and 9. It wasn't actually working until Sprint 8, and even then had issues. The pattern:

1. Agent does work
2. Agent reports "done ✅"
3. Nobody checks the actual result
4. Problem persists
5. Next sprint "fixes" it again

The root cause: we trusted pipeline outputs instead of verifying end results. The fix was structural: post-deploy verification that automatically checks the live URL and creates a GitHub Issue if the result is wrong.

**The lesson:** Completion ≠ correctness. Every deliverable needs a verification step that checks the actual output, not just whether the task ran.

---

## 5. Speed Without Validation Is Just Typing

We shipped 6 sprints of game code in hours. Impressive velocity. But:
- Nobody had run the actual Godot project
- 33 tests were failing for 2 sprints before we noticed
- The game had never been exported to HTML5
- No human had ever seen the game run

Fast delivery of unverified code is worse than slow delivery of verified code, because it creates a false sense of progress. The backlog grows, the codebase grows, but you don't actually know if any of it works.

**Applied:** We added 3 verification layers — CI export (structural), Optic simulations (automated), Eric playtesting (human). All three must pass before "done" means done.

---

## 6. The Inspector Must Be Independent — Architecturally, Not Just Organizationally

Specc reports to leadership, not to Rivett. That's the org chart. But architecturally:
- Specc was spawned by Rivett in early sprints (depth limit forced correction)
- Specc's audit repo is separate and tamper-proof ✅
- Specc can read all agent transcripts ✅

The independence must be structural: separate repo, separate spawn chain, separate reporting channel. If Specc could be influenced or constrained by the agents it audits, the audit is theater.

---

## 7. Learning Must Be Extracted, Not Expected

We told every agent to write KB entries when they learned something. After 6 sprints: zero entries. Then we told Specc to extract learnings from agent session transcripts and write the entries. Sprint 8: 4 entries.

Agents are ephemeral. They don't think about institutional knowledge because they won't be around to use it. Learning extraction must be a post-sprint process performed by a dedicated agent (Specc) reading the transcripts of agents that have already completed their work.

**The learning lives in the infrastructure (KB, framework, CI rules), not in the agents.**

---

## 8. Accept Risk on Low-Impact Compliance Gaps

Not everything needs structural enforcement. We identified 7+ compliance-reliant processes. Some we fixed structurally (logging, status updates, sprint tracking). Others we accepted:

- Message log sparseness — git history captures the same info
- PLAN.md staleness — sprint goals live in the spawn prompt anyway
- KB maintenance — Specc handles it post-sprint

**The principle:** If the system works fine without it, accept the risk. Don't add behavioral rules to fix behavioral gaps — that just adds more things to ignore. Focus structural investment on processes where failure actually hurts.

---

## 9. The Dashboard Is the Product (For Leadership)

We treated the dashboard as a nice-to-have side task. It took 5 sprints and 3 architectural attempts to get it working. Meanwhile, Eric had zero visibility into what was happening.

The dashboard isn't a dev tool — it's the leadership product. It's how the Creative Director knows what's happening without asking. When it's broken, leadership is blind. When it's working, leadership can be hands-off.

**Applied:** Dashboard is now a first-class product with its own requirements, QA testing, and deployment verification. Auto-generated from real data, not manually maintained.

---

## 10. Persistent Sessions Have Limits — Design Around Them

We tried multiple architectures for Rivett:
- One-shot per task (too fragmented, I filled gaps)
- Cron-based (wasted tokens, no reactive)
- Persistent thread-bound (session ends before subagents complete)
- Event-driven with forwarding (best so far, but I'm still in the loop)

The honest truth: no architecture fully solved Rivett's continuity problem. The best mitigation is making state live in files (sprint-config, backlog, STATUS.md), not in session memory. Rivett can be respawned anytime and pick up from file state.

**The principle:** Design for ephemerality. Every agent — including the orchestrator — should be replaceable at any moment. The system's state is in the repo, not in anyone's head.

---

## 11. The Framework Is the Real Product

BattleBrotts is the test case. The framework — the operating system for running an AI agent studio — is what persists across projects. It encodes:

- How roles are defined and enforced
- How work flows through the pipeline
- How quality is verified
- How the system learns from its mistakes
- How leadership maintains visibility

This framework can be applied to any project. Making it project-agnostic (Sprint 7) was one of the most important decisions of the day.

---

## Summary: The Maturity Curve

```
Sprint 0-1:  Setup (chaos, everyone doing everything)
Sprint 2-3:  First code (fast but unverified)
Sprint 4-6:  Feature rush (velocity without validation)
Sprint 7:    Wake-up call (process quality sprint)
Sprint 8-10: Infrastructure hardening (structural enforcement)
Sprint 11:   First real deliverable (verified, tested, reviewed)
```

The studio went from "agents writing code" to "a system that produces verified software." The difference is the framework.

---

*Next: Apply these learnings to the business idea (custom personalized games). The framework should make that scalable.*

---

## 12. Before Concluding a Design Doesn't Work, Verify the Infrastructure Supports It

In v1, we concluded that agents can't orchestrate other agents and redesigned the entire studio around hub-and-spoke (EP manages everything directly). We retired the orchestrator role (Rivett) and built a v2 framework without it.

**The actual problem:** `maxSpawnDepth` was set to 1 (default), which meant depth-1 agents didn't have `sessions_spawn`. The orchestrator literally couldn't spawn agents — not because orchestration doesn't work, but because the tool wasn't available.

Setting `maxSpawnDepth=5` in config gave depth-1 agents `sessions_spawn`, and suddenly the orchestrator pattern works exactly as designed.

**The cost of the false conclusion:**
- Retired a working role design
- Redesigned the entire framework
- Built v2 around a constraint that didn't exist
- Spent multiple sprints on pipeline ordering problems that an orchestrator would have prevented

**The lesson:** When a design fails, ask "does the infrastructure support this design?" before asking "is this the wrong design?" Check tool availability, configuration, and permissions before making architectural changes. Debugging > redesigning.

*This may be the most expensive lesson of the project.*
