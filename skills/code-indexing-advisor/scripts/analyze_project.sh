#!/usr/bin/env bash
# ==============================================================================
# analyze_project.sh
# Scans the current directory to determine codebase characteristics and
# recommends the optimal indexing strategy and tools.
# ==============================================================================

set -euo pipefail

TARGET_DIR="${1:-.}"
cd "${TARGET_DIR}"

echo "========================================================"
echo "          Codebase Indexing Advisor Scanner             "
echo "========================================================"
echo "Inspecting directory: $(pwd)"

# Count files by extension
PY_COUNT=$(find . -maxdepth 5 -name "*.py" -not -path "*/.*" 2>/dev/null | wc -l)
C_COUNT=$(find . -maxdepth 5 \( -name "*.c" -o -name "*.h" -o -name "*.cpp" -o -name "*.hpp" \) -not -path "*/.*" 2>/dev/null | wc -l)
TS_COUNT=$(find . -maxdepth 5 \( -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" \) -not -path "*/.*" -not -path "*/node_modules/*" 2>/dev/null | wc -l)
RS_COUNT=$(find . -maxdepth 5 -name "*.rs" -not -path "*/.*" -not -path "*/target/*" 2>/dev/null | wc -l)
GO_COUNT=$(find . -maxdepth 5 -name "*.go" -not -path "*/.*" 2>/dev/null | wc -l)

echo ""
echo "Detected Source Code Files:"
echo " - Python (.py):        ${PY_COUNT}"
echo " - C / C++ (.c/.h/.cpp): ${C_COUNT}"
echo " - TypeScript / JS:     ${TS_COUNT}"
echo " - Rust (.rs):          ${RS_COUNT}"
echo " - Go (.go):            ${GO_COUNT}"

# Detect project marker files
HAS_CARGO=false; [[ -f "Cargo.toml" ]] && HAS_CARGO=true
HAS_GOMOD=false; [[ -f "go.mod" ]] && HAS_GOMOD=true
HAS_PACKAGEJSON=false; [[ -f "package.json" ]] && HAS_PACKAGEJSON=true
HAS_TSCONFIG=false; [[ -f "tsconfig.json" ]] && HAS_TSCONFIG=true
HAS_PYPROJECT=false; [[ -f "pyproject.toml" || -f "requirements.txt" || -f "setup.py" ]] && HAS_PYPROJECT=true
HAS_COMPILE_COMMANDS=false; [[ -f "compile_commands.json" ]] && HAS_COMPILE_COMMANDS=true

echo ""
echo "Detected Build Manifests:"
echo " - Cargo.toml:           ${HAS_CARGO}"
echo " - go.mod:               ${HAS_GOMOD}"
echo " - package.json:         ${HAS_PACKAGEJSON}"
echo " - tsconfig.json:        ${HAS_TSCONFIG}"
echo " - Python build files:   ${HAS_PYPROJECT}"
echo " - compile_commands.json: ${HAS_COMPILE_COMMANDS}"

echo ""
echo "========================================================"
echo "          Recommended Indexing Strategy                 "
echo "========================================================"

TOTAL_FILES=$((PY_COUNT + C_COUNT + TS_COUNT + RS_COUNT + GO_COUNT))

if [ "${TOTAL_FILES}" -eq 0 ]; then
    echo "No mainstream source files detected in shallow tree."
    echo "Recommendation: Run 'toktoken index:create' or check subdirectories."
    exit 0
fi

# Tier 1 recommendation:
echo "[Tier 1: High-Compression Architectural Overview]"
echo "  Command: repomix --compress"
echo "  Benefit: Strips AST bodies, retaining classes, signatures, and docstrings (60-90% token reduction)."

# Tier 2 recommendation:
echo ""
echo "[Tier 2: Targeted Symbol & Caller Retrieval (FTS5 / AST)]"
if [ "${C_COUNT}" -gt 0 ] || [ "${TOTAL_FILES}" -gt 50 ]; then
    echo "  Tool: TokToken (Single C binary, SQLite FTS5)"
    echo "  Commands:"
    echo "    1. toktoken index:create"
    echo "    2. toktoken search:symbols '<query>' -ck function,class"
    echo "    3. toktoken inspect:symbol '<id>'"
fi
if [ "${TOTAL_FILES}" -gt 0 ]; then
    echo "  Tool: CodeTree MCP"
    echo "  Command: codetree --root ."
fi

# Tier 3 recommendation:
echo ""
echo "[Tier 3: Deep Semantic LSP & Graphs (Type Checking & References)]"
if [ "${PY_COUNT}" -gt 0 ]; then
    echo "  - Python: Use 'pyright' for flow-sensitive typing or 'serena' MCP for LSP refactoring."
fi
if [ "${C_COUNT}" -gt 0 ]; then
    echo "  - C/C++: Use 'clangd' or 'scip-clang' for compiler AST and compile_commands.json."
fi
if [ "${TS_COUNT}" -gt 0 ]; then
    echo "  - TypeScript: Use 'scip-typescript index' for monorepo path alias resolution, or 'vtsls'."
fi
if [ "${RS_COUNT}" -gt 0 ]; then
    echo "  - Rust: Use 'rust-analyzer-mcp' for sub-2ms synchronous MCP queries or 'rust-analyzer scip .'."
fi
if [ "${GO_COUNT}" -gt 0 ]; then
    echo "  - Go: Use 'scip-go index' + 'scip-search symbols' or 'gopls'."
fi
echo "========================================================"
