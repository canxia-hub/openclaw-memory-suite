# OpenClaw Memory Suite 完整安装指南

> **版本**: v1.0.0  
> **更新日期**: 2026-04-20  
> **适用对象**: AI Agent 管理员 / 新 Agent 快速部署  
> **维护者**: 小千 (canxia-hub)

---

## 📋 目录

1. [概述](#概述)
2. [前置要求](#前置要求)
3. [安装顺序（重要）](#安装顺序重要)
4. [详细安装步骤](#详细安装步骤)
5. [配置规范](#配置规范)
6. [重启网关规范](#重启网关规范)
7. [验证安装](#验证安装)
8. [常见问题与解决方案](#常见问题与解决方案)
9. [卸载与回滚](#卸载与回滚)

---

## 概述

OpenClaw Memory Suite 是一套完整的 AI Agent 长期记忆解决方案，包含以下组件：

| 组件 | 类型 | 版本 | 优先级 | 说明 |
|------|------|------|--------|------|
| **memory-lancedb-pro** | Plugin | v1.3.1 | Critical | LanceDB 增强型记忆插件（核心） |
| **lancedb-pro-skill** | Skill | v1.0.0 | High | 记忆系统部署与维护技能 |
| **graphify-openclaw** | Skill | v1.0.0 | High | Wiki 知识图谱构建技能 |
| **self-improvement** | Skill | v1.0.0 | Medium | 自我改进与学习系统 |

**关键架构**：

```
┌─────────────────────────────────────────────────────────┐
│                    OpenClaw Memory Suite                 │
├─────────────────────────────────────────────────────────┤
│  memory-lancedb-pro (Plugin)                            │
│    ↓ LanceDB 向量存储 + Hybrid Retrieval + Dreaming     │
│                                                          │
│  graphify-openclaw (Wiki Skill)                         │
│    ↓ Bridge Mode + Knowledge Graph + Semantic Search   │
│                                                          │
│  self-improvement (Learning Skill)                      │
│    ↓ Experience Capture + Skill Extraction + Evolution  │
└─────────────────────────────────────────────────────────┘
```

---

## 前置要求

### 必需环境

| 依赖 | 版本要求 | 检查命令 | 说明 |
|------|----------|----------|------|
| **OpenClaw** | >= 2026.4.14 | `openclaw --version` | 核心运行时 |
| **Node.js** | >= 18.0.0 | `node --version` | 插件运行环境 |
| **npm** | >= 9.0.0 | `npm --version` | 包管理器 |
| **Git** | >= 2.30.0 | `git --version` | 源码管理 |

### 推荐配置

| 配置项 | 推荐值 | 说明 |
|--------|--------|------|
| 内存 | >= 4GB | LanceDB 向量索引缓存 |
| 磁盘空间 | >= 2GB | 记忆数据库 + Wiki 存储 |
| CPU | >= 2 核 | 并行检索与 Rerank |

### 网络要求

- **Embedding API**: OpenAI / DashScope / Jina / Ollama 等
- **Rerank API** (可选): Jina / SiliconFlow / Voyage 等

---

## 安装顺序（重要）

⚠️ **关键警告**：必须严格按照以下顺序安装，否则会导致配置错误和网关无法启动！

### 正确顺序

```
Step 1: 安装插件源码 (memory-lancedb-pro)
   ↓
Step 2: 安装依赖 (npm install)
   ↓
Step 3: 安装技能 (lancedb-pro-skill, graphify-openclaw, self-improvement)
   ↓
Step 4: 配置 openclaw.json
   ↓
Step 5: 验证配置语法 (openclaw doctor)
   ↓
Step 6: 重启网关 (openclaw gateway restart)
   ↓
Step 7: 验证安装 (openclaw doctor --non-interactive)
```

### 错误示范

❌ **错误 1**: 先修改配置文件，再安装插件
   - 结果: 网关无法启动，报错 "plugin not found"

❌ **错误 2**: 配置文件语法错误后直接重启
   - 结果: 网关崩溃，需要手动回滚配置

❌ **错误 3**: 只配置插件，不配置 embedding
   - 结果: 插件加载成功，但记忆功能无法使用

---

## 详细安装步骤

### Step 1: 安装插件源码

```bash
# 1.1 进入 OpenClaw 插件目录
cd ~/.openclaw/extensions

# 1.2 克隆插件仓库（使用最新版本）
git clone -b master \
  https://github.com/canxia-hub/memory-lancedb-pro.git

# 1.3 进入插件目录
cd memory-lancedb-pro

# 1.4 验证源码完整性
ls -la
# 应该看到: package.json, index.ts, src/, skills/, 等
```

### Step 2: 安装依赖

```bash
# 2.1 安装 Node.js 依赖
npm install

# 2.2 验证依赖安装成功
ls node_modules/@lancedb/lancedb
# 应该看到 LanceDB 原生二进制文件

# 2.3 (可选) 运行测试
npm test
```

### Step 3: 安装技能

```bash
# 3.1 进入 OpenClaw 技能目录
cd ~/.openclaw/skills

# 3.2 克隆 Memory Suite 仓库
git clone https://github.com/canxia-hub/openclaw-memory-suite.git memory-suite

# 3.3 复制技能到全局技能库
# 3.3.1 复制 lancedb-pro-skill
cp -r memory-suite/components/lancedb-pro-skill ./lancedb-pro

# 3.3.2 复制 graphify-openclaw (如果未安装)
if [ ! -d "graphify-openclaw" ]; then
  cp -r memory-suite/components/graphify-openclaw ./graphify-openclaw
fi

# 3.3.3 复制 self-improvement (如果未安装)
if [ ! -d "self-improving-agent" ]; then
  cp -r memory-suite/components/self-improvement ./self-improving-agent
fi

# 3.4 验证技能目录结构
ls -la lancedb-pro/graphify-openclaw/self-improving-agent
```

### Step 4: 配置 openclaw.json

⚠️ **重要**: 在修改配置前，先备份当前配置！

```bash
# 4.1 备份当前配置
cp ~/.openclaw/openclaw.json ~/.openclaw/openclaw.json.backup

# 4.2 编辑配置文件
# 使用文本编辑器打开 ~/.openclaw/openclaw.json
```

#### 4.3 最小配置（推荐首次安装使用）

```json
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
          }
        }
      }
    }
  }
}
```

#### 4.4 完整配置（生产环境）

```json
{
  "plugins": {
    "entries": {
      "memory-lancedb-pro": {
        "enabled": true,
        "config": {
          "embedding": {
            "provider": "openai-compatible",
            "model": "qwen3-vl-embedding",
            "dimensions": 2560,
            "apiKey": "${DASHSCOPE_API_KEY}",
            "baseURL": "https://dashscope.aliyuncs.com/compatible-mode/v1"
          },
          "dbPath": "~/.openclaw/memory/lancedb-pro",
          "autoCapture": true,
          "autoRecall": false,
          "smartExtraction": true,
          "enableManagementTools": true,
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
          },
          "retrieval": {
            "mode": "hybrid",
            "rerank": "cross-encoder",
            "rerankApiKey": "${JINA_API_KEY}",
            "rerankModel": "jina-reranker-v3",
            "rerankEndpoint": "https://api.jina.ai/v1/rerank"
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

### Step 5: 验证配置语法

⚠️ **关键步骤**: 在重启网关前，必须验证配置语法！

```bash
# 5.1 验证配置语法
openclaw doctor

# 5.2 如果看到错误，检查以下几点：
# - JSON 语法是否正确（逗号、括号、引号）
# - 所有必需字段是否配置（embedding.apiKey）
# - 插件是否已安装（~/.openclaw/extensions/memory-lancedb-pro）

# 5.3 如果验证失败，回滚配置
cp ~/.openclaw/openclaw.json.backup ~/.openclaw/openclaw.json
```

### Step 6: 重启网关

⚠️ **重要**: 使用正确的重启命令！

```bash
# 6.1 安全重启（推荐）
openclaw gateway restart

# 6.2 等待网关重启完成（约 10-30 秒）
# 观察输出，确保没有错误

# 6.3 如果网关启动失败，检查日志
openclaw gateway logs --tail 50

# 6.4 如果需要回滚，恢复备份配置
cp ~/.openclaw/openclaw.json.backup ~/.openclaw/openclaw.json
openclaw gateway restart
```

### Step 7: 验证安装

```bash
# 7.1 运行完整验证
openclaw doctor --non-interactive

# 7.2 检查插件是否加载
openclaw status | grep memory-lancedb-pro

# 7.3 测试记忆功能
# 在 OpenClaw 对话中输入：
# "/remember 这是一个测试记忆"

# 7.4 测试检索功能
# 在 OpenClaw 对话中输入：
# "我之前说了什么测试记忆？"
```

---

## 配置规范

### Embedding 配置

#### OpenAI

```json
{
  "embedding": {
    "provider": "openai-compatible",
    "model": "text-embedding-3-small",
    "dimensions": 1536,
    "apiKey": "${OPENAI_API_KEY}",
    "baseURL": "https://api.openai.com/v1"
  }
}
```

#### DashScope (阿里云)

```json
{
  "embedding": {
    "provider": "openai-compatible",
    "model": "qwen3-vl-embedding",
    "dimensions": 2560,
    "apiKey": "${DASHSCOPE_API_KEY}",
    "baseURL": "https://dashscope.aliyuncs.com/compatible-mode/v1"
  }
}
```

#### Jina AI

```json
{
  "embedding": {
    "provider": "openai-compatible",
    "model": "jina-embeddings-v3",
    "dimensions": 1024,
    "apiKey": "${JINA_API_KEY}",
    "baseURL": "https://api.jina.ai/v1",
    "taskQuery": "retrieval.query",
    "taskPassage": "retrieval.passage"
  }
}
```

#### Ollama (本地)

```json
{
  "embedding": {
    "provider": "openai-compatible",
    "model": "nomic-embed-text",
    "baseURL": "http://localhost:11434/v1",
    "apiKey": "dummy"
  }
}
```

### Rerank 配置

#### Jina Reranker

```json
{
  "retrieval": {
    "rerank": "cross-encoder",
    "rerankApiKey": "${JINA_API_KEY}",
    "rerankModel": "jina-reranker-v3",
    "rerankEndpoint": "https://api.jina.ai/v1/rerank",
    "rerankProvider": "jina"
  }
}
```

#### SiliconFlow

```json
{
  "retrieval": {
    "rerank": "cross-encoder",
    "rerankApiKey": "${SILICONFLOW_API_KEY}",
    "rerankModel": "BAAI/bge-reranker-v2-m3",
    "rerankEndpoint": "https://api.siliconflow.cn/v1/rerank",
    "rerankProvider": "siliconflow"
  }
}
```

### Dreaming 配置

#### 基础配置

```json
{
  "dreaming": {
    "enabled": true,
    "frequency": "0 3 * * *",
    "timezone": "Asia/Shanghai",
    "verboseLogging": false
  }
}
```

#### 三阶段配置

```json
{
  "dreaming": {
    "enabled": true,
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
```

---

## 重启网关规范

### 何时需要重启

| 场景 | 是否需要重启 | 说明 |
|------|--------------|------|
| 安装新插件 | ✅ 是 | 插件在网关启动时加载 |
| 修改插件配置 | ✅ 是 | 配置在网关启动时读取 |
| 安装新技能 | ❌ 否 | 技能按需加载 |
| 修改环境变量 | ✅ 是 | 环境变量在网关启动时读取 |
| 升级 OpenClaw | ✅ 是 | 核心运行时更新 |

### 重启前检查清单

```bash
# 1. 备份当前配置
cp ~/.openclaw/openclaw.json ~/.openclaw/openclaw.json.backup

# 2. 验证配置语法
openclaw doctor

# 3. 检查插件是否已安装
ls ~/.openclaw/extensions/memory-lancedb-pro/package.json

# 4. 检查依赖是否安装
ls ~/.openclaw/extensions/memory-lancedb-pro/node_modules/@lancedb/lancedb
```

### 重启命令

```bash
# 标准重启
openclaw gateway restart

# 带延迟重启（给网关时间清理资源）
openclaw gateway restart --delay 5000

# 强制重启（不推荐，可能丢失数据）
openclaw gateway stop
sleep 5
openclaw gateway start
```

### 重启后验证

```bash
# 1. 检查网关状态
openclaw status

# 2. 检查插件是否加载
openclaw status | grep memory-lancedb-pro

# 3. 检查日志是否有错误
openclaw gateway logs --tail 20

# 4. 测试记忆功能
# 在对话中输入测试命令
```

---

## 验证安装

### 自动验证脚本

```bash
#!/bin/bash
# verify-memory-suite.sh

echo "=== OpenClaw Memory Suite 验证脚本 ==="

# 1. 检查插件目录
echo "[1/7] 检查插件目录..."
if [ -d ~/.openclaw/extensions/memory-lancedb-pro ]; then
  echo "✅ 插件目录存在"
else
  echo "❌ 插件目录不存在"
  exit 1
fi

# 2. 检查 package.json
echo "[2/7] 检查 package.json..."
if [ -f ~/.openclaw/extensions/memory-lancedb-pro/package.json ]; then
  VERSION=$(cat ~/.openclaw/extensions/memory-lancedb-pro/package.json | grep '"version"' | cut -d'"' -f4)
  echo "✅ 插件版本: $VERSION"
else
  echo "❌ package.json 不存在"
  exit 1
fi

# 3. 检查依赖
echo "[3/7] 检查依赖..."
if [ -d ~/.openclaw/extensions/memory-lancedb-pro/node_modules/@lancedb/lancedb ]; then
  echo "✅ LanceDB 依赖已安装"
else
  echo "❌ LanceDB 依赖未安装"
  echo "   运行: cd ~/.openclaw/extensions/memory-lancedb-pro && npm install"
  exit 1
fi

# 4. 检查技能
echo "[4/7] 检查技能..."
SKILLS=("lancedb-pro" "graphify-openclaw" "self-improving-agent")
for SKILL in "${SKILLS[@]}"; do
  if [ -d ~/.openclaw/skills/$SKILL ]; then
    echo "✅ 技能 $SKILL 已安装"
  else
    echo "⚠️  技能 $SKILL 未安装（可选）"
  fi
done

# 5. 检查配置
echo "[5/7] 检查配置..."
if openclaw doctor --non-interactive 2>&1 | grep -q "OK"; then
  echo "✅ 配置语法正确"
else
  echo "❌ 配置语法错误"
  openclaw doctor
  exit 1
fi

# 6. 检查网关状态
echo "[6/7] 检查网关状态..."
if openclaw status | grep -q "running"; then
  echo "✅ 网关运行中"
else
  echo "❌ 网关未运行"
  exit 1
fi

# 7. 检查插件状态
echo "[7/7] 检查插件状态..."
if openclaw status | grep -q "memory-lancedb-pro"; then
  echo "✅ 插件已加载"
else
  echo "❌ 插件未加载"
  exit 1
fi

echo ""
echo "=== 验证完成 ==="
echo "所有检查通过，Memory Suite 已成功安装！"
```

### 手动验证步骤

```bash
# 1. 检查插件版本
cat ~/.openclaw/extensions/memory-lancedb-pro/package.json | grep '"version"'

# 2. 检查配置
openclaw doctor

# 3. 检查网关状态
openclaw status

# 4. 测试记忆存储
# 在对话中输入: "/remember 这是一条测试记忆"

# 5. 测试记忆检索
# 在对话中输入: "我刚才存了什么记忆？"

# 6. 检查数据库
ls ~/.openclaw/memory/lancedb-pro
```

---

## 常见问题与解决方案

### 问题 1: 网关无法启动

**症状**:
```
Error: Cannot find module 'memory-lancedb-pro'
```

**原因**: 插件未安装或路径错误

**解决方案**:
```bash
# 1. 检查插件目录
ls ~/.openclaw/extensions/memory-lancedb-pro

# 2. 如果不存在，重新安装
cd ~/.openclaw/extensions
git clone https://github.com/canxia-hub/memory-lancedb-pro.git
cd memory-lancedb-pro
npm install

# 3. 重启网关
openclaw gateway restart
```

### 问题 2: 配置语法错误

**症状**:
```
Config validation failed: Invalid configuration
```

**原因**: openclaw.json 语法错误

**解决方案**:
```bash
# 1. 验证 JSON 语法
cat ~/.openclaw/openclaw.json | python -m json.tool

# 2. 恢复备份配置
cp ~/.openclaw/openclaw.json.backup ~/.openclaw/openclaw.json

# 3. 重新编辑配置
# 使用 JSON 编辑器，确保语法正确

# 4. 再次验证
openclaw doctor
```

### 问题 3: Embedding API 错误

**症状**:
```
Error: Invalid API key
```

**原因**: API Key 配置错误或未设置

**解决方案**:
```bash
# 1. 检查环境变量
echo $OPENAI_API_KEY
echo $DASHSCOPE_API_KEY

# 2. 如果未设置，添加到环境变量
export OPENAI_API_KEY="sk-..."
export DASHSCOPE_API_KEY="sk-..."

# 3. 或者在配置中使用直接值（不推荐）
{
  "embedding": {
    "apiKey": "sk-..."  # 不推荐，建议使用环境变量
  }
}

# 4. 重启网关
openclaw gateway restart
```

### 问题 4: LanceDB 初始化错误

**症状**:
```
Error: Failed to open LanceDB database
```

**原因**: 数据库路径权限问题或磁盘空间不足

**解决方案**:
```bash
# 1. 检查数据库目录
ls -la ~/.openclaw/memory/lancedb-pro

# 2. 如果不存在，创建目录
mkdir -p ~/.openclaw/memory/lancedb-pro

# 3. 检查权限
chmod 755 ~/.openclaw/memory/lancedb-pro

# 4. 检查磁盘空间
df -h ~/.openclaw

# 5. 重启网关
openclaw gateway restart
```

### 问题 5: Dreaming 定时任务不执行

**症状**: Dreaming 未按预期执行

**原因**: Cron 表达式错误或时区配置错误

**解决方案**:
```bash
# 1. 检查 cron 表达式
# 正确格式: "分 时 日 月 周"
# 示例: "0 3 * * *" 表示每天凌晨 3 点

# 2. 检查时区配置
{
  "dreaming": {
    "timezone": "Asia/Shanghai"  # 确保时区正确
  }
}

# 3. 手动触发 Dreaming（测试）
# 在对话中输入: "/dreaming"

# 4. 检查日志
openclaw gateway logs | grep dreaming
```

### 问题 6: Bridge 模式不工作

**症状**: Wiki 不包含 LanceDB 记忆内容

**原因**: Bridge 配置错误或 artifact 路径问题

**解决方案**:
```bash
# 1. 检查 Bridge 配置
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

# 2. 检查 artifact 目录
ls ~/.openclaw/memory/lancedb-pro/artifacts

# 3. 手动触发 Bridge 同步
python ~/.openclaw/skills/graphify-openclaw/scripts/wiki_ops.py sync

# 4. 检查 Wiki 状态
python ~/.openclaw/skills/graphify-openclaw/scripts/wiki_ops.py status
```

### 问题 7: 插件版本不匹配

**症状**:
```
Warning: Plugin version mismatch
```

**原因**: 本地插件版本与配置不兼容

**解决方案**:
```bash
# 1. 检查本地版本
cat ~/.openclaw/extensions/memory-lancedb-pro/package.json | grep '"version"'

# 2. 检查 GitHub 最新版本
gh release view --repo canxia-hub/memory-lancedb-pro

# 3. 如果本地版本较旧，更新
cd ~/.openclaw/extensions/memory-lancedb-pro
git fetch origin
git checkout feature/v1.3.0-shared-search-dreaming-config
git pull

# 4. 重新安装依赖
npm install

# 5. 重启网关
openclaw gateway restart
```

---

## 卸载与回滚

### 卸载插件

```bash
# 1. 禁用插件配置
# 编辑 ~/.openclaw/openclaw.json，将 enabled 设为 false
{
  "plugins": {
    "entries": {
      "memory-lancedb-pro": {
        "enabled": false
      }
    }
  }
}

# 2. 重启网关
openclaw gateway restart

# 3. (可选) 删除插件目录
rm -rf ~/.openclaw/extensions/memory-lancedb-pro

# 4. (可选) 删除数据库
rm -rf ~/.openclaw/memory/lancedb-pro
```

### 回滚到旧版本

```bash
# 1. 进入插件目录
cd ~/.openclaw/extensions/memory-lancedb-pro

# 2. 查看可用版本
git tag

# 3. 切换到指定版本
git checkout v1.1.3

# 4. 重新安装依赖
npm install

# 5. 重启网关
openclaw gateway restart
```

### 恢复配置备份

```bash
# 1. 恢复配置
cp ~/.openclaw/openclaw.json.backup ~/.openclaw/openclaw.json

# 2. 验证配置
openclaw doctor

# 3. 重启网关
openclaw gateway restart
```

---

## 附录

### A. 配置模板

#### A.1 最小配置模板

```json
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
          }
        }
      }
    }
  }
}
```

#### A.2 生产环境配置模板

```json
{
  "plugins": {
    "entries": {
      "memory-lancedb-pro": {
        "enabled": true,
        "config": {
          "embedding": {
            "provider": "openai-compatible",
            "model": "qwen3-vl-embedding",
            "dimensions": 2560,
            "apiKey": "${DASHSCOPE_API_KEY}",
            "baseURL": "https://dashscope.aliyuncs.com/compatible-mode/v1"
          },
          "dbPath": "~/.openclaw/memory/lancedb-pro",
          "autoCapture": true,
          "autoRecall": false,
          "smartExtraction": true,
          "enableManagementTools": true,
          "dreaming": {
            "enabled": true,
            "frequency": "0 3 * * *",
            "timezone": "Asia/Shanghai",
            "verboseLogging": false,
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
          },
          "retrieval": {
            "mode": "hybrid",
            "rerank": "cross-encoder",
            "rerankApiKey": "${JINA_API_KEY}",
            "rerankModel": "jina-reranker-v3",
            "rerankEndpoint": "https://api.jina.ai/v1/rerank"
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

### B. 快速命令参考

```bash
# 安装
cd ~/.openclaw/extensions
git clone -b master \
  https://github.com/canxia-hub/memory-lancedb-pro.git
cd memory-lancedb-pro && npm install

# 配置
cp ~/.openclaw/openclaw.json ~/.openclaw/openclaw.json.backup
# 编辑 ~/.openclaw/openclaw.json

# 验证
openclaw doctor

# 重启
openclaw gateway restart

# 检查状态
openclaw status

# 查看日志
openclaw gateway logs --tail 50

# 回滚
cp ~/.openclaw/openclaw.json.backup ~/.openclaw/openclaw.json
openclaw gateway restart
```

### C. 相关链接

- **Memory Suite 仓库**: https://github.com/canxia-hub/openclaw-memory-suite
- **Plugin 仓库**: https://github.com/canxia-hub/memory-lancedb-pro
- **OpenClaw 文档**: https://docs.openclaw.ai
- **LanceDB 文档**: https://lancedb.github.io/lancedb/

---

**文档维护者**: 小千 (canxia-hub)  
**最后更新**: 2026-04-20  
**版本**: v1.0.0
