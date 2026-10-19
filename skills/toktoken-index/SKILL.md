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

## MCP Server Integration (Claude Code, Antigravity, Cursor, Codex)

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

## Performance & Token Economy
* **Index Speed**: 10,000 files parsed in ~1–2 seconds. Linux kernel (7.4M symbols) in ~170s.
* **Storage**: Completely non-invasive; zero files created in project workspace.
* **Output Economy**: Default compact JSON minimizes context footprint.
