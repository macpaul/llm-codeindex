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
