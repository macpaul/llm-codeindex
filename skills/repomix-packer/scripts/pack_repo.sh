#!/usr/bin/env bash
# ==============================================================================
# pack_repo.sh
# Packs the repository with Tree-sitter AST signature compression (--compress)
# ==============================================================================

set -euo pipefail

OUTPUT_FILE="${1:-repomix-output.xml}"
FORMAT="${2:-xml}" # xml or markdown

if ! command -v repomix >/dev/null 2>&1; then
    echo "[ERROR] 'repomix' is not installed."
    echo "Install with: npm install -g repomix or npm install -g repomix-rs"
    exit 1
fi

echo "[Repomix] Compressing codebase into ${OUTPUT_FILE} (Format: ${FORMAT})..."
repomix \
    --compress \
    --style "${FORMAT}" \
    --output "${OUTPUT_FILE}" \
    --ignore "**/node_modules/**,**/target/**,**/dist/**,**/.git/**,**/venv/**,**/.venv/**"

echo "[SUCCESS] Codebase packed into ${OUTPUT_FILE}."
ls -lh "${OUTPUT_FILE}"
