# 📢 OpenClaw Memory Suite — v1.1.0 Update

> **Date**: 2026-04-22  
> **Version**: 1.1.0  
> **Status**: Production Ready

---

## 本次更新重点

这次更新的目标很明确：

- 把 `memory-lancedb-pro` 的最新稳定版本同步到套件文档
- 把 Dreaming 的**当前正确配置方法**写清楚
- 清掉旧的“单一 Dreaming promotion cron”口径

---

## 当前推荐组合

- `memory-lancedb-pro`: **v1.3.2**
- `openclaw-memory-suite`: **v1.1.0**

---

## 关键变化

### 1. true three-phase Dreaming

当前 Dreaming 已是三相位独立调度：

- `Memory Dreaming Light`
- `Memory Dreaming Promotion`
- `Memory Dreaming REM`

而不是旧的单一 promotion 任务伪装成三相位。

### 2. Deep phase 与官方 UI 契约保持兼容

Deep phase 继续使用官方 memory-core promotion identity，目的是让：

- Control UI
- `doctor.memory.status`

继续正确识别主 promotion 状态。

### 3. 配置方法同步更新

仓库现在同时提供：

- 最小配置示例
- 完整 Dreaming 配置示例
- 最新 cron 口径说明
- 面向 Agent 的安装验证指南

---

## 你现在应该看哪里

- `README.md` — 项目总入口
- `README_AGENT.md` — 安装和验证步骤
- `docs/CRON-JOBS.md` — 当前 Dreaming / cron 真实口径
- `examples/basic-config.json5`
- `examples/full-config.json5`

---

## 升级建议

如果你正在从旧文档或旧部署方式迁移：

1. 先更新插件到 `v1.3.2`
2. 再按新示例核对 `dreaming` 配置
3. 先运行 `openclaw doctor --non-interactive`
4. 最后再重启 gateway

---

## 仓库链接

- Suite: https://github.com/canxia-hub/openclaw-memory-suite
- Plugin: https://github.com/canxia-hub/memory-lancedb-pro
