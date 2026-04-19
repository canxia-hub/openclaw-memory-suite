---
name: self-improvement
description: "智能捕获经验与错误，构建反思数据库，驱动Agent思维基础设施进化。工作流程：(1)检测触发信号→(2)查询记忆库→(3)结构化记录到LanceDB→(4)定期聚类分析→(5)提案修改核心文件→(6)用户审批后执行。战术层(单次错误)即时记录，战役层(3+次同类)自动更新TOOLS.md，战略层(方法论)提案修改AGENTS.md/SOUL.md需审批。"
metadata:
  clawdbot:
    emoji: "🧬"
---

# Self-Improvement Skill v3.1 - 进化型

> **版本**: 3.1  
> **更新**: 2026-04-13  
> **定位**: 从"记录经验"到"进化思维基础设施"

---

## 核心使命

不是简单地"记住错误供以后查阅"，而是**将个体经验转化为集体智慧**，最终**升级 Agent 的思维基础设施**（AGENTS.md / SOUL.md / TOOLS.md / MEMORY.md），从根源上预防问题复发。

---

## 三层进化架构

```
┌─────────────────────────────────────────────────────────────────┐
│  Layer 3: 战略层 (Strategic) - AGENTS.md / SOUL.md              │
│  ├─ 修改频率：每周一次审批周期                                   │
│  ├─ 触发条件：同类问题出现 5+ 次 或 涉及核心工作流/原则           │
│  ├─ 修改方式：结构化提案 → 用户审批 → 原子化提交                  │
│  └─ 通知渠道：飞书 (strategic) + WebUI                           │
├─────────────────────────────────────────────────────────────────┤
│  Layer 2: 战役层 (Campaign) - TOOLS.md / 技能文档 / MEMORY.md     │
│  ├─ 修改频率：每日定时任务检查                                   │
│  ├─ 触发条件：同类问题出现 3+ 次                                  │
│  ├─ 升级阈值：同类标准化流程出现 5+ 次时，自动升级为独立技能        │
│  ├─ 修改方式：3-4次 → 自动生成TOOLS.md补丁（免审批）              │
│  │          5+次 → 生成/更新技能SKILL.md + 同步到MEMORY.md首选工具清单（需提案审批） │
│  └─ 通知渠道：飞书 (tactical) + WebUI 日志                       │
├─────────────────────────────────────────────────────────────────┤
│  Layer 1: 战术层 (Operational) - LanceDB 反思库                  │
│  ├─ 修改频率：每次对话自动触发                                   │
│  ├─ 触发条件：任何错误/纠正/洞察/知识差距                         │
│  ├─ 修改方式：即时写入 LanceDB，带【反思】标签                    │
│  └─ 检索方式：memory_recall(category="decision") 或 CLI: `openclaw memory-pro search --category decision`                  │
└─────────────────────────────────────────────────────────────────┘
```

### 飞书 Webhook 通知层级

| 层级 | Webhook Level | 触发条件 | 通知内容 | 需审批 |
|------|---------------|----------|----------|--------|
| **战略层** | `strategic` | 每周五 09:00，5+ 次同类问题 | 修改提案待审批 | ✅ 必须 |
| **战役层** | `tactical` | 每日 02:00，3+ 次同类问题 | TOOLS.md 已更新 | ❌ 自动 |
| **战术层** | `operational` | 单次反思记录 | 记录确认 | ❌ 静默 |
| **系统警报** | `error` | 脚本执行失败 | 异常通知 | - |

---

## 第一层：战术层 - 实时反思捕获

### 触发信号检测器

| 信号类型 | 检测关键词/场景 | 紧急度 | 示例 |
|---------|----------------|--------|------|
| 🔴 **Error** | 命令非零退出、异常抛出、API 超时/失败 | 高 | `exit code 1`, `Connection refused`, `Rate limit exceeded` |
| 🟡 **Correction** | 用户说"不对"、"错了"、"应该是"、"Actually" | 高 | "不对，我们用的是 pnpm 不是 npm" |
| 🟢 **Insight** | 发现更好的方法、优化思路 | 中 | "其实可以用 `--dry-run` 先测试" |
| 🔵 **Gap** | 用户告知新信息、发现知识过时 | 中 | "原来我们换了新的部署流程" |

