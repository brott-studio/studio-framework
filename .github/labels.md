# Label Taxonomy — `brott-studio/studio-framework`

Canonical reference for labels in this repo. Every PR and issue must carry **at least one `area:*` label and at least one `prio:*` label**. The `label-check` GitHub Actions workflow ([`.github/workflows/label-check.yml`](workflows/label-check.yml)) enforces this on every PR.

Arc and type labels are additive.

---

## Naming convention

All namespaced labels use a **colon separator**: `area:framework`, `prio:P1`, `arc:orphan-recovery`. Slash form (`area/framework`) is **not** used — it would invalidate the closed-PR label history without functional benefit.

## How to add labels to a PR

- **GitHub UI:** open the PR, click the gear icon next to "Labels" in the right sidebar, select labels.
- **CLI:** `gh pr edit <N> --add-label "area:framework" --add-label "prio:P2"` (multiple `--add-label` flags allowed).

If `label-check` is red on a PR, you're missing one of the required namespaces — add the appropriate `area:*` and/or `prio:*` label and the check re-runs automatically.

---

## 1. Area labels (`area:*`) — required ≥1

| Label | Description | Color |
|---|---|---|
| `area:framework` | Studio framework docs / agent profiles / tooling | `1d76db` |
| `area:pipeline` | Pipeline / orchestration / CI gates / spawn behavior | `0366d6` |
| `area:compliance` | Audit, escalation, governance, label/contract enforcement | `5319e7` |
| `area:runtime` | OpenClaw harness — orphan-recovery, sentinel, gateway | `6f42c1` |

A PR may carry more than one `area:*` label when the change genuinely spans areas — prefer one when possible.

## 2. Priority labels (`prio:*`) — required ≥1

| Label | Description | Color |
|---|---|---|
| `prio:P0` | Blocking — arc-blocking or prod-down | `b60205` |
| `prio:P1` | Must land this arc | `d93f0b` |
| `prio:P2` | Should land soon; capacity-permitting | `fbca04` |
| `prio:P3` | Nice-to-have / backlog | `ededed` |

**Retired:** `prio:low` folds into `prio:P3`. Existing open issues still carrying `prio:low` should be re-labeled before the label is deleted.

## 3. Arc labels (`arc:*`) — optional, additive

Arc labels track which multi-sprint arc a PR or issue belongs to. They are **created at arc-start** and **retained at arc-close** as a historical index — closed PRs keep their `arc:*` label, and the label description is amended to `[CLOSED YYYY-MM-DD]` rather than the label being deleted.

| Label | Description | Color |
|---|---|---|
| `arc:orphan-recovery` | Orphan-Recovery Durability Arc (S19.1–S19.4+) | `c5def5` |

Future arcs cycle through pastel colors: `c5def5`, `bfd4f2`, `d4c5f9`, `c2e0c6`.

## 4. Type / category labels

Standard GitHub-style category tags. Not required by the contract; use when they add signal.

| Label | Description |
|---|---|
| `bug` | Defect / regression |
| `enhancement` | New capability or improvement |
| `documentation` | Docs-only change |
| `backlog` | Triaged but not scheduled |

Plus GitHub defaults (`good first issue`, `help wanted`, etc.) where they apply.

**Retired:** `sprint:18.5` was a one-off label superseded by the `arc:*` pattern. It will be deleted once the remaining open reference is re-labeled.

---

## Enforcement (summary)

| Layer | Mechanism |
|---|---|
| Human contract | Boltz Review Checklist item ([`agents/boltz.md`](../agents/boltz.md#review-checklist)) |
| CI structural gate | `.github/workflows/label-check.yml` — verifies namespace presence on every PR |
| Branch protection | `label-check / verify-required-labels` is a required status check on `main` |

The CI check validates **namespace presence only** — it does not enforce specific label values, spelling against this taxonomy, or `arc:*` presence. The Boltz checklist provides the human-readable contract for value-level correctness.

---

*This file is the canonical taxonomy. If you add or retire a label, update this file in the same PR.*
