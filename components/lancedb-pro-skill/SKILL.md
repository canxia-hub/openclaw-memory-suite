---
name: lancedb-pro
description: >
  记忆系统统一维护技能。整合 LanceDB 长期记忆检索、Dreaming 三阶段、Memory 文件系统管理、Bridge 互操作与健康检查。
  当用户要求查看记忆、搜索记忆、检查 Dreaming、核对 cron、整理 memory、检查 bridge 状态时使用。
version: "1.3.2"
license: MIT
metadata:
  author: 小千 (Xiao Qian)
  category: memory-system
  replaces: ["lancedb-query", "memory-manager"]
  tags: memory lancedb recall dreaming bridge health-check cron wiki
---

# lancedb-pro — 记忆系统统一维护技能

> 适配 `memory-lancedb-pro v1.3.2`

## 当前关键口径

### 1. Dreaming 已是 true three-phase

当前推荐运行态下，Dreaming 会对齐三条 managed cron：

- `Memory Dreaming Light`
- `Memory Dreaming Promotion`
- `Memory Dreaming REM`

不要再按旧文档把它理解成“单一 promotion cron + UI 投影三相位”。

### 2. Deep phase 的身份兼容是刻意设计

Deep phase 继续复用官方 memory-core promotion identity，目的是让：

- Control UI
- `doctor.memory.status`

继续识别主晋升链路。

### 3. 配置方式

最少要确认：

- `dreaming.enabled = true`
- `dreaming.timezone` 已设置
- `phases.light / deep / rem` 按需配置
- 改完配置先 `openclaw doctor --non-interactive`，再重启 gateway

---

## 推荐检查流程

### A. 检查记忆系统状态

1. 看插件是否已加载
2. 看 Dreaming 是否启用
3. 看三条 cron 是否存在
4. 看 `memory/dreaming/` 三个 phase 输出目录是否正常
5. 看 wiki bridge 是否正常

### B. 检查 Dreaming 配置

关注：

- `dreaming.enabled`
- `dreaming.frequency`
- `dreaming.timezone`
- `dreaming.phases.light.cron`
- `dreaming.phases.deep.cron`
- `dreaming.phases.rem.cron`

### C. 检查输出

重点路径：

- `memory/dreaming/light/`
- `memory/dreaming/deep/`
- `memory/dreaming/rem/`
- `memory/YYYY-MM/*-complete.md`
- `memory/YYYY-MM/*-highlights.md`

---

## 推荐验证命令

```bash
openclaw doctor --non-interactive
openclaw gateway restart
openclaw cron list
```

如果运行时暴露 `memory_*` 工具，则优先用它们做检索与治理；
如果当前 runtime 没有直接暴露，则改用宿主已启用的管理入口，不要凭空假设工具一定存在。

---

## 常见任务

### 用户说：检查记忆系统状态

应检查：

- 插件加载状态
- Dreaming 配置
- cron 状态
- bridge 状态
- 近期 dreaming 输出

### 用户说：确认 dreaming 配置是否正确

应检查：

- config 是否完整
- doctor 是否通过
- Deep 是否与官方 promotion identity 保持兼容
- cron 是否已 reconcile 成 Light / Promotion / REM 三条

### 用户说：查看最近的 dreaming 输出

应读取：

- 当天或最近一天的 `light/rem/deep` phase 文件
- 如有必要，再回看 `complete/highlights`

---

## 不要再沿用的旧判断

- “Light / REM 只是 schema 能力，不会独立调度”
- “当前只有单一 Dreaming promotion 任务”
- “只看 `frequency` 就能完整判断 Dreaming 配置”
