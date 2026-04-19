from __future__ import annotations

import argparse
import re
import subprocess
import sys
from collections import defaultdict
from pathlib import Path

WIKI_ROOT = Path(r"C:\Users\Administrator\.openclaw\wiki")
CATEGORY_DIRS = ["concepts", "decisions", "procedures", "references", "snippets"]
CATEGORY_ALIASES = {
    "concept": "concepts",
    "concepts": "concepts",
    "decision": "decisions",
    "decisions": "decisions",
    "procedure": "procedures",
    "procedures": "procedures",
    "reference": "references",
    "references": "references",
    "snippet": "snippets",
    "snippets": "snippets",
}


def run(script: str, *args: str) -> int:
    cmd = [sys.executable, str(WIKI_ROOT / script), *args]
    result = subprocess.run(cmd, cwd=WIKI_ROOT)
    return result.returncode


def count_entries() -> dict[str, int]:
    stats = {}
    for category in CATEGORY_DIRS:
        path = WIKI_ROOT / category
        stats[category] = len([p for p in path.glob("*.md") if not p.name.startswith("_")]) if path.exists() else 0
    return stats


def graph_is_stale() -> tuple[bool, str]:
    graph = WIKI_ROOT / "graphify-out" / "graph.json"
    if not graph.exists():
        return True, "graph.json missing"
    graph_mtime = graph.stat().st_mtime
    newest_doc = 0.0
    newest_path = None
    for path in WIKI_ROOT.rglob("*.md"):
        if any(part in {"graphify-out", "templates", "__pycache__"} for part in path.parts):
            continue
        mt = path.stat().st_mtime
        if mt > newest_doc:
            newest_doc = mt
            newest_path = path
    if newest_doc > graph_mtime:
        return True, f"newer wiki file detected: {newest_path}"
    return False, "graph up to date"


def iter_docs():
    for path in WIKI_ROOT.rglob("*.md"):
        if any(part in {"graphify-out", "templates", "__pycache__", "legacy"} for part in path.parts):
            continue
        # Skip bridge sources (read-only)
        if "sources" in path.parts and any(part.endswith("-vaults") for part in path.parts):
            continue
        yield path


def check_broken_links() -> list[str]:
    issues = []
    pattern = r"\[\[([^\]|]+)(?:\|[^\]]+)?\]\]"
    for doc in iter_docs():
        text = doc.read_text(encoding="utf-8")
        for match in re.finditer(pattern, text):
            target = match.group(1).strip().replace("\\", "/")
            if target.endswith(".md"):
                target = target[:-3]
            # Check multiple possible locations
            candidates = [
                WIKI_ROOT / f"{target}.md",
                doc.parent / f"{target}.md",  # Same directory
            ]
            # Check all category dirs
            candidates.extend([WIKI_ROOT / c / f"{target}.md" for c in CATEGORY_DIRS])
            # Check syntheses in memory-vaults
            if "memory-vaults" in doc.parts:
                candidates.append(doc.parent / ".." / "syntheses" / f"{target}.md")
            if not any(p.exists() for p in candidates):
                issues.append(f"{doc.relative_to(WIKI_ROOT)} -> [[{match.group(1)}]]")
    return issues


def status_cmd() -> int:
    stats = count_entries()
    stale, reason = graph_is_stale()
    print("Wiki status")
    print("-----------")
    for category in CATEGORY_DIRS:
        print(f"{category}: {stats[category]}")
    print(f"total: {sum(stats.values())}")
    print(f"graph: {'STALE' if stale else 'OK'} ({reason})")
    return 0


def doctor_cmd() -> int:
    print("Wiki doctor")
    print("-----------")
    code = 0
    missing = [name for name in ["INDEX.md", "wiki-new.py", "wiki-index.py", "wiki-sync-links.py", "wiki-build-graph.py", "wiki-query.py"] if not (WIKI_ROOT / name).exists()]
    if missing:
        print("missing files:")
        for item in missing:
            print(f"- {item}")
        code = 1
    else:
        print("core files: OK")

    broken = check_broken_links()
    if broken:
        print(f"broken wiki links: {len(broken)}")
        for item in broken[:20]:
            print(f"- {item}")
        code = 1
    else:
        print("broken wiki links: 0")

    stale, reason = graph_is_stale()
    print(f"graph freshness: {'STALE' if stale else 'OK'} ({reason})")
    if stale:
        code = 1
    return code


def normalize_category(category: str) -> str:
    normalized = CATEGORY_ALIASES.get(category.strip().lower())
    if not normalized:
        valid = ", ".join(sorted(CATEGORY_ALIASES))
        raise SystemExit(f"invalid category: {category}. valid values: {valid}")
    return normalized


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="High-level wiki operations wrapper")
    sub = parser.add_subparsers(dest="cmd", required=True)
    sub.add_parser("status")
    sub.add_parser("doctor")
    p_new = sub.add_parser("new")
    p_new.add_argument("category")
    p_new.add_argument("title")
    p_new.add_argument("tags", nargs="?")
    p_new.add_argument("status", nargs="?", default="draft")
    p_build = sub.add_parser("build")
    p_build.add_argument("--semantic", action="store_true")
    p_build.add_argument("--model", default=None)
    sub.add_parser("index")
    sub.add_parser("sync-links")
    p_query = sub.add_parser("query")
    p_query.add_argument("terms", nargs="+")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    if args.cmd == "status":
        return status_cmd()
    if args.cmd == "doctor":
        return doctor_cmd()
    if args.cmd == "new":
        extra = [normalize_category(args.category), args.title]
        if args.tags is not None:
            extra.append(args.tags)
        if args.status is not None:
            extra.append(args.status)
        return run("wiki-new.py", *extra)
    if args.cmd == "build":
        extra = []
        if args.semantic:
            extra.append("--semantic")
        if args.model:
            extra.extend(["--model", args.model])
        return run("wiki-build-graph.py", *extra)
    if args.cmd == "index":
        return run("wiki-index.py")
    if args.cmd == "sync-links":
        return run("wiki-sync-links.py")
    if args.cmd == "query":
        stale, reason = graph_is_stale()
        if stale:
            print(f"warning: graph is stale ({reason}). query results may lag behind markdown source.")
        return run("wiki-query.py", *args.terms)
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
