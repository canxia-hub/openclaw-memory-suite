---
name: lancedb-pro
description: >
  记忆系统统一维护技能。整合 LanceDB 长期记忆检索 + Dreaming 整理 + Memory 文件系统管理 + Bridge 互操作。
  提供记忆系统状态诊断、Dreaming 输出整理、文件搜索、索引维护、健康检查、归档整理功能。
  当用户要求「查看记忆」「搜索记忆」「整理 memory」「检查记忆系统」「运行 dreaming」「查看定时任务」时使用。
version: "1.3.0"
license: MIT
metadata:
  author: 小千 (Xiao Qian)
  category: memory-system
  replaces: ["lancedb-query", "memory-manager"]
  core_files: ["MEMORY.md", "memory/CRON-JOBS.md", "memory/INDEX.md", "DREAMS.md"]
  tags: memory lancedb recall dreaming bridge file-search health-check archive organize cron
---

# lancedb-pro — 记忆系统统一维护技能

> 整合长期记忆检索 + Dreaming 整理 + 文件系统管理 + Bridge 互操作
> 适配 memory-lancedb-pro v1.3.0

---

## 📋 技能架构

```
lancedb-pro/
├── SKILL.md          ← 本文件
└── scripts/
    └── mem-status.ps1   ← PowerShell 健康检查脚本（Windows 兼容）
```

## 🆕 v1.3.0 当前能力

### Dreaming 三阶段整理
- **Light Phase**: 会话摘要流水记录（事件驱动，不是独立 cron）
- **REM Phase**: 反思归纳与模式识别（事件驱动，不是独立 cron）
- **Deep Phase**: 稳定结论晋升（由 promotion 事件驱动，常见来源是 memory-core 每日晋升任务）

### 日终整理流程
- 从 dreaming 输出生成 complete.md / highlights.md
- 与现有记忆格式协调一致

### Bridge 互操作
- 96 个公开 artifacts 导出（当前运行态）
- memory-wiki bridge 模式支持
- Host events 事件日志

---

## 🔧 核心能力

### 能力一：长期记忆检索（使用内置工具）

**不依赖任何外部 CLI**，直接使用 OpenClaw 内置的 `memory_*` 工具。

| 操作 | 工具 | 说明 |
|------|------|------|
| 搜索记忆 | `memory_recall` | 向量+关键词混合检索 |
| 写入记忆 | `memory_store` | 写入 decision/fact/entity/reflection |
| 更新记忆 | `memory_update` | 修正已有记忆 |
| 归档记忆 | `memory_archive` | 软删除或硬删除 |
| 晋升记忆 | `memory_promote` | 晋升至 confirmed/durable 状态 |
| 统计信息 | `memory_stats` | 查看记忆库规模和类别分布 |
| 列表浏览 | `memory_list` | 按时间浏览近期记忆 |
| 调试检索 | `memory_debug` | 检索流程诊断 |

### 能力二：Dreaming 输出管理

#### 2.1 Dreaming 文件结构

```
memory/
├── dreaming/
│   ├── light/
│   │   └── 2026-04-19.md    # Light phase 报告
│   ├── rem/
│   │   └── 2026-04-19.md    # REM phase 报告
│   └── deep/
│       └── 2026-04-19.md    # Deep phase 报告
├── 2026-04/
│   ├── 2026-04-19-complete.md    # 日终整理生成
│   └── 2026-04-19-highlights.md  # 日终整理生成
└── .dreams/                     # 机器状态
```

#### 2.2 检查 Dreaming 输出

> 用户说：「检查今天的 dreaming 输出」

操作步骤：
1. 确认日期，构造文件路径
2. 读取 `memory/dreaming/light/YYYY-MM-DD.md`
3. 读取 `memory/dreaming/deep/YYYY-MM-DD.md`
4. 统计会话数和晋升记忆数
5. 报告结果

#### 2.3 查看晋升记录

> 用户说：「查看最近晋升的记忆」

操作步骤：
1. 读取 `DREAMS.md` 中的 Deep Sleep block
2. 解析晋升记录
3. 按时间排序展示

### 能力三：日终整理流程

#### 3.1 触发条件

- Gateway 启动时自动执行
- 处理前一天的 dreaming 输出

#### 3.2 手动触发

> 用户说：「生成昨日的完整记忆」

操作步骤：
1. 读取 `memory/dreaming/light/` 和 `memory/dreaming/deep/`
2. 解析会话摘要和决策
3. 生成 `memory/YYYY-MM/YYYY-MM-DD-complete.md`
4. 生成 `memory/YYYY-MM/YYYY-MM-DD-highlights.md`
5. 报告生成结果

#### 3.3 格式协调

Dreaming 输出与现有格式关系：

| Dreaming 输出 | 现有格式 | 关系 |
|--------------|---------|------|
| Light (实时) | complete.md | Light 是 complete 的前置素材 |
| Deep (晋升时) | MEMORY.md | Deep 筛选可晋升的 durable 结论 |
| REM (反思时) | highlights.md | REM 提炼可进入 highlights 的模式 |