### 标准处理流程（每次错误必须执行）

```
错误发生
    ↓
Step 1: 【暂停】停止重复尝试，防止恶化
    ↓
Step 2: 【检索】memory_recall(query="错误类型 + 关键词") 查找已有解决方案
    ↓
有解决方案？ ──是──→ Step 3a: 【应用】使用记忆中的方案解决问题
    ↓ 否                  ↓
Step 3b: 【诊断】分析根因，尝试解决                      解决成功？
    ↓                                                  是 ↓ 否
Step 4: 【记录】使用 memory_store 写入反思               跳过记录  继续诊断
    ↓
Step 5: 【确认】向用户简要说明已记录反思
```

### 反思记录格式（必须严格遵守）

使用 `memory_store` 写入，格式如下：

```javascript
{
  "text": "【反思-YYYY-MM-DD-HHMM】类型：Error/Correction/Insight/Gap\n\n【问题描述】\n发生了什么，具体错误信息\n\n【根因分析】\n为什么会这样，深层原因\n\n【解决方案】\n如何解决，具体步骤\n\n【预防措施】\n下次如何避免，检查清单\n\n【关联文件】\n涉及的核心文件或技能\n\n【置信度】高/中/低",
  "category": "decision",
  "importance": 0.85,  // Error/Correction: 0.85-0.9, Insight/Gap: 0.7-0.8
  "tags": ["error", "git", "workflow"]  // 至少3个标签，便于聚类
}
```

### 快速记录模板

#### 场景 A: 命令/操作失败

```bash
# 立即执行
memory_store --text "【反思-$(date +%Y-%m-%d-%H%M)】类型：Error

【问题描述】
[命令]: git push origin main
[错误]: ERROR: Permission to repo denied
[上下文]: 新克隆的仓库首次推送

【根因分析】
SSH key 未添加到 GitHub 账户，或使用了 HTTPS 而非 SSH 协议

【解决方案】
1. 检查远程协议: git remote -v
2. 如为 HTTPS，切换为 SSH: git remote set-url origin git@github.com:...
3. 验证 SSH 连接: ssh -T git@github.com
4. 如失败，生成新 key: ssh-keygen -t ed25519 -C 'email'

【预防措施】
- 新项目启动时运行: git remote -v && ssh -T git@github.com
- 在 AGENTS.md 中添加'新项目检查清单'

【关联文件】
AGENTS.md, TOOLS.md

【置信度】高" --category decision --importance 0.85 --tags error,git,ssh,permission
```

#### 场景 B: 被用户纠正

```bash
memory_store --text "【反思-$(date +%Y-%m-%d-%H%M)】类型：Correction

【问题描述】
误以为项目使用 npm install，用户纠正实际使用 pnpm

【根因分析】
看到 package.json 就默认使用 npm，未检查锁文件类型

【正确认知】
- 优先检查锁文件: pnpm-lock.yaml → 使用 pnpm
- 次选检查 packageManager 字段
- 禁止假设，必须验证

【预防措施】
- 安装依赖前执行: ls *lock* 2>/dev/null || cat package.json | grep packageManager
- 在 TOOLS.md 中添加'包管理器检测规范'

【关联文件】
TOOLS.md

【置信度】高" --category decision --importance 0.9 --tags correction,package-manager,pnpm,assumption
```

#### 场景 C: 发现更好方法

