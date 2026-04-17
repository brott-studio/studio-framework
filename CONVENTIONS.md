# Conventions

Naming, formatting, and structural conventions across brott-studio repos.

---

## Organization

- **GitHub org:** `brott-studio`
- **Studio email domain:** `brott-studio.studio` (e.g., `thebott@brott-studio.studio`, `riv@brott-studio.studio`) — placeholder pattern used only as `git config user.email` for agent-authored commits. No live mailboxes exist behind these addresses.
- **Brand name:** "Brott" is the canonical brand (e.g., "Brott Studio", "BattleBrotts") — use freely in prose, titles, product names.
- **Legacy GitHub org slugs** (do NOT use in new org/repo references): `blor-inc`, `game-dev-studio`. These are retired org slugs only; the word "brott" itself is not legacy.

---

## Branch Naming

Format: `<sprint-id>-<short-slug>`

Examples:
- `sprint-9.1-shop-rework`
- `sprint-10-arena-mechanics`
- `fix-ci-playwright-timeout` (non-sprint work)

Rules:
- Lowercase, kebab-case
- Sprint ID first if applicable (`sprint-N` or `sprint-N.M` for sub-sprints)
- Short slug describing the work (3–5 words max)
- No personal names in branches

---

## Commit Messages

Format:
```
<Short imperative summary, ≤72 chars>

<Body: what changed and why. Wrap at 72 chars.>

<Optional trailer lines>
```

Rules:
- Subject in imperative mood ("Add shop rework" not "Added shop rework")
- Body explains **why**, not just what. The diff shows what.
- Reference task IDs in the body: `Implements [SN-042].`
- No `[Closes #N]` spam — GitHub does that via PR description.

---

## PR Titles

Format: `[SN-XXX] <short description>`

- `[SN-XXX]` task ID is **required** for sprint work
- Non-sprint fixes can omit the tag but must still be descriptive

Examples:
- `[SN-042] Rework shop UI for loadout preview`
- `[SN-051] Fix Playwright timeout on arena screen`

**Dashboard compatibility:** the `[brott-studio.github.io/studio-framework](https://brott-studio.github.io/studio-framework/)` dashboard renders PR titles verbatim from the GitHub API — no parsing of the `[SN-XXX]` prefix. This format is fully compatible; the tag simply shows inline with the title.

---

## Task IDs

Format: `SN-<number>`

- `SN` = "Studio Number" (historical — don't change)
- Numbers are allocated in sequence, per project
- Scoped per project repo (not global across repos)

Ett assigns task IDs in the sprint plan. Agents reference them in PR titles, commit bodies, and audit reports.

---

## File Naming

### In studio-framework
- Top-level policy docs: `SCREAMING_SNAKE_CASE.md` (e.g., `ESCALATION.md`, `COMMS.md`, `REPO_MAP.md`)
- Agent profiles: `agents/<lowercase>.md` (e.g., `agents/riv.md`)

### In project repos
- Sprint plans: `sprints/sprint-<N>.md` or `sprints/sprint-<N.M>.md`
- GDD: `GDD.md` (root)
- KB entries: `kb/<category>/<kebab-case-name>.md`
- Verification reports: `verification/sprint-<N>.md`

### In studio-audits
- Audits: `audits/<project-name>/sprint-<N>.md`
- See [REPO_MAP.md](REPO_MAP.md)

---

## Worktree Paths

When using git worktrees for parallel work:
```
/tmp/<repo-name>/                     — main clone
/tmp/<repo-name>-sprint-<N.M>/        — worktree for a specific sub-sprint
/tmp/<repo-name>-scratch/             — throwaway exploration
```

Never share a worktree between agent spawns. Each spawn gets its own clone or worktree.

---

## Agent Git Identity

Each agent commits with its role identity:

```bash
git config user.name "Nutts"
git config user.email "nutts@brott-studio.studio"
```

Agents: `riv`, `ett`, `gizmo`, `nutts`, `boltz`, `optic`, `specc`, `patch`, `thebott`.

This makes git history grep-able by role.

---

## Markdown Style

- Headers: `#` for title, `##` for sections, `###` for subsections. Rarely go deeper.
- Lists: `-` for bullets, `1.` for numbered. Consistent within a list.
- Code: triple-backtick with language tag (`bash`, `markdown`, `js`, etc.)
- Links: prefer relative for same-repo (`[ESCALATION.md](ESCALATION.md)`), full URL for cross-repo.
- Tables: only when columns genuinely help. Otherwise bullets.

---

## Enforcement Type

*[Compliance-reliant].* These conventions rely on agents reading this doc. No structural enforcement today except CI lint rules on PR titles (already in place for `[SN-XXX]` tag requirement on some repos).

---

*Cross-references: [REPO_MAP.md](REPO_MAP.md), [SPAWN_PROTOCOL.md](SPAWN_PROTOCOL.md).*
