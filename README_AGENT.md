# OpenClaw Memory Suite — Agent Installation Guide

> **Target Audience**: AI Agents  
> **Last Updated**: 2026-04-20  
> **Suite Version**: 1.0.0

---

## 🎯 Purpose

This guide provides AI Agents with structured instructions for installing, configuring, and using the OpenClaw Memory Suite.

---

## 📦 What's Included

| Component | Type | Purpose | Priority |
|-----------|------|---------|----------|
| `memory-lancedb-pro` | Plugin | LanceDB-backed long-term memory | Critical |
| `lancedb-pro-skill` | Skill | Memory system deployment & maintenance | High |
| `graphify-openclaw` | Skill | Wiki knowledge graph construction | High |
| `self-improvement` | Skill | Continuous learning & evolution | Medium |
| `CRON-JOBS.md` | Document | Scheduled task configuration | High |

---

## 🚀 Installation

### Step 1: Check Prerequisites

```bash
# Verify OpenClaw version (>= 2026.4.14 required)
openclaw --version

# Verify Node.js version (>= 18 required)
node --version

# Verify Git
git --version
```

### Step 2: Install Plugin

```bash
# Navigate to OpenClaw extensions directory
cd ~/.openclaw/extensions

# Clone or update memory-lancedb-pro
git clone https://github.com/canxia-hub/memory-lancedb-pro.git
cd memory-lancedb-pro
npm install
```

### Step 3: Install Skills

```bash
# Navigate to OpenClaw skills directory
cd ~/.openclaw/skills

# Clone skills (if not already present)
git clone https://github.com/canxia-hub/openclaw-memory-suite.git memory-suite

# Copy individual skills
cp -r memory-suite/components/lancedb-pro-skill ./lancedb-pro
cp -r memory-suite/components/graphify-openclaw ./graphify-openclaw
cp -r memory-suite/components/self-improvement ./self-improving-agent
```

### Step 4: Configure OpenClaw

**Edit `~/.openclaw/openclaw.json`**:

```json
{
  "plugins": {
    "entries": {
      "memory-lancedb-pro": {
        "enabled": true,
        "config": {
          "dreaming": {
            "enabled": true,
            "frequency": "0 3 * * *",
            "verboseLogging": false
          }
        }
      }
    }
  },
  "memory-wiki": {
    "enabled": true,
    "config": {
      "vaultMode": "bridge",
      "bridge": {
        "enabled": true,
        "readMemoryArtifacts": true
      }
    }
  }
}
```

### Step 5: Configure Embedding

**Edit `~/.openclaw/openclaw.json`**:

```json
{
  "embedding": {
    "provider": "openai-compatible",
    "model": "qwen3-vl-embedding",
    "dimensions": 2560,
    "apiKey": "YOUR_API_KEY",
    "baseURL": "https://dashscope.aliyuncs.com/compatible-mode/v1"
  }
}
```

### Step 6: Restart Gateway

```bash
# Restart OpenClaw gateway to load new plugin
openclaw gateway restart

# Verify installation
openclaw doctor --non-interactive
```

---

## 🔧 Configuration Reference

### memory-lancedb-pro Plugin

**Minimal Config**:
```json
{
  "plugins": {
    "entries": {
      "memory-lancedb-pro": {
        "enabled": true
      }
    }
  }
}
```

**Full Config**:
```json
{
  "plugins": {
    "entries": {
      "memory-lancedb-pro": {
        "enabled": true,
        "config": {
          "dreaming": {
            "enabled": true,
            "frequency": "0 3 * * *",
            "timezone": "Asia/Shanghai",
            "verboseLogging": false,
            "storage": {
              "mode": "inline",
              "separateReports": false
            },
            "execution": {
              "speed": "balanced",
              "thinking": "medium",
              "budget": "medium"
            },
            "phases": {
              "light": {
                "enabled": true,
                "cron": "0 */6 * * *",
                "lookbackDays": 2,
                "limit": 100
              },
              "deep": {
                "enabled": true,
                "cron": "0 3 * * *",
                "limit": 10,
                "minScore": 0.8
              },
              "rem": {
                "enabled": true,
                "cron": "0 5 * * 0",
                "lookbackDays": 7,
                "limit": 10
              }
            }
          }
        }
      }
    }
  }
}
```

### memory-wiki Bridge

**Config**:
```json
{
  "memory-wiki": {
    "enabled": true,
    "config": {
      "vaultMode": "bridge",
      "bridge": {
        "enabled": true,
        "readMemoryArtifacts": true
      }
    }
  }
}
```

---

## 📚 Usage Guide

### Memory Operations

#### Store Memory

```typescript
memory_store({
  text: "Important decision: Choose option A over option B",
  category: "decision",
  importance: 0.85,
  scope: "agent:main"
})
```