```bash
memory_store --text "【反思-$(date +%Y-%m-%d-%H%M)】类型：Insight

【问题描述】
原本使用 grep 搜索记忆，发现 memory_recall 工具混合搜索更高效

【原方法】
grep -r "keyword" 记忆文件

【新方法】
memory_recall(query="keyword", category="decision") 或 CLI: `openclaw memory-pro search "keyword" --category decision`

【优势】
- 语义理解，不限于精确匹配
- 自动排序相关性
- 支持分类过滤

【预防措施】
- 优先使用向量搜索工具
- 在 TOOLS.md 中更新首选工具清单

【关联文件】
TOOLS.md, MEMORY.md

【置信度】中" --category decision --importance 0.75 --tags insight,search,lancedb,best-practice
```

---

## 第二层：战役层 - 模式识别与自动修复

### 每日定时任务（02:00 执行）

```yaml
# 任务名: self-evolution-daily
# 调度: 0 2 * * *
# 执行者: 独立Agent会话（isolated session）
```

**任务内容**：
1. 查询过去 24 小时的反思记录
2. 按标签聚类，统计同类问题出现次数
3. 识别达到 "战役层阈值"（3+ 次）的模式
4. 生成 TOOLS.md 或技能文档优化提案（不直接修改，需用户确认）
5. 记录分析结果到记忆库
6. 通知用户优化建议

### 战役层处理流程

```
每日 02:00 定时触发
    ↓
查询昨日反思: memory_recall "" --scope reflection --since yesterday
    ↓
聚类分析: 按 tags 分组统计
    ↓
发现模式 X 出现 3+ 次？
    ↓ 是
┌─────────────────────────────────────────┐
│  出现次数 < 5次？                        │
│  ↓ 是                                   │
│  读取当前 TOOLS.md                       │
│  生成极简补丁（≤200字，压缩token）        │
│  应用补丁 → 创建备份 → 写入文件           │
│  记录报告 → 发送通知                     │
└─────────────────────────────────────────┘
    ↓ 否（出现 ≥5次，已形成标准化流程）
读取同类流程的所有操作记录
    ↓
提炼极致简洁的可复用流程（压缩token，删除冗余描述）
    ↓
检查是否已有对应技能
    ↓ 是 → 更新现有技能SKILL.md的流程描述
      否 → 生成新的技能SKILL.md（符合规范）
    ↓
生成更新MEMORY.md首选工具清单的提案
    ↓
将技能草稿 + MEMORY更新提案发送给用户审批
    ↓
审批通过后执行写入 → 记录报告
```

### 自动补丁示例

**发现模式**: "Git 权限错误" 出现 4 次

**生成补丁**（添加到 TOOLS.md）:

```markdown
## [Auto-Added 2026-03-09] Git 常见问题

### 权限被拒绝 (Permission denied)
**症状**: `git push` 失败，提示权限错误
**根因**: SSH key 未配置或使用了 HTTPS 协议
**解决**:
```bash
# 1. 检查远程协议
git remote -v

# 2. 如为 HTTPS，切换 SSH
git remote set-url origin git@github.com:user/repo.git

# 3. 验证 SSH 连接
ssh -T git@github.com
```
**预防**: 新项目启动时运行 `git remote -v && ssh -T git@github.com`
```

---

## 第三层：战略层 - 方法论进化

### 每3天审批周期（03:00 执行）

```yaml
# 任务名: self-evolution-cycle
# 调度: 0 3 */3 * *
# 执行者: 独立Agent会话（isolated session）
# 审批者: 天夔訫（最高权限用户）
```

**任务内容**：
1. 分析过去3天所有反思（战术+战役）
2. 识别达到 "战略层阈值" 的模式：
   - 同类问题出现 5+ 次，或
   - 涉及核心工作流缺陷，或
   - 影响 Agent 行为准则
3. 生成结构化修改提案
4. 发送审批通知（飞书 + WebUI）
5. 等待用户批准/拒绝/修改
6. 批准后执行修改，创建备份

### 战略层提案格式

