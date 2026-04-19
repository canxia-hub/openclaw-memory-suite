# ⏰ 记忆系统定时任务配置清单

> **版本**: 4.1.0  
> **创建时间**: 2026-03-23  
> **最后更新**: 2026-04-19 22:52  
> **核心原则**: 不引入第二套系统；所有定时任务都必须围绕"主账本 + Working Memory + LanceDB 桥接增强"闭环运行

---

## 📋 定时任务总览

| 任务名称 | 执行时间 | 频率 | 来源 | 核心职责 |
|---------|---------|------|------|----------|
| Dreaming Light Output | 会话结束时 | 事件驱动 | 插件运行时 | 写入会话摘要到 light phase |
| Dreaming REM Output | 反思生成时 | 事件驱动 | 插件运行时 | 写入反思结果到 rem phase |
| Dreaming Deep Output | promotion 发生时 | 事件驱动 | 插件运行时 | 写入 durable promotion 到 deep phase |
| Memory Dreaming Promotion | 03:00 | 每日 | memory-core cron | 触发短期记忆晋升，间接喂给 deep phase |
| Daily Digest | Gateway 启动时 | 触发式 | 插件代码 | 从 phase 生成 complete/highlights |
| 记忆系统每日健康检查 | 03:00 | 每日 | 宿主级 cron | 健康检查 + Dreaming 链路验证（归档整理已移交 dreaming daily digest） |
| 记忆系统每周归档 | 周一 03:30 | 每周 | 宿主级 | 周归档、候选层巡检 |
| 记忆系统每月维护 | 每月 1 日 03:00 | 每月 | 宿主级 | LanceDB 去重、系统漂移检查 |
| Self-Growth Daily Diary | 03:00 | 每日 | cron 任务 | 自我成长日记 |
| Self-Evolution Daily | 03:00 | 每日 | cron 任务 | 自我进化分析 |

---

## 🌙 Dreaming 配置（插件级）

### 当前真实实现

#### Light Phase
- **触发**: 会话摘要落盘时（事件驱动）
- **来源**: `session-memory` / 会话摘要写入链路
- **输出**: `memory/dreaming/light/YYYY-MM-DD.md`
- **注意**: 不是独立 cron；`openclaw.plugin.json` 中的 `phases.light.cron` 目前仅是 schema 能力，尚未真正调度

#### Deep Phase
- **触发**: `memory_promote` 或 memory-core 的短期晋升任务触发 promotion 时
- **来源**: `tools.ts` → `memory_promote` → `dreamingInterop.recordDeepPromotion()`
- **输出**: `memory/dreaming/deep/YYYY-MM-DD.md`
- **条件**: 仅 `state=confirmed` 且 `layer=durable` 的 promotion 才进入
- **补充**: 当前每日 03:00 的真实调度来自 `Memory Dreaming Promotion` cron，而不是插件自行注册 deep phase cron

#### REM Phase
- **触发**: reflection 文件生成时（事件驱动）
- **来源**: reflection 写回链路
- **输出**: `memory/dreaming/rem/YYYY-MM-DD.md`
- **注意**: 不是独立 cron；schema 中的 `phases.rem.cron` 当前未实际调度

### 配置现实
- `openclaw.json` 当前只显式配置了 `dreaming.enabled / frequency / verboseLogging`
- `storage / execution / phases.*` 主要依赖 schema 默认值与解析能力
- 若要把 `phases.light/deep/rem.cron` 变成真实调度，需要后续在插件中补注册逻辑

---

## 📝 Daily Digest（触发式）

### 触发条件
- Gateway 启动时（`gateway_start` event）
- 条件: `config.dreaming?.enabled === true`

### 输入
- `memory/dreaming/light/YYYY-MM-DD.md`
- `memory/dreaming/rem/YYYY-MM-DD.md`
- `memory/dreaming/deep/YYYY-MM-DD.md`

### 输出
- `memory/YYYY-MM/YYYY-MM-DD-complete.md`：完整记录，从 light phase 会话整理生成
- `memory/YYYY-MM/YYYY-MM-DD-highlights.md`：重点摘要，从 light/rem/deep 三类 phase 提炼生成

### 职责边界（v5.0 起）
- **Daily Digest 负责**：从 dreaming phase 自动生成 complete/highlights
- **每日健康检查负责**：验证 dreaming 链路是否正常、检查索引完整性、巡检 bridge 层
- **不再重复生成**：健康检查任务不再手动生成 complete/highlights，避免与 digest 冲突

---

## 🔧 插件级 vs 宿主级任务

### 插件级任务（memory-lancedb-pro）
- **Dreaming Phases**: Light / Deep / REM（事件驱动）
- **Daily Digest**: phase → complete/highlights（gateway_start 触发）
- **配置位置**: `openclaw.json` → `plugins.entries.memory-lancedb-pro.config.dreaming`

### 宿主级任务
- **每日健康检查**: 验证 dreaming 链路 + 索引完整性 + bridge 巡检
- **每周归档**: 周归档、候选层巡检
- **每月维护**: LanceDB 去重、系统漂移检查

---

## 📝 文档说明

> **重要**: 本文档仅为任务配置清单，不是声明式配置源。实际任务调度由以下配置控制：
> - `openclaw.json` 中的 `plugins.entries.memory-lancedb-pro.config.dreaming`
> - OpenClaw 宿主的 cron 配置
> - `openclaw cron` 命令管理的定时任务

---

## 🔄 变更历史

| 版本 | 日期 | 变更内容 |
|------|------|----------|
| 5.0.0 | 2026-04-20 | 每日健康检查任务职责调整：归档整理移交 dreaming daily digest，新增 dreaming 链路验证 |
| 4.1.0 | 2026-04-19 | 修正 Dreaming 为事件驱动 + memory-core promotion 混合链路，标明当前真实 cron 拓扑 |
| 4.0.0 | 2026-04-19 | 新增 Dreaming Phases、Daily Digest、区分插件级/宿主级任务 |
| 3.0.0 | 2026-03-23 | 初始版本，四大任务 |
