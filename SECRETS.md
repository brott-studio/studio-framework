# Secrets Handling

How studio agents authenticate to GitHub and handle credentials.

**Core rule:** The GitHub PAT lives in a file. Never paste it in prompts, URLs, or commit messages.

---

## 🔐 GitHub PAT

**Location on the workspace host:** `~/.config/gh/brott-studio-token`
**Permissions:** `0600` (owner read/write only)
**Scope:** `brott-studio/*` repos (studio-framework, studio-audits, battlebrotts-v2, etc.)

## 🔐 Specc GitHub App Private Key

**Location on the workspace host:** `~/.config/gh/brott-studio-specc-app.pem`
**Permissions:** `0600` (owner read/write only)
**Use:** Read by `~/bin/specc-gh-token` to mint short-lived installation tokens for the `brott-studio-specc` GitHub App. Same "never in prompts/URLs/commits" rule as the PAT above.

## 🔐 Optic GitHub App Private Key

**App ID:** `3459479`
**Installation ID:** `125974902` (`brott-studio` org)
**Location on the workspace host:** `~/.config/gh/brott-studio-optic-app.pem`
**Permissions:** `0600` (owner read/write only)
**Use:** Read by `~/bin/optic-gh-token` to mint short-lived installation tokens for the `brott-studio-optic` GitHub App. Optic authenticates as this App for check-run posting (`Optic Verified` check on project PRs). Same "never in prompts/URLs/commits" rule as the PAT above.

## 🔐 Boltz GitHub App Private Key

**App ID:** `3459519`
**Installation ID:** `125975574` (`brott-studio` org)
**Location on the workspace host:** `~/.config/gh/brott-studio-boltz-app.pem`
**Permissions:** `0600` (owner read/write only)
**Use:** Read by `~/bin/boltz-gh-token` to mint short-lived installation tokens for the `brott-studio-boltz` GitHub App. Boltz authenticates as this App for review + merge operations (cross-actor APPROVE on Nutts-authored PRs returns 200 instead of 422 under the shared PAT). Same "never in prompts/URLs/commits" rule as the PAT above.
**Scope note (S18.2-001):** The Boltz App installation is **org-level** (`brott-studio`) with `repository_selection: selected`. The same installation ID (`125975574`) covers `studio-framework`, `battlebrotts-v2`, AND `studio-audits`. `GET /repos/brott-studio/studio-audits/installation` returns this ID — no separate studio-audits-scoped installation exists or is needed. The App's Contents permission is `write` at the App level; effective usage against `studio-audits` is read-only (enforced by the `Audit Gate` workflow logic, which only issues GETs).

### Why a file, not an env var or inline value

1. **Transcript hygiene.** Every prompt, spawn payload, and announce event is logged. A PAT in a prompt lives in those logs forever. A PAT in a file stays in the file.
2. **Rotation is cheap.** Overwrite the file. Nothing else changes. No spawn prompts to edit, no code to redeploy.
3. **Agents don't need to handle it.** They use standard `git` or `gh` commands; the credential helper supplies the token invisibly.

---

## How Agents Use The PAT

### Option 1: Credential helper (preferred)

Agents run standard git commands. A git credential helper reads the PAT from the file and supplies it on demand:

```bash
git config --global credential.helper 'store --file=/dev/null'
# (or a custom helper that reads from ~/.config/gh/brott-studio-token)
```

Agents just do:
```bash
git clone https://github.com/brott-studio/studio-framework.git
git push
```

### Option 2: Read at clone time (for ephemeral worktrees)

When cloning to a scratch location:

```bash
PAT=$(cat ~/.config/gh/brott-studio-token)
git clone https://x-access-token:${PAT}@github.com/brott-studio/<repo>.git /tmp/<repo>
cd /tmp/<repo>
# subsequent git push uses the credential stored in remote URL
```

**⚠️ Never** put `$PAT` or the literal token into:
- Spawn prompts
- Task descriptions sent to subagents
- Announce events / channel messages
- Commit messages or PR descriptions
- File contents committed to any repo

**Do** tell subagents: "Read the PAT from `~/.config/gh/brott-studio-token`."

---

## Secret-Sweep Discipline

Before any commit:
1. Run `grep -rE '(ghp_|github_pat_|x-access-token:)' . --exclude-dir=.git` in your working directory.
2. If anything matches, STOP and fix before committing.

Periodically (framework maintenance), sweep for leaks:
```bash
grep -rE '(ghp_|github_pat_)' /path/to/repos --exclude-dir=.git
```

If a token is exposed: **rotate immediately** (overwrite `~/.config/gh/brott-studio-token`, revoke the old one on GitHub), then do a git history rewrite only if the leak is in public history.

---

## Per-Agent GitHub App Bootstrap

How to stand up a new per-agent GitHub App for a studio role, or install an
existing one on a new project repo. Canonical worked examples: Optic (App ID
`3459479`, org installation `125974902`) and Boltz (App ID `3459519`, org
installation `125975574`). See also
[BOOTSTRAP_NEW_PROJECT.md](BOOTSTRAP_NEW_PROJECT.md) §2 for the
new-project-bringup context.

