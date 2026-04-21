# ⏰ Memory Suite Cron & Dreaming Contract

> **Version**: 5.0.0  
> **Updated**: 2026-04-22

本文档记录的是 **当前推荐口径**，用于说明 memory suite 在最新版 `memory-lancedb-pro v1.3.2` 下的 Dreaming 调度方式。

---

## 1. 当前真实模型

当前 Dreaming 不是旧的“单一 promotion 任务 + UI 投影三相位”。

当前模型是：

- **Light**: 独立 managed cron
- **Deep / Promotion**: 独立 managed cron
- **REM**: 独立 managed cron

也就是 **true three-phase**。

---

## 2. 三条 managed cron

| Phase | Cron Name | Default Schedule | Purpose |
|------|-----------|------------------|---------|
| Light | `Memory Dreaming Light` | `0 */6 * * *` | 整理近期短期材料 |
| Deep | `Memory Dreaming Promotion` | `0 3 * * *` | 评估并推动 durable promotion |
| REM | `Memory Dreaming REM` | `0 5 * * 0` | 提炼模式与反思 |

---

## 3. 特别说明：Deep phase 的兼容身份

Deep phase 当前仍复用官方 memory-core promotion identity。

这样做的目的：

- 让 Control UI 继续识别主晋升任务
- 让 `doctor.memory.status.dreaming` 的聚合口径保持兼容

所以不要把这理解为“memory-core 接管了整个 Dreaming”。
它只是 **Deep phase 沿用了官方身份**，而 Light / REM 仍由插件自己管理。

---

## 4. 推荐配置方法

```json5
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
            "phases": {
              "light": {
                "enabled": true,
                "cron": "0 */6 * * *"
              },
              "deep": {
                "enabled": true,
                "cron": "0 3 * * *",
                "minScore": 0.8,
                "minRecallCount": 3,
                "minUniqueQueries": 3
              },
              "rem": {
                "enabled": true,
                "cron": "0 5 * * 0"
              }
            }
          }
        }
      }
    }
  }
}
```

说明：

- `frequency` 现在主要作为 Deep 的默认 fallback
- 若显式设置 `phases.deep.cron`，则以 phase 配置优先
- Light / REM 推荐显式写出各自 cron

---

## 5. 输出文件

Dreaming 常见输出：

- `memory/dreaming/light/YYYY-MM-DD.md`
- `memory/dreaming/deep/YYYY-MM-DD.md`
- `memory/dreaming/rem/YYYY-MM-DD.md`
- `memory/YYYY-MM/YYYY-MM-DD-complete.md`
- `memory/YYYY-MM/YYYY-MM-DD-highlights.md`

---

## 6. 推荐验证步骤

```bash
openclaw doctor --non-interactive
openclaw gateway restart
openclaw doctor --non-interactive
```

然后确认：

- Dreaming 已启用
- cron 列表里有三条任务
- Control UI 状态正常

---

## 7. 需要避免的旧口径

以下说法已经过时：

- “只有一个 `Memory LanceDB Dreaming Promotion` 任务”
- “Light / REM 只是 schema 能力，不会独立调度”
- “当前实现本质还是 single sweep”

这些都不再代表 `v1.3.2` 的最新状态。
