#!/usr/bin/env bash
# compile.sh — 打包 LaTeX 周报源文件为 latex.zip
# 用法: bash compile.sh <path/to/main.tex>
#
# 依赖: zip
# 输出: 同目录下的 latex.zip（上传 Overleaf 即可在线编译为 PDF）

set -euo pipefail

# ——— 参数处理 ———
TEX_FILE="${1:-}"
if [[ -z "$TEX_FILE" ]]; then
    echo "[ERROR] 请提供 .tex 文件路径，例如: bash compile.sh ~/Desktop/周报-20260407/main.tex"
    exit 1
fi

TEX_FILE="$(realpath "$TEX_FILE")"
TEX_DIR="$(dirname "$TEX_FILE")"

# ——— 权限校验：只允许在 ~/Desktop 下写入 ———
ALLOWED_BASE="$(realpath "$HOME/Desktop")"
if [[ "$TEX_DIR" != "$ALLOWED_BASE"* ]]; then
    echo "[ERROR] 权限拒绝：操作路径 $TEX_DIR 不在 ~/Desktop/ 下，已中止"
    exit 1
fi

echo "=========================================="
echo "  GOODLAB Weekly Report Packager"
echo "  源文件: $TEX_FILE"
echo "  输出目录: $TEX_DIR"
echo "=========================================="

# ——— 检查 zip 是否可用 ———
if ! command -v zip &>/dev/null; then
    echo "[ERROR] 未找到 zip 命令，请执行 brew install zip 后重试"
    exit 1
fi

cd "$TEX_DIR"
zip -r "latex.zip" "main.tex"

if [[ -f "$TEX_DIR/latex.zip" ]]; then
    rm "$TEX_FILE"
    echo "[OK] 源文件已打包: $TEX_DIR/latex.zip"
else
    echo "[ERROR] zip 打包失败，请手动压缩 $TEX_DIR 目录"
    exit 1
fi

echo ""
echo "=========================================="
echo "  打包完成！"
echo "  ZIP:      $TEX_DIR/latex.zip"
echo "  在线编译: 将 latex.zip 上传至 overleaf.com"
echo "=========================================="
