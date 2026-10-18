---
name: toktoken-index
description: >-
  Provides instructions and workflows for using TokToken to index and search codebases
  (especially C, C++, Python, Go, and multi-language projects) saving 88%-99% tokens on
  symbol lookups, call hierarchy, and import graphs.
---

# TokToken: High-Performance Symbol & Code Indexer

TokToken is a single-binary, C-native indexing tool built on top of `universal-ctags` and SQLite FTS5. It indexes 49 languages without modifying project files, storing all indexes under `~/.cache/toktoken/`.

## When to Use This Skill
* Exploring unfamiliar codebases (especially C/C++, Go, Python, PHP, Java).
* Finding specific functions, classes, structs, or methods without reading massive files into the prompt.
* Tracing symbol dependencies, callers, dead code, or blast radiuses.

## Workflow & Commands

### 1. Index the Codebase
Index once at project initialization. Re-indexing is incremental and hash-based:
```bash
toktoken index:create
```

### 2. Search Symbols by Name
Find functions, classes, and methods with relevance scoring and centrality ranking:
```bash
toktoken search:symbols "auth" -ck class,method,function
```
* Use `-c` for compact output to minimize token output.
* Use `-k` to filter by symbol kinds: `function`, `method`, `class`, `struct`, `interface`, `typedef`.

### 3. Inspect Exact Symbol Implementation
Retrieve only the implementation code of the target symbol:
```bash
toktoken inspect:symbol "src/auth.c::auth_verify_token#function"
```

### 4. File Outline (Cheaper than Reading Files)
Inspect the high-level outline and hierarchy of a file:
```bash
toktoken inspect:outline src/server.c
```

### 5. Dependency & Call Graph Tracing
```bash
# Find callers of a symbol
toktoken find:callers "src/db.c::db_connect#function"

# Find importers of a module
toktoken find:importers src/config.h

# Analyze blast radius of changes
toktoken analyze:blast-radius src/core.c
```

### 6. MCP Server Mode
To attach TokToken as an interactive MCP server for AI coding agents:
```bash
toktoken serve
```
Add to `mcp_config.json`:
```json
{
  "mcpServers": {
    "toktoken": {
      "command": "toktoken",
      "args": ["serve"]
    }
  }
}
```
