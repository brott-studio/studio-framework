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

**Concrete repo-create command** (`gh` CLI, authenticated as a user with
`repo` create rights in the `brott-studio` org):

```bash
gh repo create brott-studio/<project> \
    --private \
    --description "<one-line project description>" \
    --add-readme
# → creates the repo with `main` as the default branch and a stub README.
```

Adjust `--private` to `--public` if the project is intended to be public
(see §3.3 note on branch-protection plan prerequisites). Do not use
`--template` — the studio skeleton is small enough to seed by hand.

**Empty-directory workaround (`.gitkeep` stubs):** Git cannot commit empty
directories, and GitHub mirrors that constraint. Seed `sprints/` and
`arcs/` with a zero-byte `.gitkeep` file each so they exist on `main`
before any sprint/arc content is authored:

```bash
touch sprints/.gitkeep arcs/.gitkeep
git add sprints/.gitkeep arcs/.gitkeep
git commit -m "chore: seed sprints/ and arcs/ directory stubs"
```

`docs/gdd.md` and `.github/workflows/` are similar — `docs/gdd.md` is
committed as an empty (or one-line placeholder) file; `.github/workflows/`
is populated later in §3 and does not need a `.gitkeep`.

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

### 2a. How to install an existing App on the new `<project>` repo

The three agent Apps (`brott-studio-specc`, `brott-studio-boltz`,
`brott-studio-optic`) already exist as org-level Apps with
`repository_selection: selected`. Adding a new repo to the selected set
is what "install on `<project>`" means here.

**The shared fine-grained PAT at `~/.config/gh/brott-studio-token` cannot
do this.** `PUT /user/installations/<id>/repositories/<repo_id>` requires
either (a) the GitHub Web UI as an org owner, or (b) a classic PAT with
`admin:org` scope owned by an org owner. Fine-grained PATs return `403
Resource not accessible by personal access token`.

Use one of these two paths:

**Web-UI path (recommended, default):**

1. Visit `https://github.com/organizations/brott-studio/settings/installations/<INSTALLATION_ID>`
   for each of specc / boltz / optic (installation IDs listed in §2b
   below).
2. Click **Configure** on that installation row.
3. Under "Repository access" → "Only select repositories," add
   `brott-studio/<project>`. Save.
4. Repeat for all three Apps.

**Classic-PAT scripted path (only for org owners who need to script it):**

```bash
# Requires a PAT-classic with admin:org, owned by an org owner.
REPO_ID=$(GH_TOKEN=$PAT_CLASSIC gh api repos/brott-studio/<project> --jq .id)
for INSTALL_ID in 125608421 125975574 125974902; do
    GH_TOKEN=$PAT_CLASSIC gh api \
        --method PUT \
        /user/installations/$INSTALL_ID/repositories/$REPO_ID
done
```

Cross-reference: [`SECRETS.md` §Per-Agent GitHub App Bootstrap → step 2](SECRETS.md#2-install-on-the-target-repo)
documents the same UI path at the App-settings-page URL; either URL
works.

### 2b. Installation ID discovery

Installation IDs for existing Apps are not listed in any single file —
derive them from the App's `.pem` via a JWT-authed
`GET /app/installations` call:

```bash
# Assumes the App's private key is at ~/.config/gh/brott-studio-<agent>-app.pem
# and the App ID is known (see §2c env-var prereqs).
APP_ID=<app-id>
PEM=~/.config/gh/brott-studio-<agent>-app.pem

JWT=$(python3 -c "
import jwt, time
pem = open('$PEM').read()
now = int(time.time())
print(jwt.encode({'iat': now-60, 'exp': now+540, 'iss': '$APP_ID'}, pem, algorithm='RS256'))
")

curl -sS -H "Authorization: Bearer $JWT" \
     -H "Accept: application/vnd.github+json" \
     https://api.github.com/app/installations \
  | jq '.[] | select(.account.login == "brott-studio") | .id'
# → single numeric installation ID for the brott-studio org install.
```

**Known installation IDs (org `brott-studio`, confirmed 2026-04-22):**

| Agent | App ID | Installation ID |
|---|---|---|
| Specc | 3444613 | 125608421 |
| Boltz | 3459519 | 125975574 |
| Optic | 3459479 | 125974902 |

Update this table if an App is re-created or the org is renamed.

### 2c. Env-var prereqs for `~/bin/<agent>-gh-token`

The token-mint helpers (`~/bin/specc-gh-token`, `~/bin/boltz-gh-token`,
`~/bin/optic-gh-token`) each require two env vars at invocation time:

| Agent | `<AGENT>_APP_ID` | `<AGENT>_INSTALLATION_ID` |
|---|---|---|
| Specc | `SPECC_APP_ID=3444613` | `SPECC_INSTALLATION_ID=125608421` |
| Boltz | `BOLTZ_APP_ID=3459519` | `BOLTZ_INSTALLATION_ID=125975574` |
| Optic | `OPTIC_APP_ID=3459479` | `OPTIC_INSTALLATION_ID=125974902` |

These should be exported in the agent's workspace env (the workspace
bootstrap is responsible for exporting them; if running a true cold-start
on a fresh host, run §2b above to rediscover the installation IDs and
export them before invoking `~/bin/<agent>-gh-token`).

