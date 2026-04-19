# OpenClaw × Graphify Integration Plan (v1)

## 1. Goal

Introduce Graphify as an external-knowledge graph layer for OpenClaw workflows, while preserving OpenClaw memory/governance as the primary decision system.

## 2. Scope

In scope:
- Install Graphify runtime (`graphifyy` + `graphify` CLI)
- Enable OpenClaw-compatible Graphify skill install
- Add graph-first AGENTS guidance in project roots
- Define build/update/query operation flow
- Define verification and rollback path

Out of scope:
- Replacing OpenClaw memory system
- Automatic full migration of old memory records into graph

## 3. Architecture positioning

- Graphify role: external corpus understanding (code/docs/papers/images -> graph)
- OpenClaw memory role: internal durable decisions/facts/errors
- Integration principle: graph informs retrieval/navigation, memory remains governance source

## 4. Rollout phases

### Phase A - Foundation

1. Install:
   - `pip install graphifyy`
   - `graphify install --platform claw`
2. Validate:
   - `graphify --help`
3. Baseline check:
   - Ensure project has writable `AGENTS.md`

Exit criteria:
- Graphify CLI available
- OpenClaw platform skill installed

### Phase B - Project enablement

1. In each target project root:
   - `graphify claw install`
2. Confirm AGENTS guidance section appears (`## graphify`).

Exit criteria:
- Project AGENTS includes graph-first guidance

### Phase C - First graph build

1. Run:
   - `/graphify .`
2. Confirm output artifacts:
   - `graphify-out/graph.json`
   - `graphify-out/GRAPH_REPORT.md`
   - optional `graphify-out/graph.html`

Exit criteria:
- Non-empty graph and report generated

### Phase D - Operationalization

1. Use `graphify query/path/explain` for architecture Q&A.
2. Use `--update` for incremental refresh.
3. Keep AGENTS behavior anchored to GRAPH_REPORT first.

Exit criteria:
- At least 3 real questions answered via graph output
- Team follows graph-first navigation for architecture-level tasks

## 5. Verification checklist

- [ ] `graphify --help` succeeds
- [ ] `graphify claw install` applied in intended root
- [ ] `AGENTS.md` contains graphify section
- [ ] `graphify-out/graph.json` exists and has nodes
- [ ] `graphify query` returns relevant structure

## 6. Risk controls

1. Wrong-directory AGENTS mutation
   - Control: print and verify current working directory before `graphify claw install`
2. Misidentifying package
   - Control: enforce `graphifyy` only
3. Privacy for non-code inputs
   - Control: treat docs/images/papers as model-processed content and apply corpus hygiene
4. Over-reliance on graph
   - Control: keep final decisions in OpenClaw memory + human review

## 7. Rollback plan

- Project-level guidance rollback:
  - `graphify claw uninstall`
- Package rollback:
  - `pip uninstall graphifyy`
- Keep generated `graphify-out/` snapshots if needed for audit before cleanup

## 8. Completion definition

Integration is considered complete when:
1. Tooling installed and validated
2. AGENTS graph guidance active in target projects
3. At least one corpus fully graphed
4. Query path used in real task and judged useful
5. Team has documented operating guardrails
