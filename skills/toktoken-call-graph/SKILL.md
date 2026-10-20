---
name: toktoken-call-graph
description: Code dependency tracing, call hierarchy, and dead code detection using TokToken. Identifies all callers of functions, import references, file importers, and unreferenced/dead symbols before refactoring.
---

# TokToken: Call Hierarchy, References & Dead Code Skill

TokToken maps project-wide call hierarchies and dependency references in sub-millisecond speeds. It allows AI agents to perform safe refactoring, trace impact paths, and eliminate dead code without running heavy LSP daemons.

## When to Use This Skill
* Use when preparing to modify or rename a function, method, or class signature: check all call sites first with `find:callers` or `find:references`.
* Use when restructuring directories or refactoring modules: check which files import a target file using `find:importers`.
* Use during codebase audits and cleanup tasks to detect unreferenced and dead code using `find:dead`.
* Use to prevent breaking dependent modules across complex multi-language repositories.

## Dependency & Reference CLI Commands

### 1. Find Callers (`find:callers`)
Find all functions and methods across the codebase that call a target function:
```bash
# Find callers of a specific symbol (compact output, limit 5)
toktoken find:callers "src/db.c::db_connect#function" -c -l 5

# Find callers using compact JSON output with filter
toktoken find:callers "src/auth/jwt.go::VerifyToken#function" --filter 'cmd/*' -c -l 5
```

### 2. Find Identifier References (`find:references`)
Find all import references and usage locations of an identifier:
```bash
# Locate all references to a struct, class, or constant (compact, limit 10)
toktoken find:references "src/config.h::DatabaseConfig#struct" -c -l 10
```

### 3. Find File Importers (`find:importers`)
Identify every file in the repository that imports or includes a given file:
```bash
# Find all modules importing a header or package (compact)
toktoken find:importers src/utils/logger.go -c -l 10

# Check whether importers themselves have other importers
toktoken find:importers src/common/types.h --has-importers -c
```

### 4. Dead Code Detection (`find:dead`)
Identify unused, unreferenced functions, classes, and variables:
```bash
# Scan for all unreferenced symbols across the codebase (compact)
toktoken find:dead --exclude-tests -c -l 20

# Output dead code candidates as compact JSON
toktoken find:dead --exclude-tests -c
```

## Best Practices for Safe Refactoring in Autonomous Agents
1. **Always Use `-c` and Limit `-l`**: Large caller lists can return 100+ functions. In multi-turn agent sessions, an unconstrained caller response inflates conversation history across all subsequent turns.
2. **Pre-edit Caller Check**: Always run `toktoken find:callers "<symbol_id>" -c -l 10` before modifying an existing function's signature or parameters.
3. **Verify Import Boundaries**: Before moving a file or package, run `toktoken find:importers "<file>" -c` to calculate the blast radius on surrounding files.
3. **Dead Code Verification**: Combine `toktoken find:dead --exclude-tests` with git blame/history to safely prune obsolete logic.
