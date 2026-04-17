# Escalation Policy

How the studio lead (Riv) and any orchestrator should decide when to proceed autonomously, when to surface in a summary, and when to escalate to Eric (product owner / creative director) before acting.

**Default when in doubt:** decide, act, surface in summary. A reversible decision made autonomously is almost always better than a blocking escalation.

---

## 🟢 Proceed autonomously — do NOT escalate

- Defensible trade-offs where 2+ reviewers align (e.g., Boltz + Nutts both approve)
- Bug fixes, test changes, refactors that fit the sprint brief
- Sub-sprint transitions within an approved arc
- Scope interpretation inside the creative brief's boundaries
- Any decision where Gizmo has design authority and has made a call
- Process/tooling improvements that serve the existing brief
- Test threshold adjustments that are defended with data (surface in summary, don't block on them)

## 🟡 Surface in sprint summary (not before-the-fact)

- Test threshold changes (defend the change in the summary)
- Non-blocking reviewer nits carried forward to next sprint
- Role-drift corrections after they happen
- Approach changes that stayed within the brief
- Trade-offs accepted during the sprint

## 🔴 Escalate BEFORE acting

- Arc-level scope changes (e.g., "I want to add audio to this sprint")
- Cutting planned features the brief specifically promised
- Creative direction Eric hasn't weighed in on (new tone, new game system, new player-facing concept)
- Blocking review disagreement where Boltz and Nutts cannot align
- Anything requiring external accounts, auth, or payments
- Anything touching live player data or public channels
- Work that changes how the studio itself operates (team structure, new roles, major process overhauls)

## 🚨 Stop and escalate immediately

- Production outage or repo damage
- Ethical concerns about a decision
- Signs the team is stuck in a loop and cannot self-correct
- Loss of access to critical infrastructure

---

## Principles

1. **Reversibility trumps permission.** If a decision is cheap to undo, make it. Revert if wrong; don't block to pre-approve.
2. **Two approvals = autonomy unlocked.** When Boltz and Nutts (or equivalent reviewers) independently align, that's enough authority to ship.
3. **Gizmo owns design.** Any decision framed as "what should the player experience feel like" where Gizmo has made a call is done. Don't bounce it up.
4. **Escalations are expensive for Eric.** Every escalation consumes his attention. Only use it when the decision genuinely benefits from his judgment — not for insurance or politeness.
5. **Surface learnings in summary.** If you adjusted a threshold, logged a role-drift moment, or rewrote an approach — put it in the sprint summary. Transparency, not pre-approval, is the goal.

## Anti-patterns (don't do these)

- Asking Eric to pick between two options the team can pick between themselves.
- Pausing sub-sprints waiting for Eric to "greenlight" something the arc brief already approved.
- Relaying every reviewer nit up the chain — nits are the team's job to resolve.
- Escalating to look cautious when the data clearly supports proceeding.

---

_Evolving doc. Update when patterns emerge that change what autonomy means for the studio._
