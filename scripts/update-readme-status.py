#!/usr/bin/env python3
"""Update the README.md status block for the studio-framework repo.

This repo is framework documentation (no sprints of its own). The useful
status signal here is "which projects use this framework + their live
health." We render a compact portfolio table: per-project badges for CI
and open PRs, plus a link to each project's own README status block.

Configured project list lives in PROJECTS below. Add new projects by
editing that list.
"""
from __future__ import annotations

import datetime as dt
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
README = ROOT / "README.md"

BEGIN = "<!-- STATUS:BEGIN -->"
END = "<!-- STATUS:END -->"

ORG = "brott-studio"

# Projects that use this framework. Extend as new games/tools are added.
PROJECTS = [
    {
        "repo": "battlebrotts-v2",
        "name": "BattleBrotts v2",
        "description": "Autobattler roguelike — current active project",
    },
]


def badges(repo: str) -> str:
    """Compact CI + open-PRs + issues shields."""
    return (
        f'<img alt="ci" src="https://img.shields.io/github/actions/workflow/status/'
        f'{ORG}/{repo}/verify.yml?branch=main&label=CI"> '
        f'<img alt="prs" src="https://img.shields.io/github/issues-pr/'
        f'{ORG}/{repo}?label=open%20PRs"> '
        f'<img alt="backlog" src="https://img.shields.io/github/issues-search/'
        f'{ORG}/{repo}?query=label%3Abacklog+is%3Aopen&label=backlog">'
    )


def render() -> str:
    lines: list[str] = []
    lines.append("## 📊 Studio Portfolio")
    lines.append("")
    lines.append(
        f"Projects powered by this framework. "
        f"Each project's own README has a live status block (sprint, backlog, PRs, audits)."
    )
    lines.append("")

    for p in PROJECTS:
        repo = p["repo"]
        lines.append(f"### [{p['name']}](https://github.com/{ORG}/{repo})")
        lines.append(f"_{p['description']}_")
        lines.append("")
        lines.append(badges(repo))
        lines.append("")
        lines.append(
            f"**Details:** [README status](https://github.com/{ORG}/{repo}#-status) · "
            f"[open PRs](https://github.com/{ORG}/{repo}/pulls) · "
            f"[backlog](https://github.com/{ORG}/{repo}/issues?q=is%3Aissue+label%3Abacklog+is%3Aopen) · "
            f"[audits](https://github.com/{ORG}/studio-audits/tree/main/audits/{repo})"
        )
        lines.append("")

    lines.append("---")
    lines.append("")
    lines.append(
        f"**Framework repo:** [{ORG}/studio-framework](https://github.com/{ORG}/studio-framework) · "
        f"**Audits:** [{ORG}/studio-audits](https://github.com/{ORG}/studio-audits)"
    )
    lines.append("")
    lines.append(
        f"_Last updated: {dt.datetime.now(dt.timezone.utc).strftime('%Y-%m-%d %H:%M UTC')}"
        f" · [update workflow](../../actions/workflows/readme-status.yml)_"
    )
    return "\n".join(lines)


def strip_timestamp(block: str) -> str:
    return re.sub(r"_Last updated:.*", "", block)


def extract_block(text: str) -> str:
    m = re.search(re.escape(BEGIN) + r"(.*?)" + re.escape(END), text, re.DOTALL)
    return m.group(1) if m else ""


def splice(readme_text: str, new_block: str) -> str:
    if BEGIN not in readme_text or END not in readme_text:
        return f"{readme_text.rstrip()}\n\n{BEGIN}\n{new_block}\n{END}\n"
    pattern = re.compile(re.escape(BEGIN) + r".*?" + re.escape(END), re.DOTALL)
    return pattern.sub(f"{BEGIN}\n{new_block}\n{END}", readme_text)


def main() -> int:
    new_block = render()
    current = README.read_text(encoding="utf-8")
    updated = splice(current, new_block)

    if strip_timestamp(extract_block(current)) == strip_timestamp(extract_block(updated)):
        print("No semantic change — leaving README.md unchanged.")
        return 0

    README.write_text(updated, encoding="utf-8")
    print("README.md updated.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