```markdown
# 核心文件修改提案 [PROP-YYYY-MM-DD-XXX]

## 提案概要
| 项目 | 内容 |
|------|------|
| **目标文件** | AGENTS.md / SOUL.md / TOOLS.md / MEMORY.md |
| **修改类型** | 新增章节 / 修改现有 / 删除废弃 |
| **紧急程度** | 高 / 中 / 低 |
| **预期收益** | 减少 X 类错误 Y% |

## 问题分析
基于本周反思数据分析：
- [REF-001] 描述... (出现 5 次)
- [REF-002] 描述... (出现 3 次)
- 共同模式：...

## 修改草案

### 当前内容（如有）
```
[引用现有内容]
```

### 建议修改
```diff
+ [新增/修改的内容]
- [删除的内容]
```

## 影响评估
- **正面影响**: ...
- **潜在风险**: ...
- **回滚方案**: 恢复备份文件 core-files-backup/AGENTS.md.YYYYMMDD.bak

## 审批选项
- [ ] **批准** - 立即执行修改
- [ ] **拒绝** - 记录原因，30天后重新评估
- [ ] **修改** - 用户编辑后重新提交

**审批截止时间**: YYYY-MM-DD 18:00
```

### 审批流程

```
周五 09:00 生成提案
    ↓
发送飞书通知 + WebUI 弹窗
    ↓
等待用户审批（最长 72 小时）
    ↓
用户选择:
    ├─ 批准 ──→ 执行修改 → Git commit → 发送确认
    ├─ 拒绝 ──→ 记录原因到 LanceDB → 30天后重提
    └─ 修改 ──→ 用户编辑 → 重新提交 → 再次审批
```

---

## 核心文件版本管理

### 备份策略

```
core-files-backup/
├── AGENTS.md/
│   ├── AGENTS.md.20260307.bak
│   ├── AGENTS.md.20260309.bak
│   └── latest -> AGENTS.md.20260309.bak
├── SOUL.md/
│   ├── SOUL.md.20260305.bak
│   └── latest
├── TOOLS.md/
│   └── ...
└── MEMORY.md/
    └── ...
```

### 回滚机制

**自动回滚触发条件**：
- 修改后 7 天内，同类错误发生率上升
- 用户明确反馈"修改后效果不佳"

**手动回滚命令**：
```bash
# 查看历史版本
ls -la core-files-backup/AGENTS.md/

# 回滚到指定版本
cp core-files-backup/AGENTS.md/AGENTS.md.20260307.bak AGENTS.md

# 记录回滚
memory_store --text "【反思-回滚】AGENTS.md 回滚至 20260307 版本
原因: ..." --category decision --importance 0.9 --tags rollback,agents
```

**核心文件清单（5个）**：
| 文件 | 修改频率 | 审批要求 |
|------|---------|---------|
| `AGENTS.md` | 中 | 战略层需审批 |
| `SOUL.md` | 低 | 战略层需审批（极高敏感度） |
| `IDENTITY.md` | 极低 | **必须最高权限用户审批** |
| `TOOLS.md` | 高 | 战役层自动 |
| `MEMORY.md` | 中 | 战略层需审批 |

---

## 自定义管理指令

### `/reflect` 指令（用户手动触发）

当用户发送 `/reflect` 或 `/反思` 时：

1. **无参数**: 立即分析最近一次错误/纠正，生成反思记录
2. **带参数 `/reflect <描述>`**: 将用户描述记录为 Insight 类型反思
3. **`/reflect status`**: 显示本周反思统计和待审批提案

**执行流程**：
```
用户发送 /reflect
    ↓
读取当前会话历史（最近 10 轮）
    ↓
识别最近的问题/纠正/洞察
    ↓
生成反思草稿
    ↓
展示给用户确认
    ↓
用户确认后写入 LanceDB
```

### `/review` 指令（手动触发战役/战略层审查）

当用户发送 `/review` 或 `/审查` 时：

1. **无参数**: 立即执行战役层分析（相当于手动触发每日任务）
2. **`/review strategic`**: 立即生成战略层提案（相当于手动触发每周任务）
3. **`/review history`**: 显示过去 30 天的修改历史

---

## 快速参考卡

