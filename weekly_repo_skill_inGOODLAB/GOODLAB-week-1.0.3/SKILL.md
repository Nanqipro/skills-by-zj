---
version: "1.0.0"
name: goodlab-week
description: "周报生成器：根据用户描述的工作内容，自动生成精美的LaTeX格式周报，包含「本周工作总结」「本周工作内容详情」「下周工作计划」三大章节，并输出可编辑的latex.zip源文件（上传Overleaf即可编译为PDF）。当用户说「帮我写个周报」「周报」「写周报」「生成周报」「本周干了XXX」「这周做了XXX」「工作进展为XXX」「帮我整理一下本周工作」「本周学习了XXX」「研究进展XXX」，或者用户描述了任何本周的工作、学习、实验、研究内容时，必须立即调用此skill，不要只用文字回答，要生成latex.zip文件。"
author: GOODLAB
---

# GOODLAB Weekly Report Generator

根据用户描述的本周工作，自动生成结构清晰、排版精美的 LaTeX 周报，产出一个文件：
- **`latex.zip`** — 含 `main.tex` 的可编辑源文件包，上传 Overleaf 即可编译为 PDF

---

## 权限边界（强制执行）

**本 skill 对文件系统的操作权限严格限定如下，任何情况下不得违反：**

| 路径 | 允许的操作 |
|------|-----------|
| `~/Desktop/` 及其子目录 | 读取、创建、写入、删除 |
| 其他任何路径 | **仅允许读取**，严禁创建、写入、删除、移动 |

**执行前必须校验：**

```bash
# 所有写入/删除操作执行前，必须先确认目标路径在 ~/Desktop/ 下
ALLOWED_BASE="$HOME/Desktop"
if [[ "$OUTPUT_DIR" != "$ALLOWED_BASE"* ]]; then
    echo "[ERROR] 权限拒绝：输出路径 $OUTPUT_DIR 不在 ~/Desktop/ 下，操作已中止"
    exit 1
fi
```

如果用户要求将文件输出到 `~/Desktop` 以外的路径，**必须拒绝并告知用户**，不得执行。

---

## 触发时机

只要用户：
- 说出「周报」「写周报」「帮我写个周报」「生成周报」等词
- 描述了本周的工作内容、研究进展、实验结果、学习情况
- 说「本周干了…」「这周做了…」「工作进展…」「本周学习了…」

就应当立刻执行本 skill，**不要只输出文字，必须生成文件**。

---

## 工作流程

### 第一步：提取关键信息

从用户输入中识别以下信息（缺失时使用括号内默认值）：

| 字段 | 来源 | 默认值 |
|------|------|--------|
| 姓名 | 用户输入 | Jin Zhao |
| 单位第一行 | 用户输入 | Nanchang University |
| 单位第二行 | 用户输入 | School of Artificial Intelligence |
| 单位第三行 | 用户输入 | Generic Operational and Optimal Data Group |
| 本周工作事项 | 用户输入 | 必须从用户描述中提取 |
| 遇到的问题及解决方案 | 用户输入或推断 | 根据工作内容合理推断 |
| 收获与体会 | 用户输入或推断 | 根据工作内容合理推断 |
| 下周计划 | 用户输入或根据进展推断 | 根据本周进展合理规划 |

### 第二步：生成三段式周报内容

#### 第一节：本周工作总结（精炼条目式）

- 将本周所有工作浓缩成 **3~7 条**简洁条目
- 每条一句话，清晰点明做了什么、达成了什么
- LaTeX 使用 `\begin{itemize} \item ... \end{itemize}`
- 目标：让读者扫一眼就知道本周干了什么

**示例格式：**
```latex
\begin{itemize}
    \item 完成了XXX数据集的预处理与特征工程，共处理样本X条
    \item 复现了YYY论文的基线模型，在ZZZ指标上达到XX\%
    \item 调研并整理了AAA领域最新进展，阅读文献X篇
\end{itemize}
```

#### 第二节：本周工作内容详情（深度展开）

