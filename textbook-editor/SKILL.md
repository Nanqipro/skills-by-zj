---
version: "2.0.0"
name: textbook-editor
description: "LaTeX教材文稿编辑器，按《人工智能通识教程（第二版）》写作风格指南规范并精炼输入的.tex文件，保留全部知识内容，提升文体一致性与LaTeX格式规范性。Trigger when: user provides a .tex file or pasted LaTeX source for the AI textbook and asks for editing, refinement, style normalization, formatting fixes, or writing consistency improvements. Inputs: tex_source. Outputs: refined_tex."
---

# textbook-editor

《人工智能通识教程（第二版）》LaTeX 文稿规范化编辑器。对输入的原始 `.tex` 文件按全书写作风格指南进行精炼与规范化，保留全部知识内容，输出符合出版标准的修改稿。

## 输入 / 输出

| 变量 | 类型 | 说明 |
|------|------|------|
| `tex_source` | `.tex` 文件或粘贴的 LaTeX 源码 | 待编辑的原始稿件 |
| `refined_tex` | LaTeX 文本 | 编辑完成的规范化 LaTeX 输出 |

## 执行流程

首先阅读 `references/writing-style-guide.md` 获取完整规范，然后按以下步骤处理：

1. 判断目标章节所属模块，确定适用写作风格：
   - **风格 A（叙事科普型）**：第 1–5 章（AI 通识与基础认知、AI 赋能科研）
   - **风格 B（学术教材型）**：第 6–10 章（AI 工具实践、医工应用）
2. 按对应风格逐项检查并修改：开篇方式、段落结构、标题层级、图示格式、列表格式等
3. 核对通用写作原则：句子长度、术语规范、禁止事项、数据引用
4. 输出完整的 `refined_tex`，仅包含修改后的 LaTeX 源码

## 编辑原则

- 严格保留全部知识内容，不改动事实、案例与技术准确性
- 仅改善文体、段落节奏与 LaTeX 格式，不添加或删减实质内容
- 仅输出 `.tex` 文本，不附加说明、总结或注释

## 参考文件

| 文件 | 内容 | 何时读取 |
|------|------|----------|
| `references/writing-style-guide.md` | 全书写作风格指南（含风格 A/B 规范、通用原则、LaTeX 速查） | 每次编辑任务前必读 |

> **提示**：`references/writing-style-guide.md` 包含目录（TOC），可按章节快速定位所需规范。
