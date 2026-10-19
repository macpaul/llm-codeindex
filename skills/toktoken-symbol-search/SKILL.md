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
Search symbols by name with relevance scoring and centrality ranking:
```bash
# Basic symbol search (compact output)
toktoken search:symbols "auth_verify" -c

# Filter by symbol kind (function, class, struct, method, interface)
toktoken search:symbols "UserSession" -k class,struct

# Filter by language
toktoken search:symbols "connect" -L go -k function

# Enforce strict LLM token budget ceiling (e.g. max 500 tokens)
toktoken search:symbols "database" --token-budget 500

# Control output detail level (compact, standard, full)
toktoken search:symbols "handler" --detail compact

# Scope search strictly to dependencies imported by a specific file
toktoken search:symbols "config" --scope-imports-of src/server.go

# Scope search to files that import a specific file
toktoken search:symbols "logger" --scope-importers-of src/logging.h

# Count matching symbols only
toktoken search:symbols "parse" -n
```

### 2. Full-Text Search (`search:text`)
Search source text across all indexed files:
```bash
# Text search grouped by file with line context
toktoken search:text "FIXME" -g file -C 2

# Regex search (case-sensitive)
toktoken search:text "err := .*\.Close\(\)" -r -s

# Limit search results
toktoken search:text "API_KEY" -l 10
```

### 3. Symbol Co-occurrence (`search:cooccurrence`)
Find symbols that frequently co-occur in the same file to reveal module coupling:
```bash
# Find co-occurrences between two symbols
toktoken search:cooccurrence "verify_token,decode_jwt"
```

### 4. Similar Symbol Discovery (`search:similar`)
Find symbols structurally or semantically similar to a known symbol ID:
```bash
toktoken search:similar "src/auth/jwt.go::VerifyToken#function"
```

### 5. Exploration Suggestions (`suggest`)
Discover high-priority architectural keywords and suggested query prompts:
```bash
toktoken suggest
# Returns top keywords, symbol kind distributions, and example queries
```

## Token Economy Best Practices
1. **Always use `-c` (`--compact`)** when querying in automated agent loops to receive concise JSON.
2. **Combine `-k` (`--kind`)** to eliminate irrelevant variable or chapter definitions when hunting for functions or classes.
3. **Use `--token-budget`** when injecting search results directly into prompting context to prevent context window overflow.
