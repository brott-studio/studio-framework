# Arc Brief — The Canonical Pattern

> **An arc is the outer strategic unit HCD directs. A sprint is one iteration
> of the pipeline. An arc contains one or more sprints and ends when Gizmo
> and Ett converge on "done."**

This doc describes what an arc brief is, how to write one, and why. It's the
canonical reference for the arc-level direction HCD hands to The Bott, which
The Bott then hands to Riv at arc kickoff.

---

## What an Arc Is

An **arc** is a strategic or creative goal that may take one or several
pipeline iterations to realize. Examples:

- "Make the first 5 minutes of play irresistible."
- "Clean up tech debt and get all infrastructure healthy."
- "Get combat feeling weighty."
- "Ship a shop loop HCD can play end-to-end."

An arc has **direction, not destination**. HCD points at a place and gives a
budget. The pipeline discovers what "there" actually looks like along the way.

An arc ends when the **inner loop** (Gizmo + Ett) converges on "the arc's
intent is satisfied and no high-value work remains." Not when a checklist is
ticked.

A **sprint** is one full pipeline iteration inside an arc:
Gizmo → Ett → Nutts → Boltz → Optic → Specc → audit commit.
Sprints within an arc are numbered `N.1`, `N.2`, `N.3`, where `N` is the
arc number.

---

## What Belongs in an Arc Brief

Short. Vision-led for creative arcs, systems-led for infra arcs. Speak the
language of the problem.

**Always:**

1. **Arc goal** — one or two lines, stated in terms of intent, not acceptance
   criteria. Creative arcs: a felt outcome ("new player thinks *wow this
   looks cool*"). Infra arcs: a health description ("CI green on main,
   test suite covers all sprints explicitly").
2. **Priorities** — 2–6 bullets in the language of the problem. For creative
   arcs, evocative: "Circle, circle, COMMIT — boxing rhythm, not orbit-and-
   miss." For infra arcs, concrete: "Replace shared-PAT workaround with
   per-agent GitHub Apps."
3. **Max sprints** — a *fuse*, not a target. "Escalate after 5 sprints."
   The loop should converge before this; the fuse exists so a stuck arc
   surfaces to HCD instead of spinning forever.

**Sometimes:**

4. **Hard constraints** — scope fences. "No behavior changes to
   `combat_sim.gd`." "No new external dependencies." Only include when a
   real constraint exists; don't invent them for insurance.
5. **Context carry-over** — one or two sentences of state HCD wants the
   arc to start from. Prior arc outcomes, known blockers, relevant recent
   commits.

**Never (these are anti-patterns in arc briefs):**

- **Acceptance criteria as a checklist.** Arc completion is a judgment
  call by Gizmo+Ett. A checklist collapses that judgment into mechanics
  and drives the loop toward ticking items instead of satisfying intent.
  *Exception:* pure infra arcs may state binary success conditions ("all
  CI workflows green on main") because intent *is* the condition for
  that arc type. Even then: 1–2 conditions, not a 10-item checklist.
- **Pre-planned sprints.** Don't say "S16.1 will do X, S16.2 will do Y."
  That's Ett's job. Arc briefs describe intent; sprint plans describe
  execution. If you find yourself sketching sprints, stop — write it
  as a priority bullet and trust Ett to sequence.
- **Re-explaining pipeline mechanics.** Riv, Ett, and every agent read
  FRAMEWORK.md and PIPELINE.md every spawn. Don't repeat those rules
  in the brief.
- **Task lists.** Tasks belong in sprint plans.

---

## Where the Arc Brief Lives

**File:** `<project-repo>/arcs/arc-<N>.md`

**Delivery to Riv:** The arc brief is passed into Riv's spawn prompt. Two
acceptable patterns:

- **Inline:** the arc brief contents pasted directly into the Riv spawn
  prompt. Good for short briefs.
- **By reference + summary:** the spawn prompt contains a one-sentence
  quote of the arc goal plus a pointer to `arcs/arc-<N>.md` for the full
  brief. Good for richer briefs. The essential intent is always mirrored
  in the spawn prompt, not left to the file alone.

Riv passes the arc brief (or pointer) forward to Gizmo and Ett every sprint
in the arc, so the arc-intent check has the vision to evaluate against.

---

## The Successful S13 Example

The S13 arc was "Make the First 5 Minutes Irresistible" — five sprints
ran autonomously, and the era is the reference point for what arc-style
direction looks like done well. Reproduced below as a worked example:

> **Creative Direction: "Make the First 5 Minutes Irresistible"**
>
> *A new player should feel: exciting fight (punches land!) → cool shop
> (ooh shiny!) → one fun BrottBrain choice → back to fighting. Fast,
> visual, rewarding. Depth reveals itself after the hook.*
>
> **Design priorities for Gizmo:**
>
> 1. **Combat rhythm** — "Circle, circle, COMMIT." Right now bots orbit
>    and miss too much. Needs tension → impact → tension cycles.
> 2. **Shop as visual experience** — Player should think "WOW this looks
>    cool — what does it do?" NOT "let me study these stats."
> 3. **BrottBrain early taste** — Introduce ONE simple exciting choice.
>    Appetizer, not full menu.
> 4. **Audio design vision** — Design how charming Wall-E robots should
>    SOUND. Don't pick tools yet.
>
> **Infrastructure:**
> - Merge Specc KB PR #53
> - Re-run fun evaluation Spike (match logging now exists)
>
> **Max sprints:** 10

Notice what's there: vision, priorities in problem-language (creative for
Gizmo, list for infra), a fuse. Notice what's absent: acceptance criteria,
pre-planned sprints, task lists, pipeline mechanics.

---

## Arc Completion

An arc ends when **Gizmo reports arc-intent satisfied** AND **Ett decides
no remaining work is worth another sprint.** This is a judgment, not a test.

Gizmo, at each sprint's Phase 1, emits an **arc-intent check** (in addition
to the standard GDD drift check):

- **Arc intent satisfied** — the arc's goal reads as met. Ett decides
  completion.
- **Progressing — [what's still missing]** — arc work remains.
- **Drift from arc intent: [what]** — prior sprint pulled away from the
  goal; the next sprint should correct.

Ett, at each sprint's Phase 2 Step A, folds Gizmo's arc-intent check into
the continue-or-complete decision alongside the prior audit grade, the
remaining backlog for the arc, and the max-sprint fuse. See `agents/ett.md`
and `agents/gizmo.md` for the exact mechanics.

---

## When You're About to Write Acceptance Criteria…

…stop and ask: "Is this a real intent condition, or am I smuggling a plan
into the brief?"

- *"CI green on main and on a PR"* for a pure-infra arc → acceptable, it's
  intent.
- *"test_runner.gd enumerates all sprint files explicitly"* → that's
  a plan step. It belongs in Ett's sprint plan, not the arc brief.

When in doubt, leave it out. Trust Ett to discover the work.

---

## Summary (the whole thing on one page)

- **Arc** = strategic unit, HCD directs, Gizmo+Ett judge "done."
- **Sprint** = one pipeline iteration, Ett plans, pipeline executes, Specc
  audits.
- **Arc brief** = goal + priorities + fuse. Short. No acceptance checklist.
  No pre-planned sprints. No pipeline mechanics.
- **Completion** = Gizmo "arc intent satisfied" + Ett "no more meaningful
  work."

That's the whole pattern.
