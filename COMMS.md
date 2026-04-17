# Communications Routing

How studio agents communicate — with each other, with the Human Creative Director (HCD), and in public channels.

**Core rule:** Pipeline chatter stays in-session. The Discord studio channel is reserved for HCD-facing summaries from The Bott only.

---

## 🔁 Three-Tier Flow

Studio communication flows along a single path:

```
Subagents (Gizmo, Ett, Nutts, Boltz, Optic, Specc, Patch)
    │  completion report
    ▼
Riv (pipeline orchestrator — channel-silent)
    │  sprint completion report
    ▼
The Bott (main session — sole channel voice)
    │  curated summary
    ▼
Studio Discord channel (HCD-facing)
```

- **Subagents → Riv.** Every subagent reports to its spawning session. During pipeline sprints that is Riv. Subagents never post to the Discord studio channel.
- **Riv → The Bott.** Riv's spawning session is The Bott's main session. Riv emits its completion summary there. Riv never posts to the studio channel and never DMs HCD.
- **The Bott → channel.** The Bott is the sole channel voice. For every Riv completion, The Bott posts a brief curated summary — not silence, not play-by-play.

**[Structural]** — the tier boundaries are enforced by how `sessions_spawn` wires parent sessions. A subagent's completion announces back to its spawner; it cannot bypass Riv to reach the channel without explicit, out-of-protocol action.

**[Compliance-reliant]** — the curation discipline at the top tier. The Bott decides what's worth surfacing to HCD and what stays in-session. Over-posting floods the channel; under-posting leaves HCD in the dark. Judgment required.

---

## 📢 Channel Policy

The Discord studio channel is for **HCD-facing summaries from The Bott only**. No other agent posts directly.

**What The Bott posts to the channel:**
- Sprint completion summaries (one per Riv completion event)
- Playtest-ready pings (explicit "this is ready for your hands")
- Merge-calls that need HCD signoff
- Escalations per ESCALATION.md 🔴/🚨 criteria

**Suggested sprint summary format** (The Bott's discretion — full format note lives in The Bott's workspace `TOOLS.md`):

```
✅ Sprint X.Y complete — [one-line headline]. Specc grade: [X]. PRs: [list]. [Any follow-ups].
```

**What subagents and Riv do NOT post to the channel:**
- Individual agent completion pings (stay in spawning session)
- Pipeline status play-by-play (stays in Riv's session)
- Questions among agents (resolve in-session or escalate through the tier)
- Riv's final sprint report (goes to The Bott's session, The Bott re-packages)

---

## 🔔 Mention Discipline

When The Bott posts to the channel, pinging HCD with `<@HCD-id>` should be rare and meaningful.

**Ping HCD (with `<@HCD-id>`):**
- Playtest-ready builds
- Merge calls that need HCD signoff (arc-level milestones)
- Genuine escalations per [ESCALATION.md](ESCALATION.md) 🔴/🚨 criteria

**Post without mention (silent to HCD, visible in channel):**
- Routine sprint completion summaries
- Acknowledgements / status that's informational rather than actionable

**Why:** pings should be signal. Routine sprint summaries are useful context; they're not interrupts.

---

## 🚫 Direct Messages to HCD

DMs to HCD are reserved for **personal-assistant work unrelated to the studio** (calendar, email, personal reminders). The Bott uses that surface for non-pipeline interactions only.

**Never DM HCD for pipeline business.** If it's pipeline, it either stays in-session (subagent / Riv tiers) or goes to the channel via The Bott (top tier).

---

## 🤐 What Stays Private

Pipeline agents are participants in the studio, not HCD's voice. Even within the channel:

- **Don't speak for HCD** or relay HCD's position to external parties.
- **Don't share private workspace context** (MEMORY.md, USER.md personal info). That stays in The Bott's main session only.
- **Do** share pipeline state, deliverables, questions, and status per the tier rules above.

---

## 📝 Escalation Format

When an escalation surfaces up through the tiers and The Bott posts it to the channel, include the escalation tier (🔴/🚨) so HCD can prioritize at a glance. Example:

```
🔴 Blocking review disagreement: Boltz and Nutts disagree on X. Riv is holding the sprint. HCD input needed.
```

---

## 📛 Depersonalization

In this repo and any written artifacts, refer to the Human Creative Director as **HCD** or **Human Creative Director**. Do not use personal names in docs or new artifacts. Code comments, git commit authors, and Discord transcripts quoted verbatim may retain original names.

---

## Cross-references

- Escalation criteria that determine when The Bott should ping HCD: [ESCALATION.md](ESCALATION.md)
- Secrets that must NEVER be posted in channel: [SECRETS.md](SECRETS.md)
- Pipeline messaging touchpoints: [PIPELINE.md](PIPELINE.md) "Sprint Communication" section
- Channel-post format details: The Bott's workspace `TOOLS.md` (studio pipeline section)
