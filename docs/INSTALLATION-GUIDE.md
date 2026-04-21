# OpenClaw Memory Suite 完整安装指南

> **版本**: v1.1.0  
> **更新日期**: 2026-04-22  
> **适用对象**: AI Agent 管理员 / 新 Agent 快速部署  
> **维护者**: 小千 (canxia-hub)

---

## 1. 当前推荐版本

| 组件 | 推荐版本 | 说明 |
|------|----------|------|
| `memory-lancedb-pro` | `v1.3.2` | 最新稳定插件，已完成 true three-phase Dreaming |
| `openclaw-memory-suite` | `v1.1.0` | 文档与示例已同步到 v1.3.2 |

---

## 2. 安装顺序

```text
先安装插件源码
→ 再安装 npm 依赖
→ 再复制技能
→ 再修改 openclaw.json
→ 先 doctor 验证
→ 最后 restart gateway
```

不要跳过 `doctor`。

---

## 3. 安装插件源码

```bash
cd ~/.openclaw/extensions
git clone https://github.com/canxia-hub/memory-lancedb-pro.git
cd memory-lancedb-pro
git checkout v1.3.2
npm install
```

---

## 4. 安装 Memory Suite

```bash
cd ~/.openclaw/skills
git clone https://github.com/canxia-hub/openclaw-memory-suite.git memory-suite
cd memory-suite
git checkout v1.1.0
```

复制以下目录到全局技能库：

- `components/lancedb-pro-skill` → `lancedb-pro`
- `components/graphify-openclaw` → `graphify-openclaw`
- `components/self-improvement` → `self-improving-agent`

---

## 5. Dreaming 配置方法

### 5.1 最小配置

直接参考：

- `../examples/basic-config.json5`

示意：

```json5
{
  "plugins": {
    "entries": {
      "memory-lancedb-pro": {
        "enabled": true,
        "config": {
          "embedding": {
            "provider": "openai-compatible",
            "model": "text-embedding-3-small",
            "apiKey": "${OPENAI_API_KEY}"
          },
          "dreaming": {
            "enabled": true,
            "timezone": "Asia/Shanghai"
          }
        }
      }
    }
  }
}
```

### 5.2 完整配置

直接参考：

- `../examples/full-config.json5`

重点字段：

- `dreaming.enabled`
- `dreaming.frequency`
- `dreaming.timezone`
- `dreaming.phases.light.cron`
- `dreaming.phases.deep.cron`
- `dreaming.phases.rem.cron`

---

## 6. 当前真实 Dreaming 行为

当前 Dreaming 已是 **true three-phase**：

- `Memory Dreaming Light`
- `Memory Dreaming Promotion`
- `Memory Dreaming REM`

其中 Deep phase 继续复用官方 memory-core promotion identity，目的是让：

- Control UI
- `doctor.memory.status`

继续识别主晋升链路。

---

## 7. 验证步骤

修改配置后：

```bash
openclaw doctor --non-interactive
openclaw gateway restart
openclaw doctor --non-interactive
```

至少确认：

- 插件加载成功
- Dreaming 配置已生效
- cron 列表出现三条任务
- Control UI 的 Dreaming 状态正常

---

## 8. 常见错误

### 错误 1
先改配置，再装插件。

### 错误 2
不做 `doctor`，直接重启。

### 错误 3
沿用旧文档，把系统理解成“只有一个 Dreaming promotion 任务”。

---

## 9. 相关文档

- `../README.md`
- `../README_AGENT.md`
- `./CRON-JOBS.md`
- `../examples/basic-config.json5`
- `../examples/full-config.json5`
