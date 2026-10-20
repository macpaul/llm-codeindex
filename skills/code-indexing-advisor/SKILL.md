---
name: code-indexing-advisor
description: >-
  Analyzes project structure across Python, C/C++, TypeScript/JavaScript, Rust,
  and Go to select and configure the optimal code indexing strategy (AST compression,
  symbol FTS, SCIP graph, or full LSP) to minimize token consumption and eliminate hallucinations.
---

# Code Indexing Advisor & Strategy Router

Use this skill when exploring an unfamiliar codebase, preparing context for an AI coding task, or planning large refactors without consuming excessive LLM tokens.

## 1. Quick Project Assessment

Run the built-in scanner script to inspect project size, language breakdown, and build manifests:

```bash
./skills/code-indexing-advisor/scripts/analyze_project.sh .
```

## 2. The 3-Tier Indexing Decision Framework

Always choose the lowest-cost tier that satisfies the engineering objective:

```
                  ┌─────────────────────────────────────┐
                  │ Does the task require cross-file    │
                  │ exact type inference or renaming?   │
                  └──────────────────┬──────────────────┘
                                     │
                     YES ────────────┴──────────── NO
                      │                             │
                      ▼                             ▼
        ┌───────────────────────────┐ ┌───────────────────────────┐
        │ Tier 3: Deep Semantic LSP │ │ Does the agent need a     │
        │ - Serena MCP              │ │ broad architectural map?  │
        │ - Pyright / rust-analyzer │ └─────────────┬─────────────┘
        │ - SCIP (scip-search)      │               │
        └───────────────────────────┘       YES ────┴──── NO
                                             │             │
                                             ▼             ▼
                                ┌─────────────────┐ ┌─────────────────┐
                                │ Tier 1: AST Map │ │ Tier 2: FTS5    │
                                │ - Repomix       │ │ - TokToken      │
                                │   (--compress)  │ │ - CodeTree MCP  │
                                │ - Aider RepoMap │ │ (88-99% savings)│
                                └─────────────────┘ └─────────────────┘
```

## 3. Workflow by Language

### Python Projects
* **Small to Medium**: Use `toktoken index:create` for symbol search; use `repomix --compress` for global overview.
* **Large / Typed**: When dealing with PEP 695 generics or flow-sensitive typing (`isinstance(...)`), trigger `pyright` or connect `serena` MCP.

### C / C++ Projects
* **Core Recommendation**: Run `toktoken index:create`. TokToken indexes 7.4M symbols in ~170s and delivers 96-99% token reduction.
* **LSP**: Ensure `compile_commands.json` exists for `clangd` or index with `scip-clang`.

### TypeScript / Node.js Projects
* **Monorepos & Path Aliases (`@/*`)**: Standard AST tools fail to resolve path aliases. Run `scip-typescript index` and query with `scip-search`.
* **General Indexing**: Use `repomix --compress` for initial onboarding.

### Rust Projects
* **Lightweight Agent Queries**: Prefer `rust-analyzer-mcp` (synchronous channel) over heavy asynchronous wrappers.
* **Batch Intelligence**: Run `rust-analyzer scip .` to produce `.scip` graph, queried via `scip-search`.

### Go Projects
* Go’s uniform syntax makes it ideal for lightweight AST indexing. Run `scip-go index` and query via `scip-search`, or use `toktoken`.

## 4. Token Budget Guidelines
* **Target Token Usage**: Keep exploratory prompts below 3,000 tokens.
* **Anti-Pattern**: Never use `cat` or read entire files > 500 lines just to inspect a single function signature. Use `toktoken inspect:symbol <id>` or CodeTree instead.

## 5. The Agent Lifecycle Token Law: Avoiding the 1.7x Multi-Turn Penalty

In autonomous multi-turn agent sessions (Claude, Cursor, Cline, Antigravity), tool tokens are **not** consumed in isolation. They compound quadratically ($O(T^2)$) across conversation history:

$$\text{Total Lifetime Tokens} = \sum_{t=1}^{T} \Big( \text{BasePrompt} + \text{ToolSchemas} + \sum_{k=1}^{t-1} \text{History}_k \Big)$$

### The 1.7x Naive MCP Pitfall vs. 0.66x Optimized CLI Reality
Empirical benchmark data across complete multi-turn tasks (Das U-Boot firmware porting):

| Agent Architecture | Base Schemas | Total Turns | Lifetime Tokens | Cost Ratio vs Grep |
| :--- | :---: | :---: | :---: | :---: |
| **Grep Surgical Agent** (Expert human baseline) | 176 tokens | 7 turns | 12,652 tokens | 1.00x (Base) |
| **Grep Naive Agent** (LLM falls back to `cat` header) | 176 tokens | 7 turns | 51,091 tokens | 4.04x (Severe bloat) |
| **Naive TokToken MCP Agent** (20 MCP tools, pretty JSON) | 636 tokens | 7 turns | 19,660 tokens | **1.55x ~ 1.7x (Claude observation confirmed)** |
| **Optimized TokToken CLI Agent** (Minimal CLI schema, `-c`) | **187 tokens** | **6 turns** | **8,375 tokens** | **0.66x (34% savings vs Grep!)** |

### Golden Rules for Agent Token Efficiency:
1. **CLI-First Tool Dispatch**: Avoid exposing 20+ fine-grained MCP tool schemas into the agent's system prompt. Instead, dispatch `toktoken` through generic command execution (`run_command`), slashing base prompt overhead from 636 to 187 tokens per turn.
2. **Always Enforce Compact Output (`-c`)**: Uncompacted JSON contains 45% whitespace and formatting overhead. Always pass `-c` to all `toktoken` commands in agent loops.
3. **Always Bound Result Limits (`-l 5` or `-l 10`)**: Unbounded symbol searches return 50 items. An extra 1,000 tokens returned on Turn 1 costs 5,000+ tokens in repeated history across 5 subsequent turns!
4. **Use 1-Shot Symbol Targeting (`inspect:symbol`) Over Whole File Reads**: `grep` requires 2 turns (`grep` line number -> `sed` line range), while `cat` dumps 10,000+ tokens. `toktoken inspect:symbol` extracts the complete struct/function body in **1 turn** (~100 tokens), eliminating round-trips and cutting quadratic context growth by 98.9%.
5. **Path Filtering Before Ingestion (`--filter`)**: Filter out non-target SoC/board directories inside SQLite FTS5 *before* text reaches the LLM context window.
6. **Always Index Unindexed or Modified Files First (`index:file`)**: When encountering a newly created, unindexed, or modified file, **always run `toktoken index:file <file_path>` first** before searching or inspecting symbols. Do not search stale or unindexed files.
7. **Strict Steering Away from Whole File Reads**: Never read whole files (>100 lines) via `cat` or `read_file` to find interfaces or structs. Steer agents to `toktoken inspect:symbol`, `toktoken inspect:outline` (to list symbols first if name is unknown), or `toktoken inspect:file --lines`.
