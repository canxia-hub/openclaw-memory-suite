---
name: graphify-openclaw
description: 维护 `~/.openclaw/wiki/` 私有知识库与知识图谱。用于以下场景：(1) 用户或 Agent 需要创建、更新、查询 wiki 条目，(2) 需要同步反向链接、分类索引或重建图谱，(3) 需要用 DashScope 语义增强补充跨文档关联，(4) 需要诊断 wiki 是否有坏链、图谱过期或流程异常。
---

# graphify-openclaw

把 `~/.openclaw/wiki/` 作为全局私有知识库，Markdown 原文是权威，图谱负责导航增强。

## 统一入口

优先使用统一入口，而不是记很多零散脚本：

```bash
python ~/.openclaw/skills/graphify-openclaw/scripts/wiki_ops.py <command>
```

需要详细协议时，读取：
- `references/wiki-usage-protocol-2026-04-11.md`

## 常用命令

```bash
python ~/.openclaw/skills/graphify-openclaw/scripts/wiki_ops.py status
python ~/.openclaw/skills/graphify-openclaw/scripts/wiki_ops.py doctor
python ~/.openclaw/skills/graphify-openclaw/scripts/wiki_ops.py new concept "Agent 通信协议" "agent,communication" stable
python ~/.openclaw/skills/graphify-openclaw/scripts/wiki_ops.py build
python ~/.openclaw/skills/graphify-openclaw/scripts/wiki_ops.py build --semantic
python ~/.openclaw/skills/graphify-openclaw/scripts/wiki_ops.py query 记忆
```

## 指令映射

### `/wiki`

- `/wiki`：读取 `~/.openclaw/wiki/INDEX.md`
- `/wiki new ...`：等价于 `wiki_ops.py new ...`，分类支持 `concept|decision|procedure|reference|snippet` 及其复数形式
- `/wiki build`：等价于 `wiki_ops.py build`
- `/wiki build --semantic`：等价于 `wiki_ops.py build --semantic`
- `/wiki index`：等价于 `wiki_ops.py index`
- `/wiki sync-links`：等价于 `wiki_ops.py sync-links`
- `/wiki doctor`：等价于 `wiki_ops.py doctor`

### `/wiki-write`

把当前确认后的内容写入对应分类，然后同步反链、索引和图谱。写入后必须回读生成文件，确认 Front Matter、正文结构、链接都正确。

### `/wiki-query`

先运行 `wiki_ops.py query <terms>`，再读取命中的 Markdown 原文，不只看图谱或命令行摘要。

## DashScope 语义增强

`build --semantic` 会：

1. 优先读取 `DASHSCOPE_API_KEY`
2. 否则从 `~/.openclaw/openclaw.json` 中读取 DashScope 兼容 key
3. 仅对真实知识条目做跨文档关系推断，自动跳过 `INDEX.md` 和 `_INDEX.md`
4. 补充 `relates_to / depends_on / extends / contrasts_with` 类型的语义边

## 可靠性规则

- Markdown 原文始终高于图谱推断
- 如果 `doctor` 发现图谱过期，先重建再依赖图谱
- 如果 `--semantic` 失败，继续使用结构化图谱，不阻塞主流程
- 新条目写入后至少要同步一次反向链接和索引

## MEMORY 文档导引规范

### 自动维护规则

当创建或更新**专题知识库**（如 openclaw-lark、某个插件、某个项目）时，**必须**同步更新 MEMORY.md 的 `wiki_knowledge_base` 部分，添加专题导引。

### 导引格式

在 MEMORY.md 的 `<wiki_knowledge_base>` 中添加 `<specialized_wikis>` 部分：

```xml
<specialized_wikis>
  <wiki name="openclaw-lark">
    <description>飞书官方插件知识库：技能文档 + 源码结构</description>
    <path>~/.openclaw/wiki/reference/openclaw-lark/INDEX.md</path>
    <tags>[openclaw-lark, feishu, plugin, troubleshooting]</tags>
    <created>2026-04-16</created>
    <entry_points>
      <entry>skills/INDEX.md - 技能文档索引</entry>
      <entry>core-modules/INDEX.md - 源码模块索引</entry>
    </entry_points>
    <quick_use>
      <query>python wiki_ops.py query openclaw-lark</query>
      <query>python wiki_ops.py query 授权</query>
    </quick_use>
  </wiki>
</specialized_wikis>
```

### 触发条件

- 创建新的专题知识库（如 `reference/{topic}/`）
- 更新专题知识库的结构（新增/删除主要入口）
- 专题知识库发生重大变更

### 不触发条件

- 单个条目的创建/更新（不改变专题结构）
- 临时的探索性文档
- 测试性质的知识条目

### 执行流程

1. 创建/更新专题知识库
2. 运行 `wiki_ops.py build --semantic` 更新图谱
3. 同步更新 MEMORY.md 的 `<specialized_wikis>` 部分
4. 在回复中说明已更新导引

## 参考

按需读取：
- `references/wiki-usage-protocol-2026-04-11.md`
- `references/openclaw-graphify-integration-plan-2026-04-10.md`
- `references/upstream-verified-facts-2026-04-10.md`
