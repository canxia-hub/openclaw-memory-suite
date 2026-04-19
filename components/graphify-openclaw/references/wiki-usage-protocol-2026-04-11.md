# Wiki Usage Protocol

## Goal

Give both humans and agents one predictable way to operate the private wiki.

## Preferred entrypoint

Use:

```bash
python ~/.openclaw/skills/graphify-openclaw/scripts/wiki_ops.py <command>
```

## Commands

### Status

```bash
python ~/.openclaw/skills/graphify-openclaw/scripts/wiki_ops.py status
```

Shows category counts and whether the graph is stale.

### Doctor

```bash
python ~/.openclaw/skills/graphify-openclaw/scripts/wiki_ops.py doctor
```

Checks:
- core wiki files exist
- broken `[[wikilinks]]`
- graph freshness

### New entry

```bash
python ~/.openclaw/skills/graphify-openclaw/scripts/wiki_ops.py new concept "Agent 通信协议" "agent,communication" stable
```

Creates the entry and triggers sync/index/build through `wiki-new.py`. Category accepts both singular and plural forms, for example `concept` and `concepts`.

### Build graph

```bash
python ~/.openclaw/skills/graphify-openclaw/scripts/wiki_ops.py build
python ~/.openclaw/skills/graphify-openclaw/scripts/wiki_ops.py build --semantic
```

Use `--semantic` when you want DashScope to infer cross-document relations.

### Query

```bash
python ~/.openclaw/skills/graphify-openclaw/scripts/wiki_ops.py query 记忆
```

Returns matching nodes first, then relation lines. After that, the agent should read the matched Markdown source files.

## Agent workflow

### Read path

1. `status` only if freshness is unclear
2. `query <terms>`
3. Read matched Markdown files
4. Answer using source files as authority

### Write path

1. `new <category> <title> ...`
2. Fill the new Markdown file
3. Re-run `build --semantic` only when semantic relation refresh is worth the API cost

## Reliability rules

- Prefer `wiki_ops.py` over directly remembering individual scripts
- If `doctor` reports stale graph, rebuild before relying on graph edges
- If semantic build fails, fall back to structural graph and continue using Markdown as authority