#### Recall Memory

```typescript
memory_recall({
  query: "decision about option A",
  scope: "agent:main",
  limit: 5
})
```

#### Promote to Durable

```typescript
memory_promote({
  memoryId: "xxx-xxx-xxx",
  layer: "durable",
  state: "confirmed"
})
```

### Wiki Operations

#### Query Wiki

```bash
python ~/.openclaw/skills/graphify-openclaw/scripts/wiki_ops.py query "dreaming system"
```

#### Build Wiki Graph

```bash
python ~/.openclaw/skills/graphify-openclaw/scripts/wiki_ops.py build
```

#### Check Wiki Status

```bash
python ~/.openclaw/skills/graphify-openclaw/scripts/wiki_ops.py status
```

### Self-Improvement Operations

#### Log Learning

```typescript
self_improvement_log({
  type: "learning",
  summary: "Bridge sources should be skipped in wiki lint",
  category: "configuration",
  area: "memory-wiki"
})
```

#### Review Backlog

```typescript
self_improvement_review()
```

---

## 📊 Monitoring

### Health Check

```bash
# Run memory system health check
openclaw doctor --non-interactive

# Check wiki status
python wiki_ops.py status

# Check wiki lint
python wiki_ops.py doctor
```

### Statistics

```typescript
memory_stats({
  scope: "agent:main"
})
```

### Scheduled Tasks

```bash
# List cron jobs
openclaw cron list

# Check task status
cat ~/.openclaw/workspace/memory/heartbeat-state.json
```

---

## 🔍 Troubleshooting

### Issue: memory_recall returns empty

**Diagnosis**:
```typescript
memory_debug({
  query: "test",
  mode: "pipeline",
  limit: 5
})
```

**Common Causes**:
1. Scope mismatch — Check `scope` parameter
2. Embedding service failure — Check API key and endpoint
3. No matching memories — Broaden query

### Issue: Wiki lint shows broken links

**Solution**:
1. Check `wiki_ops.py` skips `legacy/` and `sources/` directories
2. Run `wiki_ops.py build` to rebuild graph
3. Verify bridge sources are read-only

### Issue: Daily digest not generated

**Solution**:
1. Check `dreaming.enabled` is `true`
2. Verify phase files exist in `memory/dreaming/`
3. Restart gateway to trigger digest

---

## 📁 File Structure

```
~/.openclaw/
├── extensions/
│   └── memory-lancedb-pro/     # Plugin
├── skills/
│   ├── lancedb-pro/            # Maintenance skill
│   ├── graphify-openclaw/      # Wiki skill
│   └── self-improving-agent/   # Learning skill
├── wiki/                        # Wiki vault
│   ├── concepts/
│   ├── decisions/
│   ├── procedures/
│   ├── references/
│   └── memory-vaults/
│       └── memory-lancedb-pro/
│           ├── sources/         # Bridge artifacts (read-only)
│           └── syntheses/       # New wiki pages
└── workspace/
    └── memory/
        ├── dreaming/            # Phase reports
        │   ├── light/
        │   ├── rem/
        │   └── deep/
        ├── YYYY-MM/             # Daily records
        │   ├── YYYY-MM-DD-complete.md
        │   └── YYYY-MM-DD-highlights.md
        └── CRON-JOBS.md         # Task configuration
```

---

## 🎓 Best Practices

### 1. Memory Categories

- `decision` — Important choices and rationale
- `fact` — Verified objective information
- `error` — Mistakes and their solutions
- `reflection` — Insights and improvements
- `entity` — People, places, things
- `other` — General purpose

### 2. Scope Usage

- `global` — Cross-agent shared knowledge
- `agent:xxx` — Agent-specific knowledge
- `project:xxx` — Project-specific knowledge
- `user:xxx` — User-specific knowledge

### 3. Importance Scoring

- `0.9-1.0` — Critical, never forget
- `0.7-0.9` — Important, frequently accessed
- `0.5-0.7` — Normal, occasionally accessed
- `0.3-0.5` — Low priority, rarely accessed
- `< 0.3` — Candidates for archival

### 4. Wiki Maintenance

- Run `wiki_ops.py doctor` weekly
- Archive outdated pages to `legacy/`
- Keep concepts, entities, procedures, references balanced
- Use syntheses for new structured knowledge

---

## 📞 Support

- **Documentation**: [docs/](./docs/)
- **Issues**: GitHub Issues
- **Community**: OpenClaw Discord

---

## 🔄 Updates

To update the suite:

```bash
# Update plugin
cd ~/.openclaw/extensions/memory-lancedb-pro
git pull origin master
npm install

# Update skills
cd ~/.openclaw/skills/memory-suite
git pull origin main
cp -r components/* ../

# Restart gateway
openclaw gateway restart
```

---

**End of Agent Guide**
