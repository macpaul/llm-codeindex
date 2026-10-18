---
name: serena-lsp
description: >-
  Employs Serena MCP to provide full IDE-grade Language Server capabilities across
  40+ languages (Go to Definition, Find References, Workspace Rename, Replace Symbol Body, and Type Diagnostics).
---

# Serena: Semantic IDE-Grade LSP for AI Coding Agents

Serena (`oraios/serena`) connects AI coding agents to real language server backends (Pyright, rust-analyzer, clangd, gopls, vtsls) via the Model Context Protocol (MCP). It moves beyond naive string matching and gives the agent compiler-verified accuracy.

## When to Use This Skill
* Executing cross-file refactoring (e.g. renaming a symbol across 20 files without missing any references).
* Refactoring complex Python code where duck-typing or PEP 695 generics deceive standard regex or AST tools.
* Verifying type errors and diagnostics before concluding a code change.
* Safely replacing a function implementation via `ReplaceSymbolBodyTool`.

## Installation & Initialization
```bash
# Verify installation
serena --version

# Initialize Serena for current project
serena init
```

## Running the Serena MCP Server
Add Serena to your agent's MCP configuration (`mcp_config.json`):
```json
{
  "mcpServers": {
    "serena": {
      "command": "serena",
      "args": ["start-mcp-server"]
    }
  }
}
```

## Core Semantic Tool Suite

### 1. Semantic Code Retrieval
* `find_symbol`: Locate exact symbol definition using language compiler index.
* `get_symbol_overview`: File symbol outline.
* `find_referencing_symbols`: Compiler-level cross-file reference discovery.
* `get_diagnostics`: Returns exact compiler/linter errors and warnings.

### 2. Semantic Code Editing & Refactoring
* `rename_symbol`: Safely renames a symbol, updating every reference across the codebase atomically.
* `replace_symbol_body`: Replaces the body of a specific function or method without altering signature or adjacent code.
* `insert_after_symbol` / `insert_before_symbol`: Inserts code precisely positioned relative to an AST symbol.

### 3. Agent Memories
Serena maintains persistent architectural rules in `.serena/memories/` across agent sessions.
