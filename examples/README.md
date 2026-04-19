# OpenClaw Memory Suite - Examples

This directory contains example configurations and use cases.

---

## Example Configurations

### 1. Basic Configuration

See `basic-config.json` for minimal setup.

### 2. Full Configuration

See `full-config.json` for complete setup with all features enabled.

### 3. Multi-Agent Setup

See `multi-agent-config.json` for shared memory across agents.

---

## Example Workflows

### Memory Lifecycle

```
1. Store → Working Layer (pending)
2. Recall → Verify usefulness
3. Promote → Durable Layer (confirmed)
4. Archive → Long-term storage
```

### Wiki Maintenance

```
1. Bridge syncs LanceDB artifacts
2. Create new wiki pages in syntheses/
3. Build graph with graphify
4. Run lint to verify links
```

### Self-Improvement Cycle

```
1. Capture experience → LEARNINGS.md
2. Detect patterns → Cluster analysis
3. Extract skills → New skills
4. Update rules → Core files
```

---

## Example Scripts

### Daily Health Check

```bash
#!/bin/bash
# Run daily at 03:00

# Health check
openclaw doctor --non-interactive

# Wiki lint
python ~/.openclaw/skills/graphify-openclaw/scripts/wiki_ops.py doctor

# Memory stats
# Use memory_stats tool in your agent
```

### Weekly Maintenance

```bash
#!/bin/bash
# Run weekly on Monday 03:30

# Rebuild wiki graph
python wiki_ops.py build --semantic

# Archive old memories
# Use memory_archive tool

# Review self-improvement backlog
# Use self_improvement_review tool
```

---

## Example Use Cases

### 1. Personal Assistant

**Memory Categories**:
- `preference` — User preferences
- `fact` — Personal information
- `decision` — Past decisions

**Scopes**:
- `agent:main` — Main assistant
- `user:xxx` — User-specific

### 2. Project Manager

**Memory Categories**:
- `fact` — Project details
- `decision` — Technical decisions
- `error` — Lessons learned

**Scopes**:
- `project:xxx` — Project-specific
- `agent:main` — General knowledge

### 3. Research Assistant

**Memory Categories**:
- `fact` — Research findings
- `entity` — People, papers, concepts
- `other` — General notes

**Scopes**:
- `global` — Shared knowledge
- `agent:research` — Research-specific