The `.pem` file path is derived by the helper (`~/.config/gh/brott-studio-<agent>-app.pem`)
and does not need an env var.

## 3. Wire secrets + CI gates

On `<project>`:

### 3.1 Copy the required workflows from `battlebrotts-v2/.github/workflows/`

**Canonical paths (mirror `battlebrotts-v2` exactly — do not relocate):**

- `.github/workflows/audit-gate.yml`
- `.github/workflows/scripts/audit_gate.py`
- `.github/workflows/scripts/test_audit_gate.py`

**Copy/skip table** (the 5 workflows that live in `battlebrotts-v2/.github/workflows/` today):

| Workflow file | Copy for new project? | Notes |
|---|---|---|
| `audit-gate.yml` | **Always copy.** | Studio-wide structural gate. Required. |
| `verify.yml` | Copy **only if** the project has a test suite to run (Godot / engine / language-specific). Skip for docs-only or sandbox projects. | Project-specific. |
| `build-and-deploy.yml` | Copy **only if** the project produces a deployable artifact (Godot build, web build, etc.). Skip otherwise. | Project-specific. |
| `auto-merge-kb.yml` | Copy **only if** the project uses Specc's `kb/` auto-merge convention. Skip for first-time bootstraps; wire in later. | Optional. |
| `readme-status.yml` | Skip by default. It's a `battlebrotts-v2`-specific status-badge generator driven by `scripts/update-readme-status.py`; not studio-wide infra. | Skip. |

**Parameterisation (applies to `audit_gate.py`):** replace every
occurrence of the string `battlebrotts-v2` with `<project>` — not just the
`PROJECT` constant. The canonical script also contains docstring
references like `audits/battlebrotts-v2/<sprint>.md` which the acceptance
rubric (§3.2 grep) will catch. Use `grep -n battlebrotts-v2 audit_gate.py`
after editing; the only remaining match should be in a `#`-prefixed
comment that explains the canonical precedent (if you choose to keep
such a comment at all).

Do NOT hardcode `battlebrotts-v2` anywhere else in the new project.

### 3.2 Add repo-level Actions secrets

Required secrets on `brott-studio/<project>`:

- `BOLTZ_APP_ID` — Boltz App's numeric ID (3459519).
- `BOLTZ_APP_PRIVATE_KEY` — PEM contents from
  `~/.config/gh/brott-studio-boltz-app.pem`.

```bash
gh secret set BOLTZ_APP_ID        --repo brott-studio/<project> --body '3459519'
gh secret set BOLTZ_APP_PRIVATE_KEY --repo brott-studio/<project> < ~/.config/gh/brott-studio-boltz-app.pem
```

