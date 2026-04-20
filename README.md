# OpenClaw Memory Suite

> **Version**: 1.0.0  
> **Status**: Production Ready  
> **License**: MIT  
> **Repository**: https://github.com/canxia-hub/openclaw-memory-suite

---

## 📖 Overview

OpenClaw Memory Suite 是一套完整的 AI Agent 长期记忆解决方案，包含：

- **memory-lancedb-pro** — LanceDB 增强型记忆插件
- **lancedb-pro-skill** — 记忆系统维护技能
- **graphify-openclaw** — Wiki 知识图谱技能
- **self-improvement** — 自我改进与学习系统
- **定时任务标准** — 记忆系统定时任务配置规范

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    OpenClaw Memory Suite                 │
├─────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────┐    │
│  │           memory-lancedb-pro (Plugin)           │    │
│  │  ┌──────────────────────────────────────────┐   │    │
│  │  │  LanceDB Store + Hybrid Retrieval        │   │    │
│  │  │  + Dreaming Phases + Daily Digest        │   │    │
│  │  └──────────────────────────────────────────┘   │    │
│  └─────────────────────────────────────────────────┘    │
│                          ↓                               │
│  ┌─────────────────────────────────────────────────┐    │
│  │         graphify-openclaw (Wiki Skill)          │    │
│  │  ┌──────────────────────────────────────────┐   │    │
│  │  │  Bridge Mode + Knowledge Graph           │   │    │
│  │  │  + Wiki Lint + Semantic Search           │   │    │
│  │  └──────────────────────────────────────────┘   │    │
│  └─────────────────────────────────────────────────┘    │
│                          ↓                               │
│  ┌─────────────────────────────────────────────────┐    │
│  │        self-improvement (Learning Skill)        │    │
│  │  ┌──────────────────────────────────────────┐   │    │
│  │  │  Experience Capture + Skill Extraction   │   │    │
│  │  │  + Error Learning + Continuous Evolution │   │    │
│  │  └──────────────────────────────────────────┘   │    │
│  └─────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────┘
```

---

## 📦 Components

### 1. memory-lancedb-pro (Plugin)

**Repository**: https://github.com/canxia-hub/memory-lancedb-pro

**Core Features**:
- LanceDB 向量存储 + BM25 全文索引
- 混合检索（Vector + BM25 + Rerank）
- Dreaming 三阶段机制（Light/REM/Deep）
- Daily Digest 自动生成
- Memory-Wiki Bridge 实时同步
- 多作用域隔离（Agent/Project/User）

**Version**: v1.3.1

---

### 2. lancedb-pro-skill (Skill)

**Purpose**: 记忆系统部署与维护技能

**Features**:
- 快速部署指南
- 配置模板（OpenAI/DashScope/Ollama/Jina）
- 健康检查流程
- 故障排查手册
- 最佳实践

---

### 3. graphify-openclaw (Wiki Skill)

**Purpose**: Wiki 知识图谱构建与维护

**Features**:
- Bridge 模式（LanceDB artifacts 实时同步）
- 知识图谱构建
- Wiki Lint（链接验证、噪音过滤）
- 语义搜索
- Obsidian CLI 集成

---

### 4. self-improvement (Skill)

**Purpose**: Agent 自我改进与持续学习

**Features**:
- 经验捕获（LEARNINGS.md）
- 错误记录（ERRORS.md）
- 技能提取（从经验到技能）
- 定时整理与聚类
- 规则演进建议

---

### 5. 定时任务标准

**Document**: `docs/CRON-JOBS.md`

**Purpose**: 记忆系统定时任务配置规范

**Tasks**:
- Dreaming Phases（Light/REM/Deep）
- Daily Digest（complete/highlights 生成）
- 健康检查（索引完整性、bridge 状态）
- 归档整理（周归档、月维护）
- Self-improvement（自我成长、自我进化）

---

## 🚀 Quick Start

### For Humans

See [README_AGENT.md](./README_AGENT.md) for Agent installation guide.

### Basic Usage

**📖 详细安装指南**: 请查阅 [INSTALLATION-GUIDE.md](./docs/INSTALLATION-GUIDE.md) 获取完整的安装步骤、配置规范和故障排查指南。

```bash
# 1. Install the suite
git clone https://github.com/canxia-hub/openclaw-memory-suite.git
cd openclaw-memory-suite

# 2. Install components
./scripts/install.sh

# 3. Configure OpenClaw
# Add to openclaw.json:
# {
#   "plugins": {
#     "entries": {
#       "memory-lancedb-pro": { "enabled": true }
#     }
#   }
# }

# 4. Restart OpenClaw
openclaw gateway restart
```

---

## 📚 Documentation

- [README_AGENT.md](./README_AGENT.md) — Agent 安装指南
- [ANNOUNCEMENT.md](./ANNOUNCEMENT.md) — 项目公告
- [docs/CRON-JOBS.md](./docs/CRON-JOBS.md) — 定时任务配置
- [docs/architecture.md](./docs/architecture.md) — 架构文档

---

## 🔗 Related Repositories

| Repository | Description |
|------------|-------------|
| [memory-lancedb-pro](https://github.com/canxia-hub/memory-lancedb-pro) | LanceDB 记忆插件 |
| [openclaw](https://github.com/openclaw/openclaw) | OpenClaw 核心框架 |

---

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](./CONTRIBUTING.md) for details.

---

## 📄 License

MIT License — see [LICENSE](./LICENSE) for details.

---

## 👥 Authors

- **win4r** — Original memory-lancedb-pro author
- **canxia-hub** — Maintenance and enhancements

---

## 🙏 Acknowledgments

- OpenClaw Team
- LanceDB Team
- All contributors and users
