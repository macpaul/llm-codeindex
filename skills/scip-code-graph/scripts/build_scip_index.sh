#!/usr/bin/env bash
# ==============================================================================
# build_scip_index.sh
# Detects project language and runs appropriate SCIP indexer
# ==============================================================================

set -euo pipefail

OUTPUT_PATH="${1:-index.scip}"

echo "[SCIP Builder] Checking project environment..."

if [[ -f "go.mod" ]] && command -v scip-go >/dev/null 2>&1; then
    echo "[SCIP] Indexing Go project with scip-go..."
    scip-go index --output "${OUTPUT_PATH}"
    echo "[SUCCESS] Generated ${OUTPUT_PATH}"
    exit 0
fi

if [[ -f "package.json" || -f "tsconfig.json" ]] && command -v scip-typescript >/dev/null 2>&1; then
    echo "[SCIP] Indexing TypeScript/JavaScript project with scip-typescript..."
    scip-typescript index --output "${OUTPUT_PATH}"
    echo "[SUCCESS] Generated ${OUTPUT_PATH}"
    exit 0
fi

if [[ -f "pyproject.toml" || -f "setup.py" || -f "requirements.txt" ]] && command -v scip-python >/dev/null 2>&1; then
    echo "[SCIP] Indexing Python project with scip-python..."
    scip-python index . --project-name="$(basename "$PWD")" --output "${OUTPUT_PATH}"
    echo "[SUCCESS] Generated ${OUTPUT_PATH}"
    exit 0
fi

if [[ -f "compile_commands.json" ]] && command -v scip-clang >/dev/null 2>&1; then
    echo "[SCIP] Indexing C/C++ project with scip-clang..."
    scip-clang --compdb-path=compile_commands.json --index-file="${OUTPUT_PATH}"
    echo "[SUCCESS] Generated ${OUTPUT_PATH}"
    exit 0
fi

if [[ -f "Cargo.toml" ]] && command -v rust-analyzer >/dev/null 2>&1; then
    echo "[SCIP] Indexing Rust project with rust-analyzer scip..."
    rust-analyzer scip . --output "${OUTPUT_PATH}"
    echo "[SUCCESS] Generated ${OUTPUT_PATH}"
    exit 0
fi

echo "[ERROR] No recognized language manifest found or indexer is missing."
echo "Ensure scip-go, scip-typescript, scip-python, scip-clang, or rust-analyzer is installed."
exit 1
