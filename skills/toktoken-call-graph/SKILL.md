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
# Find callers of a specific symbol
toktoken find:callers "src/db.c::db_connect#function"

# Find callers using compact JSON output
toktoken find:callers "src/auth/jwt.go::VerifyToken#function" -c
```

### 2. Find Identifier References (`find:references`)
Find all import references and usage locations of an identifier:
```bash
# Locate all references to a struct, class, or constant
toktoken find:references "src/config.h::DatabaseConfig#struct"
```

### 3. Find File Importers (`find:importers`)
Identify every file in the repository that imports or includes a given file:
```bash
# Find all modules importing a header or package
toktoken find:importers src/utils/logger.go

# Check whether importers themselves have other importers
toktoken find:importers src/common/types.h --has-importers
```

### 4. Dead Code Detection (`find:dead`)
Identify unused, unreferenced functions, classes, and variables:
```bash
# Scan for all unreferenced symbols across the codebase
toktoken find:dead

# Exclude test files so test fixtures aren't falsely flagged as production callers
toktoken find:dead --exclude-tests

# Output dead code candidates as compact JSON
toktoken find:dead --exclude-tests -c
```

## Best Practices for Safe Refactoring
1. **Pre-edit Caller Check**: Always run `toktoken find:callers "<symbol_id>"` before modifying an existing function's signature or parameters.
2. **Verify Import Boundaries**: Before moving a file or package, run `toktoken find:importers "<file>"` to calculate the blast radius on surrounding files.
3. **Dead Code Verification**: Combine `toktoken find:dead --exclude-tests` with git blame/history to safely prune obsolete logic.
