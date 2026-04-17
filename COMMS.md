# Communications Routing

How studio agents communicate — with each other, with the Human Creative Director (HCD), and in public channels.

**Core rule:** All pipeline messages go to the studio channel. Never DM the HCD for pipeline business.

---

## 🎯 The Studio Channel Rule

Pipeline communication — merge calls, sprint summaries, escalations, subagent completion summaries, status updates, questions needing HCD input — **goes to the studio channel**. Never DMs to HCD.

**Why:** DMs fragment pipeline context across private surfaces. The channel is the single source of truth for the studio record. A question asked in DM has no witnesses; a question asked in channel is resolved once and visible to every future session.

**Applies to:** Riv, Ett, Nutts, Boltz, Optic, Gizmo, Specc, Patch, The Bott, and any subagent any of these agents spawn. If you spawn a subagent, tell it: "Use the studio channel for all pipeline messages. Do not DM HCD."

**Direct DMs to HCD** are reserved for personal-assistant interactions unrelated to the studio (calendar, email, personal reminders). The Bott uses that surface for non-pipeline work.

---

## 🔔 Mention Discipline

The studio channel is **@mentions-only for HCD**. Pinging HCD with `<@HCD-id>` should be rare and meaningful.

**Ping HCD (with `<@HCD-id>`):**
- Playtest-ready builds (explicit "this is ready for your hands")
- Merge calls that need HCD's signoff (arc-level milestones)
- Genuine escalations per ESCALATION.md 🔴/🚨 criteria

**Post without mention (silent to HCD, visible in channel):**
- Subagent completion summaries
- Pipeline status updates ("sprint N.2 build phase started")
- Routine acknowledgements
- Questions among agents that don't need HCD input

**Why the discipline:** subagent completions and status updates are high-frequency. If every one pinged HCD, notifications become noise and HCD starts muting the channel. Pings should be signal.

---

## 📝 Message Format

**Subagent completion summaries:** post to channel, no mention. Keep them concise:
- One-line outcome ("Sprint 9.1 build complete, PR #42 open")
- Deliverables (links)
- Any flag/followup (if genuinely needed)

**Sprint reports:** Riv posts final report to channel at sprint end. HCD ping only if playtest-ready or decision needed.

**Escalations:** include the escalation tier (🔴/🚨) in the message so HCD can prioritize at a glance. Example: `🔴 Blocking review disagreement: Boltz and Nutts disagree on X, need direction.`

---

## 🤐 What Stays In The Channel

Pipeline agents are participants in the studio, not HCD's voice. In the channel:

- **Don't speak for HCD** or relay HCD's position to external parties
- **Don't share private workspace context** (MEMORY.md content, HCD's personal info from USER.md) — those stay in main session only
- **Do** share pipeline state, deliverables, questions, status

---

## Cross-references

- Escalation criteria that determine when to ping HCD: [ESCALATION.md](ESCALATION.md)
- Secrets that must NEVER be posted in channel: [SECRETS.md](SECRETS.md)
- Pipeline messaging points: [PIPELINE.md](PIPELINE.md) "Sprint Communication" section

---

*[Compliance-reliant.] Relies on agent behavior — no structural enforcement gates channel vs. DM routing. The Bott monitors and corrects drift.*
