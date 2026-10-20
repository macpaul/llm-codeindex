---
name: toktoken-symbol-search
description: Precision symbol and full-text code retrieval using TokToken SQLite FTS5. Retrieves function, class, and struct definitions within strict token budgets, searches co-occurring symbols, and finds semantically similar identifiers.
---

# TokToken: Precision Symbol & Code Search Skill

TokToken provides lightning-fast symbol-level retrieval backed by SQLite FTS5 and BM25 relevance ranking. It allows AI coding agents to pinpoint exact target symbols without reading large files into prompt context, saving **88% to 99% of tokens**.

## When to Use This Skill
* Use when locating and inspecting specific functions, classes, structs, or methods across a multi-language repository.
* **NEVER** use broad file-reading tools or naive grep when hunting for a specific symbol definition. Reading full 1,000-line files to find a 20-line function consumes thousands of unnecessary context tokens.
* Use when searching for text or regex patterns grouped by file.
* Use to analyze symbol co-occurrence (identifying tightly coupled components).
* Use to find symbols similar in structure or purpose to a given identifier.
* Use `suggest` when exploring an unfamiliar repository to get high-value entry point queries.

## Search CLI Commands

### 1. Symbol Search (`search:symbols`)
Search symbols by name with relevance scoring and centrality ranking (always use `-c` and `-l` in agent workflows):
```bash
# Basic symbol search (compact output, top 5 results)
toktoken search:symbols "auth_verify" -c -l 5

# Filter by symbol kind (function, class, struct, method, interface)
toktoken search:symbols "UserSession" -k class,struct -c -l 5

# Filter by language and path scope
toktoken search:symbols "connect" -L go -k function --filter 'pkg/net/*' -c

# Enforce strict LLM token budget ceiling (e.g. max 500 tokens)
toktoken search:symbols "database" --token-budget 500 -c

# Control output detail level (compact, standard, full)
toktoken search:symbols "handler" --detail compact -c -l 5

# Scope search strictly to dependencies imported by a specific file
toktoken search:symbols "config" --scope-imports-of src/server.go -c

# Scope search to files that import a specific file
toktoken search:symbols "logger" --scope-importers-of src/logging.h -c

# Count matching symbols only (0 tokens of payload)
toktoken search:symbols "parse" -n
```

### 2. Full-Text Search (`search:text`)
Search source text across all indexed files:
```bash
# Text search grouped by file with line context (compact, limit 10)
toktoken search:text "FIXME" -g file -C 2 -c -l 10

# Regex search (case-sensitive) with path filtering
toktoken search:text "err := .*\.Close\(\)" -r -s --filter 'internal/*' -c -l 5

# Limit search results to protect agent context window
toktoken search:text "API_KEY" -c -l 5
```

### 3. Symbol Co-occurrence (`search:cooccurrence`)
Find symbols that frequently co-occur in the same file to reveal module coupling:
```bash
# Find co-occurrences between two symbols (compact)
toktoken search:cooccurrence "verify_token,decode_jwt" -c
```

### 4. Similar Symbol Discovery (`search:similar`)
Find symbols structurally or semantically similar to a known symbol ID:
```bash
toktoken search:similar "src/auth/jwt.go::VerifyToken#function" -c -l 5
```

### 5. Exploration Suggestions (`suggest`)
Discover high-priority architectural keywords and suggested query prompts:
```bash
toktoken suggest -c
# Returns top keywords, symbol kind distributions, and example queries
```

## Token Economy Best Practices for Autonomous Agents

1. **Mandatory `-c` (`--compact`)**: Never execute `toktoken` without `-c` in agent workflows. Uncompacted JSON contains 45% whitespace and indentation overhead that is repeatedly re-ingested across multi-turn history.
2. **Mandatory `-l 5` or `-l 10` (Result Limits)**: Unbounded queries return 50 symbols. In multi-turn tasks, 50 symbols ingested in Turn 1 costs 5x more because of context compounding on every subsequent turn.
3. **Pre-Filter by Path (`--filter <glob>`)**: Always scope searches using `--filter` (e.g. `--filter 'drivers/usb/core/*'`) to prune vendor-specific noise inside SQLite before tokens enter the context window.
4. **Combine `-k` (`--kind`)**: Eliminate noisy variables and chapters when looking for classes or functions (`-k function,class,struct`).
5. **Use `--token-budget`**: Constrain outputs to strict ceiling limits (e.g. `--token-budget 400`).
6. **Always Index Unindexed or Modified Files First (`index:file`)**: When files are newly created or modified during coding, **always run `toktoken index:file <path>` first** before searching or inspecting symbols, ensuring search hits are never stale.
7. **Steer Away from Whole File Reads**: Once a symbol is located via `search:symbols`, never dump or cat the whole file. Steer directly to `toktoken inspect:symbol "<path>::<symbol>" -c` to extract the definition in ~100 tokens.