### 能力四：Bridge 互操作

#### 4.1 检查 Bridge 状态

```bash
openclaw wiki doctor
```

预期输出：
```
Wiki doctor: healthy
Bridge: enabled (92 exported artifacts)
Source provenance: 91 bridge, 1 bridge-events
```

#### 4.2 导出的 Artifacts 类型

| Kind | 文件 | 数量 |
|------|------|------|
| memory-root | MEMORY.md, DREAMS.md | 每个 workspace 2 个 |
| daily-note | memory/YYYY-MM/*.md | 每月多个 |
| dream-report | memory/dreaming/**/*.md | 每个 phase 每天 1 个 |
| event-log | memory/.openclaw/events.jsonl | 每个 workspace 1 个 |

#### 4.3 Host Events 查询

> 用户说：「查看最近的 memory 事件」

操作步骤：
1. 读取 `memory/.openclaw/events.jsonl`
2. 过滤最近的 20 条事件
3. 按时间排序展示

### 能力五：Memory 文件系统管理

通过 Agent 直接使用 `read` / `write` / `exec` 工具操作。

| 操作 | 实现方式 | 说明 |
|------|---------|------|
| 状态检查 | 直接读取 memory/ | 统计文件数、月度目录、索引完整性 |
| 文件搜索 | `Get-ChildItem` + `Select-String` | 按关键词/日期/月搜索记忆文件 |
| 索引更新 | 直接写入 INDEX.md | 生成/修复月度索引和总索引 |
| 文件整理 | `Move-Item` | 将会话文件移动到对应月度目录 |
| 健康检查 | 综合巡检 | 配对检查、current-task 巡检、cron 状态检查 |

### 能力六：定时任务状态巡检

通过 `cron list` 工具检查记忆系统相关定时任务状态：

| 任务 | 频率 | 说明 |
|------|------|------|
| 记忆系统每日健康检查与归档 | 每日 03:00 | 主账本整理、健康检查、归档 |
| Memory Dreaming Promotion | 每日 03:00 | memory-core 短期晋升任务，间接喂给 deep phase |
| 自我进化脉冲 | 每日 02:00 | 工具使用与工作流精炼 |
| 记忆系统每周归档 | 周一 03:30 | 周归档、桥接层巡检 |
| 记忆系统每月维护 | 每月1日 03:00 | LanceDB 去重、结构审查 |

> 注意：当前 Light / REM / Deep phase 不是三条独立 cron，而是事件驱动写入链路。

---

## 🚀 使用方式

### 快速状态检查

> 用户说：「检查记忆系统状态」

操作步骤：
1. 扫描 `memory/` 目录，统计文件数、月度目录数
2. 检查 `DREAMS.md` 是否存在
3. 检查 `memory/dreaming/` 目录结构
4. 验证 INDEX.md 是否存在且内容匹配
5. 检查 `.working-memory/current-task.yaml` 是否有异常悬挂
6. 运行 `openclaw wiki doctor` 检查 Bridge 状态
7. 运行 `cron list` 检查定时任务状态
8. 输出健康摘要

### 搜索记忆

> 用户说：「搜索一下关于 xxx 的记忆」

两种方式：
1. **长期记忆搜索**：`memory_recall(query="xxx", category="decision", limit=5)`
2. **Dreaming 文件搜索**：`exec` → `Select-String -Path "memory\dreaming\**\*.md" -Pattern "xxx"`

优先方式1（向量检索更快），结果不足时补方式2（Dreaming 输出可能包含原始素材）。

### 检查 Dreaming 配置

> 用户说：「确认 dreaming 配置是否正确」

操作步骤：
1. 读取 `openclaw.json` 中的 `plugins.entries.memory-lancedb-pro.config.dreaming`
2. 验证 `enabled: true`
3. 识别 `frequency` 当前仅作为 dreaming 配置字段，真实已落地的调度主要是 gateway_start digest 和 memory-core promotion cron
4. 检查 Control UI / schema 是否识别 dreaming 支持
5. 运行 `openclaw wiki doctor` 或 `wiki_status` 确认 Bridge 正常

### 整理 Memory 目录

> 用户说：「帮我整理 memory 目录」

操作流程：
1. 读取 `MEMORY.md` 的 writeback_routing 规则
2. 扫描 memory 根目录下散落的 `*.md` 文件
3. 按日期特征（YYYY-MM-DD）匹配目标月度目录
4. 执行 `Move-Item` 移动文件到 `memory/YYYY-MM/`
5. 更新 `memory/INDEX.md`
6. 报告整理结果

### 健康检查

> 用户说：「运行记忆系统健康检查」