- 对每项工作进行详细说明，使用 `\subsection{}` 分小节
- 每个小节包含：**做了什么 → 遇到什么问题 → 如何解决 → 收获与体会**
- 语言专业、流畅，体现技术深度
- 如有数据、指标、方法名称，应明确写出

**子节结构模板：**
```latex
\subsection{XXX工作}
本周...（做了什么）。

在此过程中，遇到了...（问题描述）。经过...（解决过程），最终...（解决结果）。

通过本次工作，深入理解了...（收获）。
```

#### 第三节：下周工作计划（前瞻性条目式）

- 根据本周进展，规划 **3~5 条**下周任务
- 每条具体可执行，体现延续性和递进性
- LaTeX 使用 `\begin{itemize} \item ... \end{itemize}`

### 第三步：生成完整 LaTeX 文件

将内容填入以下模板，生成完整的 `main.tex`。**请直接使用 Write 工具写入文件，不要只在对话中展示**。

参考 `assets/template.tex` 中的 LaTeX 文档结构和 preamble。生成时，将 `%%AUTHOR%%`、`%%INSTITUTION_1%%`、`%%INSTITUTION_2%%`、`%%INSTITUTION_3%%`、`%%SECTION1%%`、`%%SECTION2%%`、`%%SECTION3%%` 替换为实际内容。

**输出目录（macOS 桌面路径）：**

```bash
OUTPUT_DIR="$HOME/Desktop/周报-YYYYMMDD"

# 权限校验：拒绝 ~/Desktop 以外的任何写入
ALLOWED_BASE="$HOME/Desktop"
if [[ "$OUTPUT_DIR" != "$ALLOWED_BASE"* ]]; then
    echo "[ERROR] 权限拒绝：输出路径不在 ~/Desktop/ 下，操作已中止"
    exit 1
fi

mkdir -p "$OUTPUT_DIR"
echo "输出目录: $OUTPUT_DIR"
```

将 `YYYYMMDD` 替换为今天的实际日期（如 `20260406`），最终输出到 `~/Desktop/周报-YYYYMMDD/`。

### 第四步：打包 latex.zip

进入输出目录，将 `main.tex` 打包后删除原始文件，确保文件夹内只剩 `latex.zip`：

```bash
cd "$OUTPUT_DIR"

# 检查 zip 是否可用
if ! command -v zip &>/dev/null; then
    echo "[ERROR] 未找到 zip 命令，请执行 brew install zip 后重试"
    exit 1
fi

zip -r latex.zip main.tex
rm main.tex
echo "[OK] 源文件已打包: $OUTPUT_DIR/latex.zip"
```

### 第五步：交付结果

向用户说明：
1. **ZIP 位置**：`~/Desktop/周报-YYYYMMDD/latex.zip`（含 `main.tex`）
2. **在线编译**：将 `latex.zip` 上传至 [Overleaf](https://www.overleaf.com) 即可在线编译为 PDF
3. 简要说明如何自定义（修改作者、机构、内容等）

---

## 内容质量要求

- **第一节**：精炼，每条 ≤ 30 字，一目了然
- **第二节**：丰富，每个子节 ≥ 100 字，有技术深度
- **第三节**：具体，每条计划有明确的行动指向
- **整体**：语言流畅自然，专业但不晦涩，体现研究生/工程师的专业素养
- **LaTeX**：特殊字符（`%`, `&`, `_`, `#`, `$`, `{`, `}`）需正确转义

---

## 常见 LaTeX 转义规则

| 字符 | LaTeX 写法 |
|------|-----------|
| % | `\%` |
| & | `\&` |
| _ | `\_` |
| # | `\#` |
| $ | `\$` |
| { } | `\{ \}` |
| ~ | `\textasciitilde{}` |
| ^ | `\textasciicircum{}` |

---

## 参考资源

- `assets/template.tex` — LaTeX 模板（preamble、文档结构、样式定义）
- `scripts/compile.sh` — 打包脚本（zip 打包，供手动调用）