### 1. Create the App (org-level)

Create the App under the `brott-studio` organisation (org-owned, not
personal). Settings:

- **Homepage URL:** `https://github.com/brott-studio`
- **Webhook:** disabled (uncheck "Active"; agents poll the API, no webhook
  consumer exists).
- **Install on:** "Only on this account" (org-scoped; do not allow
  installations on arbitrary accounts).
- **Request user authorization:** off.

**Permissions (minimum per role):**

| Role | Contents | Pull-requests | Checks | Metadata | Notes |
|---|---|---|---|---|---|
| Specc (audits) | Write on `studio-audits`; Read on project repos | — | — | Read | Writes audit files; reads project state. |
| Boltz (reviewer/merger) | Write on project repos; Read on `studio-audits` | Write | — | Read | Reviews + merges PRs; reads audits for `Audit Gate`. |
| Optic (check-run reporter) | Read on project repos | — | Write | Read | Posts `Optic Verified` + `Audit Gate`-adjacent check-runs. |

Record the App ID (6-7 digit number) shown after creation — you'll need it
for the token-mint helper and for Actions secrets.

### 2. Install on the target repo

Either path is fine; the web UI is the common case for first-time install.

**Web-UI path (first-time install on a new repo):**

1. Go to `https://github.com/organizations/brott-studio/settings/apps/brott-studio-<agent>/installations`.
2. On the `brott-studio` installation row, click **Configure**.
3. Under "Repository access," select "Only select repositories" and add the
   new repo. Save.
4. Record the **installation ID** from the URL
   (`.../installations/<INSTALLATION_ID>`). For org-scoped installs this ID
   is stable across repo-set changes.

**API path (confirming install or scripting adds to existing installations):**

```bash
# Confirm the App is installed on a given repo (auth as the App JWT):
curl -sS -H "Authorization: Bearer $JWT" \
     -H "Accept: application/vnd.github+json" \
     https://api.github.com/repos/brott-studio/<repo>/installation
# → returns installation `id` and `app_id` on success (200).
```

Org-scoped installs with `repository_selection: selected` share one
installation ID across all selected repos. Adding a repo to the selected
set does not create a new installation — confirmed via the Boltz install
(ID `125975574` covers `studio-framework`, `battlebrotts-v2`, and
`studio-audits`).

### 3. Write the private key

Download the `.pem` from the App settings page ("Private keys" → "Generate
a private key"). Write it to the workspace host:

```bash
mv ~/Downloads/brott-studio-<agent>.<date>.private-key.pem \
   ~/.config/gh/brott-studio-<agent>-app.pem
chmod 0600 ~/.config/gh/brott-studio-<agent>-app.pem
```

Never commit the PEM. Never paste its contents into prompts, announce
events, or chat messages. The token-mint helpers read it directly at
mint-time.

### 4. Verify via token mint

Add or reuse a mint helper at `~/bin/<agent>-gh-token` (see existing
`~/bin/{specc,optic,boltz}-gh-token` for the canonical PyJWT-based
implementation). Smoke test:

```bash
BOLTZ_APP_ID=3459519 BOLTZ_INSTALLATION_ID=125975574 \
    ~/bin/boltz-gh-token | wc -c
# expect ≈ 40 chars + newline, exit 0
```

A successful mint returns a short-lived installation access token
(`ghs_...`, 40-character prefix plus payload). Non-zero exit or a
non-token response indicates a misconfigured App ID, installation ID, PEM
path, or repo access — chase those before wiring the App into any
workflow.

### 5. Wire into CI (project repos only)

For Apps that power CI workflows (currently Boltz for `Audit Gate`), add
the App ID and PEM contents as repo-level Actions secrets on each project
repo that needs them:

- `<AGENT>_APP_ID` — numeric App ID.
- `<AGENT>_APP_PRIVATE_KEY` — full PEM contents (CR-LF preserved).

Create via the REST API with libsodium sealed-box encryption (see
[API docs](https://docs.github.com/en/rest/actions/secrets)); never commit
the PEM and never echo it in a workflow log.

---

## Rotation

1. Generate a new fine-grained PAT on GitHub with `brott-studio/*` access.
2. `echo 'ghp_NEW_TOKEN' > ~/.config/gh/brott-studio-token && chmod 0600 ~/.config/gh/brott-studio-token`
3. Revoke the old PAT on GitHub.
4. No other changes required — agents pick up the new token automatically via credential helper.

---

## Other Secrets

If additional secrets appear (API keys for Playwright services, deploy hooks, etc.), apply the same pattern:
- Store in a dedicated file under `~/.config/`
- `0600` permissions
- Document the path here
- Agents read from file at usage time, never from prompts

---

## Cross-references

- Spawn protocol that depends on these rules: [SPAWN_PROTOCOL.md](SPAWN_PROTOCOL.md)
- Channel hygiene (PATs must never appear in channel messages): [COMMS.md](COMMS.md)

---

*[Compliance-reliant.] File location and "never in prompts" rule relies on agent behavior. Some protection is structural (0600 perms prevent sibling-process reads). A fully structural approach would require OpenClaw to mask credentials in transcripts — not available today.*
