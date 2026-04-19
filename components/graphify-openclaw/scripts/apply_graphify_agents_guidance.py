#!/usr/bin/env python3
"""Insert or update Graphify guidance block in AGENTS.md.

Usage:
  python scripts/apply_graphify_agents_guidance.py --agents AGENTS.md
  python scripts/apply_graphify_agents_guidance.py --agents AGENTS.md --template references/agents-graphify-guidance-template.md
"""

from __future__ import annotations

import argparse
from pathlib import Path

START = "<!-- graphify-guidance:start -->"
END = "<!-- graphify-guidance:end -->"


def load_template(path: Path) -> str:
    text = path.read_text(encoding="utf-8")
    fence = "```md"
    if fence in text:
        start = text.find(fence)
        end = text.find("```", start + len(fence))
        if start != -1 and end != -1:
            return text[start + len(fence) : end].strip() + "\n"
    return text.strip() + "\n"


def upsert_block(content: str, block: str) -> tuple[str, str]:
    wrapped = f"{START}\n{block.rstrip()}\n{END}\n"

    if START in content and END in content:
        a = content.find(START)
        b = content.find(END, a)
        if b == -1:
            raise ValueError("Found start marker without end marker")
        b += len(END)
        # consume trailing newline cluster
        while b < len(content) and content[b] in "\r\n":
            b += 1
        new_content = content[:a].rstrip() + "\n\n" + wrapped + "\n" + content[b:].lstrip()
        return new_content.rstrip() + "\n", "updated"

    if content.strip():
        new_content = content.rstrip() + "\n\n" + wrapped
    else:
        new_content = wrapped
    return new_content.rstrip() + "\n", "inserted"


def main() -> None:
    parser = argparse.ArgumentParser(description="Apply Graphify guidance block to AGENTS.md")
    parser.add_argument("--agents", default="AGENTS.md", help="Target AGENTS.md path")
    parser.add_argument(
        "--template",
        default=str(Path(__file__).resolve().parent.parent / "references" / "agents-graphify-guidance-template.md"),
        help="Template file path",
    )
    args = parser.parse_args()

    agents_path = Path(args.agents).resolve()
    template_path = Path(args.template).resolve()

    if not template_path.exists():
        raise FileNotFoundError(f"Template not found: {template_path}")

    block = load_template(template_path)

    if agents_path.exists():
        content = agents_path.read_text(encoding="utf-8")
    else:
        content = ""

    new_content, action = upsert_block(content, block)

    agents_path.parent.mkdir(parents=True, exist_ok=True)
    agents_path.write_text(new_content, encoding="utf-8")

    print(f"{action}: {agents_path}")
    print(f"template: {template_path}")


if __name__ == "__main__":
    main()
