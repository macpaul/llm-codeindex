---
name: toktoken-index
description: Lifecycle management and indexing engine for TokToken. Detects codebases, builds hash-based incremental indexes, clones and indexes GitHub repositories, manages cache and project registries, and launches the MCP stdio server.
---

# TokToken: Codebase Indexing & Lifecycle Management

TokToken is a single-binary, C-native indexing tool built on top of `universal-ctags` and SQLite FTS5. It indexes 49 programming languages in seconds without modifying project files, storing all indexes under `~/.cache/toktoken/`.

## When to Use This Skill
* Use when initializing or onboarding an AI coding agent (Claude Code, Antigravity, Cursor, Codex) onto an unfamiliar local or remote codebase.
* Use to detect whether a workspace contains supported source code and requires indexing.
* Use to perform hash-based incremental re-indexing after modifying or adding files.
* Use to clone and immediately index a public GitHub repository without manual git clone overhead.
* Use to inspect global indexing statistics, list all cached projects, or clear caches.
* Use to launch or configure TokToken's stdio Model Context Protocol (MCP) server.

## Indexing CLI Commands

### 1. Codebase Detection
Quickly detect whether a target folder is a code repository and check index status:
```bash
toktoken codebase:detect .
# Outputs JSON: {"is_codebase":true, "has_index":false, "action":"index:create"}
```

### 2. Create Project Index
Index the codebase. Creates an optimized SQLite FTS5 database in `~/.cache/toktoken/`:
```bash
# Index current directory
toktoken index:create

# Index specific project directory
toktoken index:create /path/to/project

# Index with language filter and max file limits
toktoken index:create --languages python,go,rust -m 50000

# Full indexing (disable smart filters)
toktoken index:create --full

# Index with diagnostic telemetry (JSONL to stderr)
toktoken index:create -X
```

### 3. Incremental Index Update
Re-index only modified files using fast content hash comparison:
```bash
# Update existing index in milliseconds
toktoken index:update

# Reindex a single modified file
toktoken index:file src/controller/auth.go
```

### 4. Index Remote GitHub Repositories
Clone and immediately index any GitHub repository into cache for instant agent analysis:
```bash
# Clone and index remote repository
toktoken index:github mauriziofonte/toktoken

# List all cloned GitHub repositories
toktoken repos:list

# Remove a specific cloned repository
toktoken repos:remove mauriziofonte/toktoken

# Clear all cloned repositories
toktoken repos:clear
```

### 5. Statistics & Cache Management
```bash
# Show current project index stats (file count, symbol count, kinds, languages)
toktoken stats

# List all indexed projects in the local cache
toktoken projects:list

# Clear the index cache for the current or all projects
toktoken cache:clear
```

## MCP Server Integration vs. CLI Dispatch: The Agent Efficiency Trade-Off

TokToken natively implements the Model Context Protocol (MCP) exposing 27 tools over stdio:
```bash
toktoken serve
```

### Global MCP Configuration (`mcp_config.json`)
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

### ⚠️ Critical Agent Lifecycle Warning: Schema Bloat vs. CLI Dispatch
* **The 1.7x Multi-Turn Penalty with Full MCP**:
  Registering 27 separate MCP tools injects ~3,500–4,000 tokens of JSON schema into the LLM system prompt on **every single turn**. Across a 7-turn refactoring or porting session, tool schemas alone consume **25,000+ tokens** of pure overhead!
* **The Recommended High-Efficiency Pattern (CLI-First Dispatch)**:
  Instead of declaring 27 individual MCP tools, configure the agent to invoke `toktoken` through its generic shell execution tool (`run_command` / `bash`).
  * **System prompt schema footprint**: Drops from ~4,000 tokens to ~180 tokens (**-95% schema overhead**).
  * **Always pass `-c`**: Enforce compact output (`toktoken search:symbols "..." -c -l 5`).
  * **Result**: Achieves **0.66x of traditional grep's total token cost** (-34% savings over expert grep, -84% savings over naive grep).

## Agent Steering Rules: Unindexed Files & Whole File Reads

### 1. Mandatory Pre-Indexing for Unindexed or Modified Files (`index:file`)
* **When an agent creates, modifies, or encounters an unindexed file**:
  * **Always run `toktoken index:file <path/to/file>` first** before searching, inspecting symbols, or tracing callers in that file.
  * Querying unindexed files without running `index:file` leads to failed searches, missing symbols, or stale offset lookups.
  * Example:
    ```bash
    # Index newly added or edited driver before inspection:
    toktoken index:file drivers/dfu/dfu_ufs.c
    toktoken inspect:symbol "drivers/dfu/dfu_ufs.c::dfu_fill_entity_ufs#function" -c
    ```
* **After git operations or batch edits**:
  * Run `toktoken index:update` to synchronize the SQLite FTS5 database across all modified files in milliseconds.

### 2. Strictly Prohibit Whole File Reads — Steer to `inspect:symbol`
* **Anti-Pattern**: Agents should **NEVER** run `cat`, `read_file`, or unbounded line dumps on files > 100 lines just to inspect a function, class, or struct. Reading full 1,000+ line C headers consumes 8,000–10,000 tokens per call and compounds quadratically.
* **The Steering Formula**:
  * If symbol name is known: `toktoken inspect:symbol "<path>::<symbol>" -c` (costs ~100 tokens, 98.9% savings).
  * If symbol name is unknown: `toktoken inspect:outline <path> -c` (costs ~100 tokens to view symbol table), then inspect the target symbol.
  * If specific lines are needed: `toktoken inspect:file <path> --lines <start>-<end> -c`.

## Performance & Token Economy
* **Index Speed**: 10,000 files parsed in ~1–2 seconds. Linux kernel (7.4M symbols) in ~170s.
* **Storage**: Completely non-invasive; zero files created in project workspace.
* **Incremental File Indexing**: Use `toktoken index:file <file>` for instant ~10ms indexing of non-default files (such as `.defconfig` or `.dts`).
* **Output Economy**: Always pass `-c` (`--compact`) to strip whitespace and indentation in automated agent loops.
