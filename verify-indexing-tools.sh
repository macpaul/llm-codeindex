#!/usr/bin/env bash
# ==============================================================================
# verify-indexing-tools.sh
# Verification and Diagnostic script for LLM Code Indexing Tools
# Checks presence, path, and version of all surveyed tools
# ==============================================================================

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

printf "\n${BOLD}%-25s %-10s %-35s %-30s${NC}\n" "TOOL" "STATUS" "PATH" "VERSION / INFO"
printf "%s\n" "------------------------------------------------------------------------------------------------------"

check_tool() {
    local name="$1"
    local cmd="$2"
    local version_arg="$3"
    
    if command -v "$cmd" >/dev/null 2>&1; then
        local bin_path
        bin_path="$(command -v "$cmd")"
        local ver
        ver="$("$cmd" $version_arg 2>&1 | head -n 1 | tr -d '\r' | cut -c 1-30)"
        printf "%-25s ${GREEN}%-10s${NC} %-35s %-30s\n" "$name" "[PASS]" "$bin_path" "$ver"
    else
        printf "%-25s ${RED}%-10s${NC} %-35s %-30s\n" "$name" "[MISSING]" "Not found in PATH" "-"
    fi
}

echo -e "\n${CYAN}--- Universal & Multi-Language Symbol / AST Tools ---${NC}"
check_tool "Universal Ctags" "ctags" "--version"
check_tool "TokToken" "toktoken" "--help"
check_tool "Repomix" "repomix" "--version"
check_tool "Tree-sitter CLI" "tree-sitter" "--version"
check_tool "CodeTree MCP" "codetree" "--help"
check_tool "Aider Repo Map" "aider" "--version"

echo -e "\n${CYAN}--- Language Servers & Compiler Backends (LSP) ---${NC}"
check_tool "Clangd (C/C++)" "clangd" "--version"
check_tool "Pyright (Python)" "pyright" "--version"
check_tool "Python LSP (pylsp)" "pylsp" "--version"
check_tool "Gopls (Go)" "gopls" "version"
check_tool "Rust Analyzer (Rust)" "rust-analyzer" "--version"
check_tool "TypeScript Server" "tsserver" "--version"
check_tool "vtsls (TS LSP)" "vtsls" "--version"
check_tool "Serena MCP (Multi)" "serena" "--help"
check_tool "rust-analyzer-mcp" "rust-analyzer-mcp" "--help"

echo -e "\n${CYAN}--- SCIP Code Intelligence Ecosystem ---${NC}"
check_tool "SCIP CLI" "scip" "--version"
check_tool "SCIP TypeScript" "scip-typescript" "--version"
check_tool "SCIP Python" "scip-python" "--version"
check_tool "SCIP Go" "scip-go" "--help"
check_tool "SCIP Clang (C/C++)" "scip-clang" "--version"
check_tool "SCIP Search (Fast)" "scip-search" "--version"

echo -e "\n${CYAN}--- Package & Tool Runners ---${NC}"
check_tool "Astral uv" "uv" "--version"
check_tool "Node.js" "node" "--version"
check_tool "NPM" "npm" "--version"
check_tool "Go compiler" "go" "version"
check_tool "GCC compiler" "gcc" "--version"
check_tool "Cargo (Rust)" "cargo" "--version"

printf "\n%s\n" "======================================================================================================"
