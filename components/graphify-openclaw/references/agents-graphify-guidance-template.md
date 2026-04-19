# AGENTS.md Graphify Guidance Template

Use this section in project-level `AGENTS.md` to strengthen graph-first cognition.

```md
## graphify

This project uses a Graphify knowledge graph at `graphify-out/`.

Rules:
- Before answering architecture, module dependency, or cross-file reasoning questions, read `graphify-out/GRAPH_REPORT.md` first.
- Prefer graph-guided navigation over blind raw grep when graph artifacts exist.
- For path-specific reasoning, use `graphify query`, `graphify path`, or `graphify explain` against `graphify-out/graph.json`.
- After significant code changes, refresh graph state with `/graphify .` or incremental update mode.
- If graph and source conflict, treat source as authority and mark graph output as stale until refreshed.
```

## Insertion policy

- If upstream installer is acceptable: use `graphify claw install`.
- If custom wording is required: apply this block with `scripts/apply_graphify_agents_guidance.py`.

## Safety note

For protected core AGENTS files, draft first and request explicit approval before write.
