# BOOTSTRAP_NEW_PROJECT.md — Cold-start a new project under the studio framework

**Audience:** a studio agent (or HCD) bringing a fresh project repo under the
studio pipeline for the first time.
**Goal:** a cold-start agent can run these 5 steps end-to-end without
blocking questions.
**Scope:** one project repo (e.g. `brott-studio/<new-project>`), not the
framework itself. The framework and the audits repo already exist.
**Status this sprint (S18.2):** docs only — no validation pass this sprint
(cold-start validation runs in S18.3).
**Acceptance rubric:** a cold-start agent walking these 5 steps should
self-score against [`BOOTSTRAP_ACCEPTANCE.md`](BOOTSTRAP_ACCEPTANCE.md) —
one section per step, with literal verification commands and patch-back
pointers. Any FAIL is patched back into this doc (or the cross-referenced
doc named in the rubric) per S18.3 Workstream C.

Throughout, `<project>` is the new project's repo name (e.g. `battlebrotts-v2`
for the canonical precedent). Nothing in the pipeline hardcodes a specific
project name except where documented in `REPO_MAP.md`.

---

## 1. Create the project repo

Create `brott-studio/<project>` with the minimum skeleton:

```
<project>/
  sprints/                       # sprint plans land here (sprint-<N>.<M>.md)
  arcs/                          # arc briefs (arc-<N>.md)
  docs/gdd.md                    # game design doc (or project charter)
  .github/workflows/             # CI workflows
```

Commit a stub `README.md`, a `.gitignore`, and an empty `docs/gdd.md` (HCD
fills in the GDD after [arcs/arc-1.md](#5-first-arc-kickoff) is written).
Set `main` as the default branch.

No other boilerplate this early — the pipeline docs live in
[studio-framework](.) and are referenced by link, not copied.

## 2. Provision per-agent GitHub Apps

Studio pipeline uses three GitHub Apps as per-agent identities:

| App | Role | Install permissions (min) |
|---|---|---|
| `brott-studio-specc` | Audits — writes to `studio-audits` | Contents: write on `studio-audits`; Metadata: read on `<project>` |
| `brott-studio-boltz` | Reviewer/merger — operates on project repos; also reads `studio-audits` for the `Audit Gate` check | Contents: write, Pull-requests: write on `<project>`; Contents: read on `studio-audits` |
| `brott-studio-optic` | Check-run reporter — reports build/verify status | Checks: write, Metadata: read on `<project>` |

For each App, install it on the new `<project>` repo and write the private
key to `~/.config/gh/brott-studio-<agent>-app.pem` on the workspace host
(`0600`). Confirm with `GET /repos/brott-studio/<project>/installation`
authenticated as the App (returns `app_id: <App ID>`). Also confirm Specc's
install on `studio-audits` still has Contents: write, and Boltz's install on
`studio-audits` still has Contents (read is sufficient for the `Audit Gate`
check).

**See [`SECRETS.md` §Per-Agent GitHub App Bootstrap](SECRETS.md#per-agent-github-app-bootstrap)**
for the full create → install → write-key → mint-token → verify recipe, plus
worked examples using Optic (App ID 3459479) and Boltz (App ID 3459519).

## 3. Wire secrets + CI gates

On `<project>`:

1. Copy the three required workflows from `battlebrotts-v2/.github/workflows/`:
   - `audit-gate.yml` + `scripts/audit_gate.py` (+ tests) — **parameterise**:
     replace `battlebrotts-v2` with `<project>` in `audit_gate.py` constants
     (`PROJECT`, `AUDIT_PATH_TEMPLATE` is derived from `PROJECT`). Do NOT
     hardcode `battlebrotts-v2` anywhere in the new project.
   - Whatever build/verify workflows the project needs (for Godot projects:
     `verify.yml` + `build-and-deploy.yml`; for other projects: the analog).
2. Add repo-level Actions secrets:
   - `BOLTZ_APP_ID` — Boltz App's numeric ID (3459519).
   - `BOLTZ_APP_PRIVATE_KEY` — PEM contents from
     `~/.config/gh/brott-studio-boltz-app.pem`.
3. Branch protection on `main` (skeleton matching `battlebrotts-v2`):
   - Required status checks: start with `Audit Gate`; add project-specific
     verify checks (e.g. `Godot Unit Tests`, `Optic Verified`) as the
     project's verify workflow lands.
   - Require a PR for all changes.
   - (Scope-gated for S18.4: `enforce_admins`, `restrictions`, bypass lists.
     Do **not** set these during bootstrap — they're wired project-by-project
     after the audit-gate is proven live.)
4. Point `Audit Gate` at `studio-audits:audits/<project>/` by verifying
   `PROJECT` in `audit_gate.py` matches `<project>` exactly.

## 4. Point the framework at the new project

On `studio-framework`:

1. Update [`REPO_MAP.md`](REPO_MAP.md) to list `<project>`: its role, the
   agents that write to it, and the cross-links to arcs/sprints/audits
   locations.

On `studio-audits`:

2. Create `audits/<project>/` with a short `README.md` that names the
   project, links back to the project repo, and notes that files land as
   `v2-sprint-<N>.<M>.md` (or the project-specific naming convention).

No hardcoded `battlebrotts-v2` should remain in any file pointing at the new
project. Search the new project's workflows for the string
`battlebrotts-v2` — if anything matches outside comments explaining the
canonical precedent, parameterise it.

## 5. First-arc kickoff

1. **HCD** writes `arcs/arc-1.md` — the arc brief for the project's first
   arc. See [`ARC_BRIEF.md`](ARC_BRIEF.md) for the shape.
2. **The Bott** spawns Riv with the arc brief.
3. Riv spawns Gizmo → Ett → Nutts → Boltz → Optic → Specc as usual.
4. The first sprint's planning PR (`sprints/sprint-1.1.md`) triggers the
   `Audit Gate` workflow, which hits the **first-sprint-of-arc rule**:
   `M == 1` → `Audit Gate` **requires `arcs/arc-1.md` in the PR tree** and
   **skips the prior-audit lookup**. Present → PASS. Missing → FAIL with
   summary `"first sprint of an arc must introduce arcs/arc-<N>.md"`.
5. From `sprint-1.2.md` onward, `Audit Gate` enforces the
   immediately-preceding audit: `audits/<project>/v2-sprint-1.1.md` on
   `studio-audits/main`.

That's it. The project is live in the pipeline.

---

## Cross-references

- Secrets + per-agent App bootstrap recipe: [SECRETS.md](SECRETS.md)
- Pipeline stages and close-out invariant: [PIPELINE.md](PIPELINE.md)
- Repo map / who writes where: [REPO_MAP.md](REPO_MAP.md)
- Arc brief shape: [ARC_BRIEF.md](ARC_BRIEF.md)
- Canonical precedent: `battlebrotts-v2` (study its `.github/workflows/` for
  the current audit-gate implementation).