The `gh` CLI handles libsodium sealed-box encryption transparently. If
`gh secret set` is unavailable, use the REST API
(`POST /repos/.../actions/secrets/public-key` → encrypt → `PUT
/repos/.../actions/secrets/<NAME>`) — see
[SECRETS.md §5 Wire into CI](SECRETS.md#5-wire-into-ci-project-repos-only).

### 3.3 Branch protection on `main`

Skeleton matching `battlebrotts-v2`:

- Required status checks: start with `Audit Gate`; add project-specific
  verify checks (e.g. `Godot Unit Tests`, `Optic Verified`) as the
  project's verify workflow lands.
- Require a PR for all changes.
- (Scope-gated for S18.4: `enforce_admins`, `restrictions`, bypass lists.
  Do **not** set these during bootstrap — they're wired project-by-project
  after the audit-gate is proven live.)

**⚠️ Plan prerequisite (GitHub platform constraint, not a studio rule):**
Branch protection and repo rulesets on **private** repositories require
GitHub **Pro, Team, or Enterprise**. On Free orgs, the API returns `403
Upgrade to GitHub Pro or make this repository public to enable this
feature.`

- **For production projects:** either create the repo as `--public`, or
  ensure the `brott-studio` org is on a paid plan **before** this step.
- **For private sandboxes without a paid plan:** skip step §3.3 entirely
  — it cannot complete, and the acceptance rubric assertions 3.4 / 3.5
  will record N/A with a one-line reason. Document the skip in the
  bootstrap report so Boltz/Specc don't expect the required-check to
  fire.

This is a doc-only acknowledgement of the platform constraint; it is not
a directive to change org billing. Plan decisions live with HCD.

### 3.4 Point `Audit Gate` at `studio-audits:audits/<project>/`

Verify `PROJECT` in `.github/workflows/scripts/audit_gate.py` matches
`<project>` exactly. The `AUDIT_PATH_TEMPLATE` is derived from `PROJECT`
so no separate edit is needed.

## 4. Point the framework at the new project

On `studio-framework`:

1. Update [`REPO_MAP.md`](REPO_MAP.md) to list `<project>`: its role, the
   agents that write to it, and the cross-links to arcs/sprints/audits
   locations.

   **Delivery path:** `studio-framework@main` is branch-protected — direct
   pushes to `main` are rejected. Open a PR from a feature branch against
   `main` and route it through normal review (Boltz merges after Specc /
   HCD sign-off). **Step §4.1 completes only after the PR merges into
   `main`.** Acceptance rubric assertion 4.1 will FAIL until merge; that
   FAIL is expected during the open-PR window and is not a doc gap.

   **REPO_MAP entry — required fields checklist.** Model the new
   `<project>` section on the existing `battlebrotts-v2` entry and include
   all of:

   - [ ] **Purpose** — one-line description of what the project is.
   - [ ] **Contains** — bullet list of top-level directories / files that
         matter (at minimum: game source / code, `docs/gdd.md`, `sprints/`,
         `arcs/`, any project-specific conventions).
   - [ ] **Writes (role → path)** — which agents write where
         (Nutts → code, Gizmo → GDD, Specc → `kb/` if applicable, etc.).
   - [ ] **Reads** — which agents read this repo during spawn / planning.
   - [ ] **Cross-links** — explicit links back to the project's arcs,
         sprints, and audits locations (`studio-audits/audits/<project>/`).
   - [ ] **⚠️ Does NOT contain** — any invariants worth calling out (e.g.
         "audits live in `studio-audits`, not here").

On `studio-audits`:

2. Create `audits/<project>/` with a short `README.md` that names the
   project, links back to the project repo, and notes the sprint-audit
   naming convention.

   **README stub template** (use as-is, substitute `<project>` and tweak
   the naming convention line if the project uses a non-default one):

   ```markdown
   # audits/<project>/

   Audit trail for [`brott-studio/<project>`](https://github.com/brott-studio/<project>).

   ## File naming convention

   One audit per sprint:

   - `v2-sprint-<N>.<M>.md` — sprint audit (e.g. `v2-sprint-1.1.md` for arc 1 sprint 1).

   ## Status

   Active. Writes by Specc only.
   ```

No hardcoded `battlebrotts-v2` should remain in any file pointing at the new
project. Search the new project's **entire `.github/workflows/` tree**
(all workflow YAMLs AND `.github/workflows/scripts/*.py`) for the string
`battlebrotts-v2` — if anything matches outside comments explaining the
canonical precedent, parameterise it. The acceptance rubric (§4.3) runs
the grep across all workflow files, not just `audit_gate.py`.

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