检查清单：
- [ ] `memory/INDEX.md` 是否存在且有效
- [ ] 月度目录命名是否规范（YYYY-MM）
- [ ] 重点/完整文件是否配对
- [ ] `DREAMS.md` 是否存在且有内容
- [ ] `memory/dreaming/` 目录结构是否完整
- [ ] Bridge 状态是否健康（当前运行态为 96 artifacts，允许随文件增减波动）
- [ ] Host events 日志是否存在
- [ ] `memory/CRON-JOBS.md` 是否与 cron 实际配置匹配
- [ ] `.working-memory/current-task.yaml` 是否异常
- [ ] 内置 memory_recall 工具是否可用
- [ ] 定时任务最近运行是否成功

---

## 📐 记忆系统架构速查

### 六层模型

```
Layer 0: Startup Entry     → MEMORY.md / AGENTS.md（启动必读）
Layer 1: Ledger Layer      → memory/*.md / memory/YYYY-MM/ / complete / highlights
Layer 2: Runtime Layer     → .working-memory/current-task.yaml
Layer 3: Archive Layer     → .working-memory/archive/*.yaml
Layer 4: Bridge Layer      → publicArtifacts / host events / dreaming output
Layer 5: Durable Layer     → LanceDB（decision / fact / entity / reflection）
```

### 写回路由

| 信息类型 | 写入目标 | 稳定性要求 |
|---------|---------|----------|
| 当天过程 | daily log / dreaming/light | 日级有效 |
| 反思归纳 | dreaming/rem | 模式识别 |
| 稳定决策 | LanceDB / decision / dreaming/deep | 跨会话有效 |
| 客观事实 | LanceDB / fact | 长期有效 |
| 实体信息 | LanceDB / entity | 长期有效 |

### 检索策略

- **简单任务**：直接 memory_recall
- **复杂任务**：current-task → episode-like → durable memory → context packet
- **Dreaming 输出**：memory/dreaming/**/*.md（按 phase 检索）

---

## ⚠️ 注意事项

1. **Dreaming 不替代 complete/highlights**
   - Dreaming 是实时增量流水
   - complete/highlights 是日终整理产物
   - 两者协调一致，避免冲突

2. **Bridge 模式要求**
   - 必须使用 `vaultMode: "bridge"`
   - 必须配置正确的 vault path
   - 定期运行 `openclaw wiki doctor` 检查

3. **不使用已废弃的 CLI**
   - `lancedb-query`（query.js 调用的 `openclaw memory search` 不存在）
   - `memory-manager`（bash 不兼容 Windows Server 2022）

4. **遵守 MEMORY.md 闭环规则**
   - 禁止自动 prompt 注入
   - 禁止把 bridge 层整包写入 LanceDB
   - 禁止创造第二套长期真相源

5. **Windows 路径规范**
   - 使用 `\` 或 `Get-ChildItem` 跨平台路径操作
   - 避免 Unix 风格路径

---

## 🔧 故障排查

### Dreaming 无输出

**症状**：`memory/dreaming/` 目录为空

**排查步骤**：
1. 检查 `openclaw.json` 中 `dreaming.enabled: true`
2. 运行 `openclaw wiki doctor` 确认插件加载成功
3. 检查日志中是否有 dreaming 相关错误
4. 区分“事件驱动无输出”与“独立 cron 未注册”，不要把 absence of phase cron 误判为故障

### Bridge 无 artifacts

**症状**：`openclaw wiki doctor` 显示 0 artifacts

**排查步骤**：
1. 确认 `memory-wiki` 插件启用
2. 确认 `vaultMode: "bridge"`
3. 确认 `MEMORY.md` 和 `DREAMS.md` 存在
4. 运行 `openclaw wiki doctor` 重新检查

### Host Events 未写入

**症状**：`memory/.openclaw/events.jsonl` 不存在或为空

**排查步骤**：
1. 确认 `memory_promote` 或 `memory_recall` 被调用
2. 检查 `index.ts` 中 `hostEventWriter` 是否正确初始化
3. 查看日志中是否有 event 写入错误

---

## 🔗 相关文档

- [MEMORY.md](../../workspace/MEMORY.md) — 记忆系统中枢
- [DREAMS.md](../../workspace/DREAMS.md) — Dreaming 输出汇总
- [memory/CRON-JOBS.md](../../workspace/memory/CRON-JOBS.md) — 定时任务配置
- [memory/README.md](../../workspace/memory/README.md) — 完整技术说明
- [技术文档 v1.2.2](../../workspace/docs/memory-lancedb-pro-technical-documentation-v1.2.2.md)
- [memory-capability-runtime-contract-2026-04-19](../../workspace/docs/memory-capability-runtime-contract-2026-04-19.md)
- [dreaming-phase-markdown-contract-2026-04-19](../../workspace/docs/dreaming-phase-markdown-contract-2026-04-19.md)
- [Dreaming 集成计划](../../workspace/docs/memory-lancedb-pro-dreaming-integration-plan-2026-04-19.md)
- [格式协调方案](../../workspace/docs/dreaming-memory-format-coordination-2026-04-19.md)
