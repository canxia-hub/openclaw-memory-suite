# OpenClaw Memory Suite

> **Version**: 1.1.0  
> **Status**: Production Ready  
> **License**: MIT  
> **Repository**: https://github.com/canxia-hub/openclaw-memory-suite

OpenClaw Memory Suite 是面向 OpenClaw 的记忆系统分发与文档仓库，负责把 **最新版 `memory-lancedb-pro` 插件**、相关技能、Wiki bridge 协作方式，以及 **Dreaming 配置方法** 整理成可复用安装路径。

---

## 当前推荐版本

| Component | Recommended Version | Notes |
|-----------|---------------------|-------|
| `memory-lancedb-pro` | `v1.3.2` | true three-phase Dreaming |
| `openclaw-memory-suite` | `v1.1.0` | docs + install path aligned to v1.3.2 |

---

## 包含内容

- `components/lancedb-pro-skill` — 记忆系统维护技能
- `components/graphify-openclaw` — Wiki 知识图谱技能
- `components/self-improvement` — 自我改进技能
- `docs/CRON-JOBS.md` — Dreaming 与宿主级任务口径
- `docs/INSTALLATION-GUIDE.md` — 完整安装与升级指南
- `examples/` — 推荐配置示例

---

## 这次更新了什么

### 1. 对齐最新版插件

仓库文档已统一到 `memory-lancedb-pro v1.3.2`：

- true three-phase Dreaming
- Light / Deep / REM 三条独立 managed cron
- Deep phase 保持 memory-core promotion identity
- 不再使用旧的单一 Dreaming promotion 口径

### 2. 更新 Dreaming 配置方法

当前推荐配置方式不是“只开一个 daily frequency 就结束”，而是：

- 开启 `dreaming.enabled`
- 明确 `timezone`
- 按需配置 `phases.light / phases.deep / phases.rem`
- 用 `openclaw doctor --non-interactive` 先验证，再重启 gateway

### 3. 保留最小配置与完整配置两条路径

- `examples/basic-config.json5`
- `examples/full-config.json5`

---

## 快速安装

**📖 详细安装指南**: 请查阅 [INSTALLATION-GUIDE.md](./docs/INSTALLATION-GUIDE.md) 获取完整的安装步骤、配置规范和故障排查指南。

### 1. 安装插件

```bash
cd ~/.openclaw/extensions
git clone https://github.com/canxia-hub/memory-lancedb-pro.git
cd memory-lancedb-pro
git checkout v1.3.2
npm install
```

### 2. 安装本套件

```bash
cd ~/.openclaw/skills
git clone https://github.com/canxia-hub/openclaw-memory-suite.git memory-suite
cd memory-suite
git checkout v1.1.0
```

### 3. 复制技能

将以下目录复制到你的 skills 目录中：

- `components/lancedb-pro-skill` → `lancedb-pro`
- `components/graphify-openclaw` → `graphify-openclaw`
- `components/self-improvement` → `self-improving-agent`

### 4. 选择配置模板

- 最小配置：`examples/basic-config.json5`
- 完整配置：`examples/full-config.json5`

### 5. 验证并重启

```bash
openclaw doctor --non-interactive
openclaw gateway restart
openclaw doctor --non-interactive
```

---

## 文档入口

- [README_AGENT.md](./README_AGENT.md) — 面向 Agent 的安装与验证指南
- [ANNOUNCEMENT.md](./ANNOUNCEMENT.md) — 当前版本公告
- [docs/CRON-JOBS.md](./docs/CRON-JOBS.md) — Dreaming / cron 最新口径
- [docs/INSTALLATION-GUIDE.md](./docs/INSTALLATION-GUIDE.md) — 完整安装指南
- [examples/README.md](./examples/README.md) — 配置示例说明

---

## 核心提醒

1. **先装插件源码，再改配置**，不要反过来。
2. **改完配置先 doctor，再 restart**。
3. **不要再把旧的单一 Dreaming cron 说明当成当前实现**。
4. Deep phase 当前兼容 Control UI 的关键点，是复用官方 promotion identity，而不是自造一套 UI 识别口径。

---

## License

MIT
