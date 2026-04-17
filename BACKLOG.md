# BACKLOG.md — GitHub Issues-Backed Backlog Pattern

The studio's parked / deferred / "future sprint" work lives as **GitHub Issues** on the project repo, not in chat transcripts, not in scattered TODO markdown files.

## Where the backlog lives

- **Repo:** `brott-studio/battlebrotts-v2` (project-specific — each game repo owns its own backlog)
- **Filter:** label `backlog` + state `open`

```bash
gh issue list --repo brott-studio/battlebrotts-v2 --label backlog --state open --limit 100
```

## Label taxonomy

Every backlog issue carries **three labels**: `backlog` + one `area:*` + one `prio:*`.

**Areas:**
- `area:audio` — music, SFX, audio mixing
- `area:art` — sprites, VFX, animation, visual polish
- `area:ux` — menus, HUD, inputs, onboarding, accessibility
- `area:gameplay` — mechanics, balance, content, combat, progression
- `area:tech-debt` — refactors, cleanup, performance, infra hygiene
- `area:framework` — studio-framework / pipeline / agent-profile work

**Priorities:**
- `prio:high` — should land in the next 1–2 sprints
- `prio:mid` — pull in when adjacent or when a sprint is under-scoped
- `prio:low` — nice-to-have, no ticking clock

## Lifecycle

```
[open]  ──► [sprint-scoped]  ──►  [PR references issue]  ──►  [merged → auto-closed]
  │              │                       │                           │
  │         Ett writes                Nutts writes              GitHub closes
  │         Closes #N / Refs #N       Closes #N / Refs #N       the issue
  │         into sprint doc           into PR body              automatically
  │                                                             on merge to main
  │
  └─── or stays open across sprints until priority + capacity align
```

1. **Open.** Anyone (Riv, The Bott, Ett, Gizmo, HCD) can open an issue when work is deferred.
2. **Sprint-scoped.** Ett folds issues into the sprint plan during planning (see `agents/ett.md`). Sprint doc references `Closes #N` (full) or `Refs #N` (partial).
3. **PR.** Nutts/Boltz reference the same issues in the PR body using `Closes #N` / `Refs #N` (see `agents/nutts.md`, `agents/boltz.md`).
4. **Merge.** GitHub auto-closes `Closes #N` issues on merge to `main`. `Refs #N` stays open for follow-up.

## Who writes issues

**Anyone.** Riv, The Bott, Ett, Gizmo, HCD — whoever is in the conversation where work gets deferred is responsible for opening the issue before the loop closes. This is explicitly called out in `agents/riv.md`.

Chat transcripts are not institutional memory. Issues are.

## How to query

```bash
# Full open backlog
gh issue list --repo brott-studio/battlebrotts-v2 --label backlog --state open --limit 100

# High-priority only
gh issue list --repo brott-studio/battlebrotts-v2 --label backlog --label prio:high --state open

# By area (e.g., for Gizmo's design-phase check)
gh issue list --repo brott-studio/battlebrotts-v2 --label backlog --label area:gameplay --state open

# As JSON (for Ett's planning preamble)
gh issue list --repo brott-studio/battlebrotts-v2 --label backlog --state open \
  --json number,title,labels --limit 100

# Open a new backlog issue
GH_TOKEN=$(cat ~/.config/gh/brott-studio-token) gh issue create \
  --repo brott-studio/battlebrotts-v2 \
  --label backlog --label area:<area> --label prio:<high|mid|low> \
  --title "<terse title>" --body "<context + acceptance criteria>"
```

## Compliance

Specc audits every arc retrospective for backlog compliance (see `agents/specc.md`, section 6). Parked work without a matching open issue in `brott-studio/battlebrotts-v2` grades the arc down. It's a compliance gate, not a suggestion.

## Which agents touch the backlog

| Agent   | Interaction                                                            |
|---------|------------------------------------------------------------------------|
| Riv     | Opens issues when HCD defers work mid-conversation                     |
| Ett     | Queries backlog during planning; folds issues into sprint scope        |
| Gizmo   | Checks backlog by area when writing design specs; references `Refs #N` |
| Nutts   | Writes `Closes #N` / `Refs #N` in PR bodies                            |
| Boltz   | Verifies PRs reference backlog issues during review                    |
| Specc   | Audits arc retrospectives for backlog compliance                       |

## Out of scope (for this pattern)

- GitHub Projects / Milestones — not used; labels + filters are enough.
- CI workflows enforcing the pattern — Specc's audit is the enforcement mechanism.
- Cross-repo backlogs — each game repo owns its own backlog. `studio-framework` has no backlog (meta work is tracked via this repo's own issues if needed, not under the `backlog` label pattern).
