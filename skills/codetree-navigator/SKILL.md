---
name: codetree-navigator
description: >-
  Guides the AI agent in leveraging CodeTree's 23 structured AST navigation tools
  via Tree-sitter and SQLite to explore codebases without reading full files.
---

# CodeTree: Structured AST Code Navigation MCP Server

CodeTree (`ThinkyMiner/codeTree`) is a Model Context Protocol (MCP) server that empowers AI agents to explore codebases at the AST and symbol node level. Instead of reading whole files (2,000+ tokens), the agent asks targeted questions returning ~80 token nodes (~25x token reduction).

## Supported Languages (11)
Python, TypeScript, JavaScript, Go, Rust, C, C++, Java, C#, Ruby, PHP.

## When to Use This Skill
* When an AI agent needs to inspect a specific method or class without ingesting the whole source file.
* Finding imports, symbol references, function definitions, and file hierarchy.
* Navigating multi-file modules incrementally.

## Setup & Execution

### 1. Launching as MCP Server
In Claude Code, Antigravity, or Cursor:
```json
{
  "mcpServers": {
    "codetree": {
      "command": "codetree",
      "args": ["--root", "."]
    }
  }
}
```
Or run directly via uvx:
```bash
uvx --from mcp-server-codetree codetree --root .
```

## The 23 Tool Capabilities
CodeTree exposes 23 specialized agent tools categorized into:

1. **File & Directory Discovery**:
   - `list_files`: Lists tracked project files.
   - `get_file_tree`: Generates AST-aware directory tree.
2. **Symbol & Outline Retrieval**:
   - `get_outline`: Returns high-level symbols (classes, functions) for a file.
   - `get_symbol`: Extracts the exact AST node and body for a named symbol.
   - `search_symbols`: Fuzzy/exact search for symbol names across the project.
3. **Graph & Cross-References**:
   - `find_references`: Identifies where a symbol is referenced across files.
   - `get_imports`: Extracts imported modules and aliases in a file.
   - `get_callers`: Finds callers of a function within the parsed AST graph.
4. **Targeted Code Slicing**:
   - `get_function_signature`: Returns only parameter types and return type.
   - `get_class_hierarchy`: Lists base classes and implemented interfaces.
