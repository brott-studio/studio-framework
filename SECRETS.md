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
