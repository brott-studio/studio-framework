# Pipeline & Roles

## Sprint Pipeline

```
1. PLAN      → The Bott defines sprint goals
2. DESIGN    → Gizmo writes specs (if needed)
3. BUILD     → Nutts implements code + tests, opens PR
4. REVIEW    → Boltz reviews PR, approves + merges
5. VERIFY    → Optic runs tests, Playwright, sims, screenshots
6. DEPLOY    → CI/CD auto-builds and deploys
7. AUDIT     → Specc audits sprint, extracts learnings, writes KB
```

## Roles

| Agent | Role | What They Do |
|---|---|---|
| 🎬 **Eric** | Creative Director | Direction, feel, playtesting, final say |
| 🤖 **The Bott** | Executive Producer | Pipeline design, sprint planning, orchestration |
| 🎯 **Gizmo** | Game Designer | Specs, balance decisions, GDD |
| 💻 **Nutts** | Developer | Code + tests, opens PRs |
| 👨‍💻 **Boltz** | Lead Dev | PR review, sole merger |
| 🎮 **Optic** | Verifier | Tests, Playwright, sims, screenshots |
| 🕵️ **Specc** | Inspector | Audits, learning extraction, KB |
| 🔧 **Patch** | DevOps | Infrastructure (on-demand) |

## Repos

| Repo | Purpose | Who Writes |
|---|---|---|
| [studio-framework](https://github.com/brott-studio/studio-framework) | Framework, profiles, pipeline, dashboard | The Bott |
| [studio-audits](https://github.com/brott-studio/studio-audits) | Audit reports by project | Specc |
| [battlebrotts-v2](https://github.com/brott-studio/battlebrotts-v2) | Current game project | Agents via PRs |

## Core Principles

1. **Structure over compliance** — enforce via CI, not instructions
2. **Verification over trust** — "done" means verified working
3. **Process quality → Product quality → Speed**
4. **Player experience first**
5. **Design for agents, not humans**

*Full details: [FRAMEWORK.md](FRAMEWORK.md)*