| 场景 | 立即行动 | 后续跟进 |
|------|---------|---------|
| 命令失败 | 暂停 → 检索记忆 → 诊断 → `memory_store` 记录 | 每日检查是否达战役层阈值 |
| 被用户纠正 | 立即 `memory_store` 记录 (importance=0.9) | 检查是否需更新 SOUL.md |
| 发现更好方法 | `memory_store` 记录 (importance=0.75) | 评估是否推广到 AGENTS.md |
| 用户发送 `/reflect` | 分析最近问题 → 生成草稿 → 确认写入 | 更新反思统计 |
| 每日 02:00 | 自动聚类分析 → 更新 TOOLS.md（免审批） | 发送 WebUI 通知 |
| 每周五 09:00 | 生成战略层提案 → 发送飞书+WebUI | 等待用户审批 |
| 同类问题 5+ 次 | 标记为战略层候选 | 纳入下周提案 |

---

## 与旧版对比

| 维度 | v2.0 (旧，已完全废弃) | v3.1 (新，当前使用) |
|------|----------------------|---------------------|
| 核心目标 | 记录经验供查阅 | 进化思维基础设施 |
| 存储位置 | `.learnings/*.md`（已删除） | LanceDB (战术) + 核心配置文件 (战略) |
| 处理时效 | 人工定期审查 | 战术层即时记录 + 战役层每日分析 + 战略层每3天提案 |
| 修改审批 | 全部人工 | TOOLS.md/技能文档更新需用户确认，AGENTS/SOUL等核心文件需正式审批 |
| 检索方式 | `grep` 文本搜索 | `memory_recall` 工具 / `openclaw memory-pro search` CLI |
| 回滚机制 | 无 | 核心文件修改前自动创建备份，支持手动回滚 |
| 通知渠道 | 无 | 飞书通知（可选） + WebUI 日志 |

---

## 附录 A：反思质量检查清单

写入反思前，确认以下项目：

- [ ] 包含【反思-YYYY-MM-DD-HHMM】前缀
- [ ] 明确标注类型（Error/Correction/Insight/Gap）
- [ ] 问题描述具体，包含错误信息或原话
- [ ] 根因分析深入，不止于表面
- [ ] 解决方案可操作，有具体命令/步骤
- [ ] 预防措施能真正避免复发
- [ ] 关联文件准确
- [ ] 至少 3 个标签，便于聚类
- [ ] importance 设置合理（Error/Correction: 0.85+, Insight/Gap: 0.7-0.8）

---

## 附录 B：可选扩展配置

### 1. 定时任务说明（已配置完成）
当前已通过 `openclaw cron` 配置完成所有进化任务，无需额外脚本：
| 任务名 | 执行周期 | 用途 |
|--------|----------|------|
| `self-evolution-daily` | 每日 02:00 | 战役层每日反思分析 |
| `self-evolution-cycle` | 每3天 03:00 | 战略层核心规则迭代提案 |
| `self-growth-daily-diary` | 每日 01:30 | 人格成长每日日记 |
| `self-growth-weekly-soul-evolution` | 每周日 04:00 | SOUL.md人格微调提案 |

### 2. 飞书通知（可选功能）
飞书通知为可选扩展功能，当前环境未配置，如需启用可按以下方式配置：
1. 在飞书创建Webhook机器人
2. 将Webhook URL写入 `.config/feishu-webhook` 文件
3. 定时任务会自动将审批通知发送到配置的飞书地址

### 3. 版本备份（可选功能）
核心文件备份为可选功能，当前使用手动备份机制：
- 核心文件修改前自动创建 `.bak` 备份文件
- 重要变更可手动提交到Git仓库（如已初始化）

### 4. 已废弃内容说明
以下旧系统内容已完全移除，不再使用：
- ❌ `.learnings/` 目录及相关文件
- ❌ `scripts/self-improvement-*.sh` 独立脚本
- ❌ `scripts/setup-self-improvement-cron.sh` 配置脚本
- ❌ `scripts/feishu-notify.sh` 通知脚本
