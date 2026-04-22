# BOOTSTRAP_ACCEPTANCE.md — Cold-start Acceptance Rubric

**Audience:** a studio agent (or HCD) walking [`BOOTSTRAP_NEW_PROJECT.md`](BOOTSTRAP_NEW_PROJECT.md) end-to-end for a new project repo.
**Purpose:** self-scored rubric. For each of the 5 bootstrap steps, the cold-start agent runs the listed verification commands and records PASS / FAIL / N/A. The rubric is the proof that "the bootstrap doc is complete enough for an agent with no tribal knowledge."

**How to use:**

1. Before each step in `BOOTSTRAP_NEW_PROJECT.md`, open this rubric to the matching section.
2. Execute the source step per its instructions.
3. Run each verification command in the table. Compare to *expected result*.
4. Record the outcome as one of:
   - **PASS** — command ran, output matches expected result.
   - **FAIL** — command errored, missing prerequisite, or output did not match. Capture the actual output in a one-line reason.
   - **N/A** — assertion does not apply to this project (e.g. project is not a Godot project, so `Godot Unit Tests` does not apply). One-line reason required.
5. Any **FAIL** is patched back into the source doc this sprint, per **S18.3 Workstream C — Bootstrap patch-back**. File a PR against [`BOOTSTRAP_NEW_PROJECT.md`](BOOTSTRAP_NEW_PROJECT.md) (or the cross-referenced doc listed in the *failure → patch* column) that fixes the gap the FAIL exposed. The rubric exists so gaps land as concrete doc changes, not vibes.

**Scope — what this rubric does NOT gate:** this is a bootstrap-time self-score, not a structural branch-protection check. Runtime pipeline compliance (audit-gate behavior in-sprint, `enforce_admins`, bypass lists, Optic check-run posting) is out of scope and is handled by the audit-gate workflow + S18.4 scope gates. This rubric only validates that the bootstrap doc gets a cold-start agent to a functioning starting state.

**Design notes:**

- Every assertion is **objectively verifiable** via a literal command with a machine-checkable expected result (exit code, HTTP status, exact file path, string match).
- Commands assume the operator has `~/.config/gh/brott-studio-token` (PAT) and/or the relevant per-agent App private key per [`SECRETS.md`](SECRETS.md). Where an App installation token is required, the command uses `~/bin/<agent>-gh-token` as documented in `SECRETS.md`.
- Placeholder: `<project>` is the new project repo name. Substitute everywhere before running.
- All `gh api` calls should be run with `GH_TOKEN` set to either the PAT (for read-only metadata) or the relevant App installation token (for install-scoped reads); the rubric assumes `GH_TOKEN` is exported in the shell.

---

## Step 1 — Create the project repo

