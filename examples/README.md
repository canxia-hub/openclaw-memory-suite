# OpenClaw Memory Suite - Examples

This directory contains current configuration examples aligned to:

- `memory-lancedb-pro v1.3.2`
- `openclaw-memory-suite v1.1.0`

---

## Available examples

### `basic-config.json5`

Use this when you want the smallest working setup:

- plugin enabled
- embedding configured
- Dreaming enabled
- timezone declared

### `full-config.json5`

Use this when you want the recommended production-style setup:

- management tools enabled
- complete Dreaming config
- explicit Light / Deep / REM cron schedules
- memory-wiki bridge enabled

---

## Important note

Current Dreaming is **true three-phase**.

That means the active model is:

- `Memory Dreaming Light`
- `Memory Dreaming Promotion`
- `Memory Dreaming REM`

Do not treat the old single-promotion explanation as current truth.
