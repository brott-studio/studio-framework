# Repo Map

The three-repo architecture of the brott-studio AI agent studio.

---

## Repos

### `brott-studio/studio-framework`
**Purpose:** The framework itself. How the studio operates.

**Contains:**
- `FRAMEWORK.md`, `PIPELINE.md`, all root-level policy docs
- `agents/*.md` — agent profiles (single source of truth for role behavior)
- `archived/v1/` — historical v1 framework (read-only reference)
- `index.html`, `favicon.png`, `icon.png` — dashboard assets (generated/updated by The Bott)

**Writes:** The Bott. Framework evolution is leadership work, not pipeline work.
**Reads:** Every agent, every spawn. Riv / Ett / Gizmo / Nutts / Boltz / Optic / Specc / Patch all clone this repo and read their own profile before acting.

---

### `brott-studio/<project-repo>` (currently: `battlebrotts-v2`)
**Purpose:** The actual game being built.

**Contains:**
- Game source code
- `GDD.md` — game design document (Gizmo is primary author)
- `kb/` — project knowledge base (patterns, troubleshooting, postmortems, decisions)
- `sprints/sprint-<N>.md` — sprint plans (Ett writes, Riv references)
- Tests, assets, build scripts, CI config

**Writes:** Nutts (code + tests), Gizmo (GDD), Specc (KB during audit extraction — cross-repo write, committed here), Patch (infra). Riv does not write code, only orchestrates.

**⚠️ Does NOT contain:** Audit reports. Audits live in `studio-audits`, not here.

---

### `brott-studio/studio-audits`
**Purpose:** Independent audit trail. Specc's turf.

**Contains:**
- `audits/<project>/sprint-<N>.md` — one audit per sprint
- Learning extraction notes
- Cross-project patterns if / when multiple projects exist

**File path convention (hard rule):** `audits/<project-name>/sprint-<N>.md`
- Example: `audits/battlebrotts-v2/sprint-9.1.md`
- Sub-sprints use decimal: `sprint-9.1.md`, `sprint-9.2.md`

**Writes:** Specc, exclusively. No other agent commits here.
**Reads:** Specc, Ett (reads previous audit when planning next sprint), The Bott, HCD.

**Why separate from the project repo:**
1. **Independence.** An audit critical of the build must live somewhere the builders don't own. Separate repo = separate merge rights.
2. **Cross-sprint history.** Audits persist as the project evolves. If the game repo gets force-pushed or squashed, audit history remains intact.
3. **Structural enforcement surface** (aspirational). A future structural gate could watch `studio-audits` commits to unlock `<project-repo>` sprint-N+1 merges. See [ESCALATION.md](ESCALATION.md) context on sub-sprint Specc gate.

---

## Who Writes Where

| Agent | studio-framework | `<project-repo>` | studio-audits |
|---|---|---|---|
| The Bott | ✅ (framework evolution, dashboard) | ✅ (sprint coordination, minor) | ❌ |
| Riv | ❌ (orchestrates only) | ❌ (no direct writes) | ❌ |
| Ett | ❌ | ✅ (`sprints/sprint-<N>.md` plan) | ❌ |
| Gizmo | ❌ | ✅ (`GDD.md`, specs) | ❌ |
| Nutts | ❌ | ✅ (code, tests, PRs) | ❌ |
| Boltz | ❌ | ✅ (PR reviews, merges) | ❌ |
| Optic | ❌ | ✅ (verification reports, screenshots) | ❌ |
| Specc | ❌ | ✅ (KB entries only) | ✅ (all audit reports) |
| Patch | ❌ | ✅ (infra, CI configs) | ❌ |

---

## Reading Order For A Fresh Session

A cold-start agent session should read, in order:
1. `studio-framework/README.md` (entry point)
2. `studio-framework/FRAMEWORK.md` (mental model)
3. `studio-framework/PIPELINE.md` (sprint flow)
4. `studio-framework/agents/<your-role>.md` (your specific profile)
5. Any cross-referenced policy (`ESCALATION.md`, `COMMS.md`, `SECRETS.md`, etc.) the profile points to
6. `<project-repo>/GDD.md` if your task touches game mechanics
7. Latest audit in `studio-audits/audits/<project>/` if your task is a sprint continuation

---

## Access Model

All three repos are under the `brott-studio` GitHub org. A single PAT at `~/.config/gh/brott-studio-token` grants access to all of them. See [SECRETS.md](SECRETS.md).

---

*[Structural] file-path conventions are enforced by tooling (grep / CI scripts can validate `audits/<project>/sprint-<N>.md` format). Cross-repo write discipline (who writes where) is **[Compliance-reliant]** — no branch protection enforces role-to-repo mapping today.*