Source: [`BOOTSTRAP_NEW_PROJECT.md` §1](BOOTSTRAP_NEW_PROJECT.md#1-create-the-project-repo).

| # | Assertion | Verification command | Expected result | Failure → patch |
|---|---|---|---|---|
| 1.1 | The repo `brott-studio/<project>` exists and is accessible to the shared PAT. | `gh api repos/brott-studio/<project> --jq .full_name` | Exit `0`, stdout exactly `brott-studio/<project>`. | [`BOOTSTRAP_NEW_PROJECT.md` §1](BOOTSTRAP_NEW_PROJECT.md#1-create-the-project-repo) — clarify the create-repo command (org, visibility, template) if the repo is missing or inaccessible. |
| 1.2 | The default branch is `main`. | `gh api repos/brott-studio/<project> --jq .default_branch` | Exit `0`, stdout exactly `main`. | [`BOOTSTRAP_NEW_PROJECT.md` §1](BOOTSTRAP_NEW_PROJECT.md#1-create-the-project-repo) — add an explicit "set `main` as default branch" command if this was ambiguous. |
| 1.3 | The required skeleton directories/files exist on `main`: `sprints/`, `arcs/`, `docs/gdd.md`, `.github/workflows/`. | `for p in sprints arcs docs/gdd.md .github/workflows; do gh api "repos/brott-studio/<project>/contents/$p?ref=main" --jq '.name // .[0].name' >/dev/null && echo "OK $p" || echo "MISS $p"; done` | Every line starts with `OK`; no `MISS` lines. | [`BOOTSTRAP_NEW_PROJECT.md` §1](BOOTSTRAP_NEW_PROJECT.md#1-create-the-project-repo) — the skeleton listing should match reality; if a directory cannot be created empty on GitHub, the doc must say so and give the stub-file workaround. |
| 1.4 | A `README.md` and `.gitignore` are committed on `main`. | `gh api repos/brott-studio/<project>/contents/README.md?ref=main --jq .type && gh api repos/brott-studio/<project>/contents/.gitignore?ref=main --jq .type` | Both calls exit `0`, both stdout lines are `file`. | [`BOOTSTRAP_NEW_PROJECT.md` §1](BOOTSTRAP_NEW_PROJECT.md#1-create-the-project-repo) — the stub-file list must name every required root file. |

---

## Step 2 — Provision per-agent GitHub Apps

Source: [`BOOTSTRAP_NEW_PROJECT.md` §2](BOOTSTRAP_NEW_PROJECT.md#2-provision-per-agent-github-apps). Cross-ref: [`SECRETS.md` §Per-Agent GitHub App Bootstrap](SECRETS.md#per-agent-github-app-bootstrap).

| # | Assertion | Verification command | Expected result | Failure → patch |
|---|---|---|---|---|
| 2.1 | Each of the three agent App private keys exists on disk with `0600` permissions. | `for a in specc boltz optic; do f=~/.config/gh/brott-studio-$a-app.pem; test -f "$f" && stat -c '%a %n' "$f"; done` | Three lines, each starting with `600 ` followed by the file path. Exit `0`. | [`SECRETS.md`](SECRETS.md) — the write-key step must specify the exact path pattern and `chmod 600`. |
| 2.2 | Each App is installed on `brott-studio/<project>` and returns a valid installation record. | `for a in specc boltz optic; do GH_TOKEN=$(~/bin/$a-gh-token) gh api /repos/brott-studio/<project>/installation --jq '.app_id' || echo "FAIL-$a"; done` | Three numeric `app_id` lines, no `FAIL-*` lines, each command exits `0`. | [`BOOTSTRAP_NEW_PROJECT.md` §2](BOOTSTRAP_NEW_PROJECT.md#2-provision-per-agent-github-apps) — if the `GET /repos/.../installation` verify step was under-specified, expand it to name the exact token-mint command per agent. |
| 2.3 | Specc's existing install on `studio-audits` still has `contents: write`. | `GH_TOKEN=$(~/bin/specc-gh-token) gh api /repos/brott-studio/studio-audits/installation --jq '.permissions.contents'` | Exit `0`, stdout exactly `write`. | [`BOOTSTRAP_NEW_PROJECT.md` §2](BOOTSTRAP_NEW_PROJECT.md#2-provision-per-agent-github-apps) — if this was lost during re-provisioning, the doc must include an explicit "do not narrow existing installations" warning. |
| 2.4 | Boltz's install on `studio-audits` has at least `contents: read` (needed for the `Audit Gate` check). | `GH_TOKEN=$(~/bin/boltz-gh-token) gh api /repos/brott-studio/studio-audits/installation --jq '.permissions.contents'` | Exit `0`, stdout is `read` or `write`. | [`BOOTSTRAP_NEW_PROJECT.md` §2](BOOTSTRAP_NEW_PROJECT.md#2-provision-per-agent-github-apps) — make Boltz's `studio-audits` permission explicit in the install-permissions table. |

---

## Step 3 — Wire secrets + CI gates

Source: [`BOOTSTRAP_NEW_PROJECT.md` §3](BOOTSTRAP_NEW_PROJECT.md#3-wire-secrets--ci-gates).

| # | Assertion | Verification command | Expected result | Failure → patch |
|---|---|---|---|---|
| 3.1 | `audit-gate.yml` and `audit_gate.py` are present on `main` at their canonical paths. | `gh api repos/brott-studio/<project>/contents/.github/workflows/audit-gate.yml?ref=main --jq .type && gh api repos/brott-studio/<project>/contents/.github/workflows/scripts/audit_gate.py?ref=main --jq .type` | Both exit `0`, both stdout lines are `file`. | [`BOOTSTRAP_NEW_PROJECT.md` §3.1](BOOTSTRAP_NEW_PROJECT.md#31-copy-the-required-workflows-from-battlebrotts-v2githubworkflows) — the copy-from-`battlebrotts-v2` list must name every file and its destination path. |
| 3.2 | `audit_gate.py` has been parameterised — no `battlebrotts-v2` literals remain outside comments. | `gh api repos/brott-studio/<project>/contents/.github/workflows/scripts/audit_gate.py?ref=main --jq -r .content \| base64 -d \| grep -nE '^[^#]*battlebrotts-v2' ; echo "rc=$?"` | `rc=1` (grep found no non-comment matches). Any non-comment match → FAIL. | [`BOOTSTRAP_NEW_PROJECT.md` §3.1](BOOTSTRAP_NEW_PROJECT.md#31-copy-the-required-workflows-from-battlebrotts-v2githubworkflows) — the parameterisation instruction must state "search the whole file for `battlebrotts-v2`" (constants AND docstrings), not just "replace the `PROJECT` constant". |
| 3.3 | Both required Actions secrets are present on the project repo. | `gh api repos/brott-studio/<project>/actions/secrets --jq '[.secrets[].name] \| sort \| join(",")'` | Exit `0`, stdout contains both `BOLTZ_APP_ID` and `BOLTZ_APP_PRIVATE_KEY` (other secrets may also be present). | [`BOOTSTRAP_NEW_PROJECT.md` §3.2](BOOTSTRAP_NEW_PROJECT.md#32-add-repo-level-actions-secrets) — the secrets list must be a literal checklist, and the `gh secret set` commands must be shown. |
| 3.4 | `Audit Gate` is listed as a required status check on `main`. | `gh api repos/brott-studio/<project>/branches/main/protection/required_status_checks --jq '.contexts \| index("Audit Gate")'` | Exit `0`, stdout is a number `≥ 0` (i.e. the context is present). `null` → FAIL. **N/A if the repo is private and the `brott-studio` org is on GitHub Free** — branch-protection endpoints return `403 Upgrade to GitHub Pro` on private Free-tier repos. Record N/A with that 403 as the reason; see [`BOOTSTRAP_NEW_PROJECT.md` §3.3](BOOTSTRAP_NEW_PROJECT.md#33-branch-protection-on-main) plan-prerequisite note. | [`BOOTSTRAP_NEW_PROJECT.md` §3.3](BOOTSTRAP_NEW_PROJECT.md#33-branch-protection-on-main) — the branch-protection skeleton must show the exact `gh api --method PUT` call to set required checks, and state the plan prerequisite for private repos. |
| 3.5 | `main` branch protection requires a PR for all changes. | `gh api repos/brott-studio/<project>/branches/main/protection --jq '.required_pull_request_reviews \| type'` | Exit `0`, stdout is `object` (null → FAIL). **N/A under the same Free-tier-private-repo condition as 3.4** — record N/A with the 403 as the reason. | [`BOOTSTRAP_NEW_PROJECT.md` §3.3](BOOTSTRAP_NEW_PROJECT.md#33-branch-protection-on-main) — "require a PR for all changes" must be accompanied by the literal API payload or `gh` command; plan prerequisite for private repos must be documented. |

---

## Step 4 — Point the framework at the new project

Source: [`BOOTSTRAP_NEW_PROJECT.md` §4](BOOTSTRAP_NEW_PROJECT.md#4-point-the-framework-at-the-new-project). Cross-ref: [`REPO_MAP.md`](REPO_MAP.md).

| # | Assertion | Verification command | Expected result | Failure → patch |
|---|---|---|---|---|
| 4.1 | `studio-framework/REPO_MAP.md` on `main` contains an entry naming `<project>`. | `gh api repos/brott-studio/studio-framework/contents/REPO_MAP.md?ref=main --jq -r .content \| base64 -d \| grep -c '<project>'` | Exit `0`, stdout is an integer `≥ 1`. **Expected FAIL state during the open-PR window:** `studio-framework@main` is branch-protected, so the REPO_MAP update lands via PR. Assertion 4.1 remains FAIL until that PR merges; re-score after merge. | [`BOOTSTRAP_NEW_PROJECT.md` §4](BOOTSTRAP_NEW_PROJECT.md#4-point-the-framework-at-the-new-project) — the REPO_MAP update step must specify required fields (role, writing agents, cross-links) as a checklist and acknowledge the PR-merge delivery path. |
| 4.2 | `studio-audits/audits/<project>/README.md` exists on `main`. | `gh api repos/brott-studio/studio-audits/contents/audits/<project>/README.md?ref=main --jq .type` | Exit `0`, stdout exactly `file`. | [`BOOTSTRAP_NEW_PROJECT.md` §4](BOOTSTRAP_NEW_PROJECT.md#4-point-the-framework-at-the-new-project) — give the exact `README.md` stub body or a link to a template. |
| 4.3 | No non-comment `battlebrotts-v2` literals remain in the new project's workflows (parameterisation check across all workflow files, not just `audit_gate.py`). | `for f in $(gh api repos/brott-studio/<project>/contents/.github/workflows --jq -r '.[].path'); do gh api "repos/brott-studio/<project>/contents/$f?ref=main" --jq -r .content \| base64 -d \| grep -nE '^[^#]*battlebrotts-v2' && echo "HIT $f"; done ; echo done` | Output is a single `done` line, no `HIT` lines. | [`BOOTSTRAP_NEW_PROJECT.md` §4](BOOTSTRAP_NEW_PROJECT.md#4-point-the-framework-at-the-new-project) — the "search for `battlebrotts-v2`" instruction must name the scope (all workflow files, not just one) and the expected clean result. |

---

## Step 5 — First-arc kickoff

Source: [`BOOTSTRAP_NEW_PROJECT.md` §5](BOOTSTRAP_NEW_PROJECT.md#5-first-arc-kickoff). Cross-ref: [`ARC_BRIEF.md`](ARC_BRIEF.md), [`PIPELINE.md`](PIPELINE.md).

| # | Assertion | Verification command | Expected result | Failure → patch |
|---|---|---|---|---|
| 5.1 | `arcs/arc-1.md` exists on `main` of `<project>`. | `gh api repos/brott-studio/<project>/contents/arcs/arc-1.md?ref=main --jq .type` | Exit `0`, stdout exactly `file`. | [`BOOTSTRAP_NEW_PROJECT.md` §5](BOOTSTRAP_NEW_PROJECT.md#5-first-arc-kickoff) — step 5.1 must state the exact path and that it lives on `main` (not a branch) before the first sprint PR opens. |
| 5.2 | The first-sprint-of-arc rule is documented in `audit_gate.py` — the deployed script contains the `M == 1` branch (literal `M == 1` check and the canonical FAIL summary). | `gh api repos/brott-studio/<project>/contents/.github/workflows/scripts/audit_gate.py?ref=main --jq -r .content \| base64 -d \| grep -F 'first sprint of an arc must introduce arcs/arc-'` | Exit `0`, at least one match line printed. | [`BOOTSTRAP_NEW_PROJECT.md` §5](BOOTSTRAP_NEW_PROJECT.md#5-first-arc-kickoff) — if the copied `audit_gate.py` is stale (missing the first-sprint-of-arc rule), the doc must either pin a minimum script version or include the rule inline for cross-check. |
| 5.3 | The first sprint plan lands at the canonical path `sprints/sprint-1.1.md` (opened as a PR against `main`). | `gh api 'repos/brott-studio/<project>/pulls?state=all&per_page=100' --jq '[.[] \| select(.head.ref != null) \| {num:.number, title:.title}] \| map(select(.title \| test("sprint-1\\.1"))) \| length'` | Exit `0`, stdout is an integer `≥ 1`. | [`BOOTSTRAP_NEW_PROJECT.md` §5](BOOTSTRAP_NEW_PROJECT.md#5-first-arc-kickoff) — step 5.4 must state the exact filename (`sprints/sprint-1.1.md`) and PR title convention so the kickoff PR is searchable. |

---

## Totals

- Step 1: 4 assertions
- Step 2: 4 assertions
- Step 3: 5 assertions
- Step 4: 3 assertions
- Step 5: 3 assertions
- **Total: 19 assertions** (minimum bar is ≥ 2/step, ≥ 10 total — this rubric clears both).

---

## Cross-references

- Source doc being validated: [`BOOTSTRAP_NEW_PROJECT.md`](BOOTSTRAP_NEW_PROJECT.md)
- Credentials + App bootstrap: [`SECRETS.md`](SECRETS.md)
- Pipeline stages: [`PIPELINE.md`](PIPELINE.md)
- Repo architecture: [`REPO_MAP.md`](REPO_MAP.md)
- Arc brief shape: [`ARC_BRIEF.md`](ARC_BRIEF.md)
- Escalation policy: [`ESCALATION.md`](ESCALATION.md)
