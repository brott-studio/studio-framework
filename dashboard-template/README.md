# dashboard-template/

Reference files for registering a project with the studio dashboard.

For the end-to-end setup guide, see [`../DASHBOARD_SETUP.md`](../DASHBOARD_SETUP.md).

## Files

- **`project.json.template`** — canonical example manifest. Copy to `.studio/project.json` in your project repo and edit.
- **`examples/`** — real manifests from live projects, committed here for reference (the actual files also live at `.studio/project.json` in each project repo).

## Manifest field reference

JSON doesn't support comments, so the annotated schema lives here instead of inside the template file.

| Field | Required | Type | Default | Notes |
|---|---|---|---|---|
| `name` | **yes** | string | — | Must match the GitHub repo name. Used for URL routing (`?project=<name>`) and as the audit folder default. |
| `org` | **yes** | string | — | GitHub org slug. For the studio: `brott-studio`. |
| `displayName` | no | string | `name` | Human-readable label shown in the picker and page title. |
| `auditRepo` | no | string | `studio-audits` | Repo where sprint audits live, relative to `org`. |
| `auditFolder` | no | string | `name` | Subfolder under `audits/` in `auditRepo`. Only set this if the folder name differs from the project name. |
| `paths.gdd` | no | string | `docs/gdd.md` | Path (relative to repo root) to the Game Design Document. |
| `paths.designDocs` | no | string | `docs/design` | Directory containing per-sprint design markdown files. |
| `paths.kb` | no | string | `docs/kb` | Flat directory of knowledge-base markdown files. |
| `ciWorkflows` | no | string[] | `null` (show all) | Whitelist of workflow filenames (e.g. `["ci.yml", "deploy.yml"]`) to surface in the CI panel. Omit or leave empty to show every workflow. |
| `liveUrl` | no | string | `null` | If set, a **▶ Live Build** link appears in the dashboard header pointing here. Typical: the project's GitHub Pages URL. |

## Minimal manifest

Every field except `name` and `org` is optional. A legal manifest can be as small as:

```json
{ "name": "my-project", "org": "brott-studio" }
```

The dashboard will use defaults for everything else and work immediately as long as your project follows the default layout (`docs/gdd.md`, `docs/design/`, `docs/kb/`, audits in `studio-audits/audits/my-project/`).
