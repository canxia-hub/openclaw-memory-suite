# Graphify Upstream Verified Facts (2026-04-10)

This file records facts verified from the upstream project `safishamsi/graphify` to avoid assumptions.

## Repository identity

- Repository: `https://github.com/safishamsi/graphify`
- Default branch: `v3`
- License: MIT
- Project created at: `2026-04-03T15:49:07Z`

Verified via:
- `gh repo view safishamsi/graphify --json ...`

## Official package and CLI naming

- Official PyPI package name: `graphifyy`
- CLI entrypoint command: `graphify`
- Python requirement: `>=3.10`

Verified via:
- `README.md` (official package warning)
- `pyproject.toml` (`name = "graphifyy"`, `[project.scripts] graphify = ...`)

## OpenClaw-specific install and behavior

- Install command for OpenClaw platform skill:
  - `graphify install --platform claw`
- Project-level always-on guidance command:
  - `graphify claw install`
- OpenClaw extraction note in README:
  - OpenClaw uses sequential extraction (parallel agent support still early)

Verified via:
- `README.md` platform matrix and notes

## What `graphify claw install` actually changes

From upstream `graphify/__main__.py`:

- `claw install` routes to `_agents_install(Path("."), "claw")`.
- `_agents_install` writes or appends a `## graphify` section into project-root `AGENTS.md`.
- For OpenClaw branch, no codex hook and no opencode plugin branch executes.
- Console note states AGENTS.md is the always-on mechanism for platforms without PreToolUse-equivalent hook.

Practical implication:
- Run `graphify claw install` in the intended project root only.
- Do not run it in a wrong directory (it edits that directory’s `AGENTS.md`).

## Core output structure

Graphify default output folder:

```text
graphify-out/
├── graph.html
├── GRAPH_REPORT.md
├── graph.json
└── cache/
```

Verified via:
- `README.md`

## Pipeline model (high-level)

Documented pipeline:

```text
detect -> extract -> build_graph -> cluster -> analyze -> report -> export
```

- Structural extraction: tree-sitter AST for code
- Semantic extraction: LLM/vision for docs, papers, images
- Graph + community clustering: NetworkX + Leiden

Verified via:
- `ARCHITECTURE.md`
- `README.md`

## Operational constraints for OpenClaw rollout

1. Use official package only: `graphifyy`.
2. Treat `graphify claw install` as a project AGENTS mutation action.
3. Keep AGENTS guidance explicit: read `graphify-out/GRAPH_REPORT.md` before raw search.
4. Validate with real graph artifacts, not command success only.
