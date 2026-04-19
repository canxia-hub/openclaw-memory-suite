#!/usr/bin/env python3
"""Baseline verification for Graphify + OpenClaw integration."""

from __future__ import annotations

import json
import shutil
import subprocess
import sys
from pathlib import Path


def run(cmd: list[str]) -> tuple[bool, str]:
    try:
        p = subprocess.run(cmd, capture_output=True, text=True, check=False)
        out = (p.stdout or "") + (p.stderr or "")
        return p.returncode == 0, out.strip()
    except Exception as exc:
        return False, str(exc)


def main() -> None:
    report = {
        "python_version": sys.version.split()[0],
        "python_ok": sys.version_info >= (3, 10),
        "graphify_in_path": shutil.which("graphify") is not None,
    }

    ok_help, out_help = run(["graphify", "--help"]) if report["graphify_in_path"] else (False, "graphify not found in PATH")
    report["graphify_help_ok"] = ok_help
    report["graphify_help_preview"] = "\n".join(out_help.splitlines()[:8])

    ok_import, out_import = run([sys.executable, "-c", "import graphify; print('ok')"])
    report["python_import_graphify_ok"] = ok_import
    report["python_import_graphify_preview"] = out_import

    report["recommended_next_steps"] = [
        "pip install graphifyy" if not ok_import else "graphify package import looks good",
        "graphify install --platform claw" if not ok_help else "graphify CLI is callable",
        "graphify claw install (run inside target project root)",
    ]

    print(json.dumps(report, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
