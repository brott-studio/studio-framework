# Dashboard Setup

One URL serves the whole studio: **<https://brott-studio.github.io/studio-framework/>**.

The dashboard is project-agnostic. Every repo under `brott-studio/` that ships a `.studio/project.json` manifest shows up automatically in the project-picker dropdown and gets its own panels (GDD, design docs, KB, PRs, CI runs, audits, pulse) for free.

## Register a project

1. In your project repo, add a manifest at `.studio/project.json`. Minimum viable file:

   ```json
   {
     "name": "my-project",
     "org": "brott-studio"
   }
   ```

2. Commit & push to `main`.
3. Open the dashboard and wait up to 5 minutes (discovery cache TTL) — or append `?refresh` to the URL to bypass the cache. Your project appears in the dropdown.
4. Switch to it; panels populate from defaults (`docs/gdd.md`, `docs/design/`, `docs/kb/`, `studio-audits` repo with folder matching the project name).

## Manifest schema

See [`dashboard-template/project.json.template`](dashboard-template/project.json.template) and [`dashboard-template/README.md`](dashboard-template/README.md) for the annotated reference.

All fields except `name` and `org` are optional. Missing fields fall back to the dashboard's built-in defaults, so legacy projects without a manifest continue to work unchanged.

## URL parameters

- `?project=<name>` — load a specific project (also set by the dropdown).
- `?refresh` or `?nocache` — bypass all localStorage caches (discovery list, audits, PRs, CI runs).
- `?audit_folder=<name>` — override the audits folder name if it differs from the project name (rare).

## Caching

- Org project discovery: 5 min.
- Audits list: 2 min.
- Everything else (PRs, CI runs, contents listings): 5 min.

All caches live in `localStorage` keyed by URL; `?refresh` clears them for the current page load.

## Troubleshooting

- **My project doesn't appear in the dropdown.** Check that `.studio/project.json` is on `main` and is valid JSON. Append `?refresh` to force rediscovery.
- **Panels show "Failed to load" or "404".** Your manifest paths point somewhere that doesn't exist. Check `paths.gdd`, `paths.designDocs`, `paths.kb` against your actual repo layout, or omit them to use defaults.
- **Audits panel is empty.** Ensure `studio-audits/audits/<project-name>/*.md` exists, or set `auditFolder` in the manifest.
