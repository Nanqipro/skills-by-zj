---
version: "2.0.0"
name: textbook-pipeline
description: "教材编辑审校全流程调度器，串行调用 textbook-editor（LaTeX文稿规范化编辑）和 textbook-reviewer（专业质量审校），最终同时交付 refined.tex 和 review_report.docx 两个文件，全程不参与任何内容修改。Trigger when: user wants to run the complete edit-and-review workflow on a .tex file for 《人工智能通识教程》 in one step, or asks for both a refined LaTeX file and a Word review report together. Input: tex_source. Outputs: refined_tex, review_report_docx."
---

# textbook-pipeline

《人工智能通识教程（第二版）》教材编辑审校全流程调度器。严格按照固定顺序串行调用 `textbook-editor` 和 `textbook-reviewer` 两个下游技能，收集并交付最终两份文件。全程仅做流程调度与文件传递，不参与任何内容生成或修改逻辑。

## 输入 / 输出

| 变量 | 类型 | 说明 |
|------|------|------|
| `tex_source` | `.tex` 文件或粘贴的 LaTeX 源码 | 用户提供的原始稿件 |
| `refined_tex` | LaTeX 文本 | textbook-editor 生成的编辑后文件 |
| `review_report_docx` | `.docx` 文件 | textbook-reviewer 生成的美化版审校报告 |

## 固定执行流程

**必须完整执行三步，不可省略、颠倒或跳过任意步骤。**

### 第一步：调用 textbook-editor

- 输入：用户提供的原始文件 `tex_source`
- 动作：触发 `textbook-editor` 技能，传入 `tex_source`，等待生成编辑后文件
- 输出：接收生成的 `refined.tex`

### 第二步：调用 textbook-reviewer

- 输入：第一步生成的 `refined.tex`
- 动作：触发 `textbook-reviewer` 技能，传入 `refined.tex`，等待生成审校报告
- 输出：接收生成的 `review_report.docx`

### 第三步：收集并交付结果

- 动作：汇总两步骤生成的文件，整理为最终交付包，输出到 `~/.openclaw/workspace`
- 交付内容：同时向用户发送以下 2 个文件（缺一不可）：
  1. `refined.tex` — 编辑后的规范化 LaTeX 文件
  2. `review_report.docx` — 美化格式的审校评价报告

## 角色边界

本技能**只做以下事情**：

- 接收 `tex_source` 输入
- 按顺序触发下游技能并传递文件
- 收集并整理最终输出交付给用户

本技能**绝对不做以下事情**：

- 修改、编辑、润色任何 LaTeX 内容或文字表述
- 干预 textbook-editor 或 textbook-reviewer 的逻辑与输出结果
- 跳过、颠倒、合并工作流步骤
- 生成额外文件、文字说明或补充内容
- 修改下游技能生成文件的名称、格式、内容
