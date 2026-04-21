# OpenClaw Memory Suite — Agent Installation Guide

> **Target Audience**: AI Agents / Maintainers  
> **Last Updated**: 2026-04-22  
> **Suite Version**: 1.1.0  
> **Plugin Target**: `memory-lancedb-pro v1.3.2`

---

## 1. 安装目标

这份指南只做三件事：

1. 安装最新版 `memory-lancedb-pro`
2. 安装配套 skills
3. 用**当前正确的 Dreaming 配置方法**完成验证

---

## 2. 正确顺序

```text
先安装插件源码
→ 再安装依赖
→ 再复制技能
→ 再修改 openclaw.json
→ 先 doctor 验证
→ 最后 restart gateway
```

不要反过来。

---

## 3. 安装插件

```bash
cd ~/.openclaw/extensions
git clone https://github.com/canxia-hub/memory-lancedb-pro.git
cd memory-lancedb-pro
git checkout v1.3.2
npm install
```

---

## 4. 安装本套件

```bash
cd ~/.openclaw/skills
git clone https://github.com/canxia-hub/openclaw-memory-suite.git memory-suite
cd memory-suite
git checkout v1.1.0
```

把以下目录复制到全局技能目录：

- `components/lancedb-pro-skill` → `lancedb-pro`
- `components/graphify-openclaw` → `graphify-openclaw`
- `components/self-improvement` → `self-improving-agent`

> Windows 可用 `Copy-Item -Recurse`，Unix-like 可用 `cp -r`。

---

## 5. 选择配置模板

### 最小配置

直接参考：

- `examples/basic-config.json5`

适合首次接入，先确认插件能加载、Dreaming 能启用。

### 完整配置

直接参考：

- `examples/full-config.json5`

适合生产环境，需要：

- management tools
- 完整 Dreaming 三阶段配置
- memory-wiki bridge

---

## 6. 当前 Dreaming 配置方法

当前正确口径是：

- `dreaming.enabled = true`
- 显式设置 `timezone`
- 按需设置 `phases.light / phases.deep / phases.rem`
- `deep.cron` 可单独设置，也会兼容 `frequency`

推荐示例：

```json5
{
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
```

---

## 7. 当前运行时行为

Dreaming 启用后，会对齐三条 managed cron：

- `Memory Dreaming Light`
- `Memory Dreaming Promotion`
- `Memory Dreaming REM`

其中：

- **Deep / Promotion** 继续复用官方 memory-core promotion identity
- 这是为了让 Control UI 和 `doctor.memory.status` 继续识别主晋升链路

---

## 8. 验证步骤

修改配置后：

```bash
openclaw doctor --non-interactive
openclaw gateway restart
openclaw doctor --non-interactive
```

至少确认：

- 插件成功加载
- Dreaming 配置通过校验
- cron 列表出现 Light / Promotion / REM
- Control UI 的 Dreaming 状态正常

---

## 9. 常见误区

### 误区 1
只设置 `dreaming.frequency`，却把系统理解成“只有一个 Dreaming 任务”。

### 误区 2
沿用旧文档，把 `Memory LanceDB Dreaming Promotion` 当成当前任务名。

### 误区 3
不先 `doctor` 就直接 `gateway restart`。

---

## 10. 相关文档

- `README.md`
- `docs/CRON-JOBS.md`
- `examples/basic-config.json5`
- `examples/full-config.json5`
