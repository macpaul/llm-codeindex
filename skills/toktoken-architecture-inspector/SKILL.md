---
name: toktoken-architecture-inspector
description: Deep structural code analysis and impact forecasting using TokToken. Extracts all-in-one symbol context bundles, calculates refactoring blast radius, traces transitive dependency trees, and detects circular import cycles.
---

# TokToken: Architecture Inspection, Context Bundling & Blast Radius Skill

TokToken provides advanced architectural diagnostics and surgical inspection tools. It allows AI coding agents to extract complete symbol context bundles, calculate refactoring blast radii, detect circular import cycles, and inspect file outlines without loading entire files into working memory.

## When to Use This Skill
* Use `inspect:bundle` whenever an agent needs to understand a function or class in depth: it returns the symbol's implementation, the imports it relies on, and the outline of its parent file in a single compact call.
* Use `inspect:blast` before executing non-trivial refactorings or signature changes to preview the exact ripple effect and affected depth.
* Use `inspect:cycles` during architecture audits or build-time troubleshooting to detect circular imports.
* Use `inspect:dependencies` to trace transitive import graphs of modules.
* Use `inspect:outline` to view a file's structure and symbols before deciding whether to inspect full code.
* Use `inspect:hierarchy` to understand class/struct inheritance and interface implementations.
* Use `inspect:file` with `--lines` to read surgical line slices instead of whole files.

## Inspection CLI Commands

### 1. Exact Symbol Code Extraction (`inspect:symbol`) - The Premier Agent Tool
Extract the exact, isolated implementation of a function, struct, class, or method in a single shot (always use `-c`):
```bash
# Inspect only the exact implementation of a symbol (compact JSON)
toktoken inspect:symbol "src/utils.go::HashPassword#function" -c

# Extract complex C struct definition from headers in ~100 tokens (avoids 10k token cat disaster)
toktoken inspect:symbol "include/efi_loader.h::efi_capsule_update_info#class" -c
```
> **Agent Efficiency Note**: Traditional `grep` requires 2 turns (Turn 1: grep line number -> Turn 2: sed line range). `toktoken inspect:symbol` extracts the complete struct/function body in **1 turn**, saving an entire round-trip and preventing quadratic history compounding!

### 2. Surgical Line Slicing (`inspect:file`)
Read targeted line slices instead of whole files:
```bash
# Read specific line ranges from a configuration or file
toktoken inspect:file configs/genio_720_evk_ufs_defconfig --lines 125-145 -c
```

### 3. Symbol Context Bundle (`inspect:bundle`)
Extracts the target symbol implementation, all imports used by the file, and the parent file outline in one compact call:
```bash
# Retrieve full context bundle for a target symbol (compact)
toktoken inspect:bundle "src/auth/jwt.go::VerifyToken#function" -c

# Include all callers directly inside the context bundle
toktoken inspect:bundle "src/auth/jwt.go::VerifyToken#function" --include-callers -c
```

### 4. Blast Radius Analysis (`inspect:blast`)
Forecast the ripple effect of changing or deleting a symbol:
```bash
# Analyze impact blast radius of a symbol
toktoken inspect:blast "src/db/pool.go::GetConnection#function" -c

# Limit blast radius traversal depth (e.g. depth 2)
toktoken inspect:blast "src/core/config.h::GlobalConfig#struct" -d 2 -c
```

### 5. Circular Import Cycle Detection (`inspect:cycles`)
Detect problematic circular dependencies across modules:
```bash
# Detect all import cycles in the repository (compact)
toktoken inspect:cycles -c

# Focus strictly on cross-directory import cycles
toktoken inspect:cycles --cross-dir -c

# Filter cycles by minimum path length
toktoken inspect:cycles --min-length 3 -c
```

### 6. Transitive Dependency Graph (`inspect:dependencies`)
Trace the complete tree of modules imported by a file:
```bash
# Trace transitive dependencies for a file (compact)
toktoken inspect:dependencies src/main.go -c
```

### 7. Symbol & Class Hierarchy (`inspect:hierarchy`)
Examine class and struct hierarchies, nested functions, and methods:
```bash
# Show structural hierarchy within a module (compact)
toktoken inspect:hierarchy src/models/user.go -c
```

### 8. File Outline (`inspect:outline`)
Inspect all symbols declared in a file without reading full lines of implementation:
```bash
# Extract high-level symbol outline (compact)
toktoken inspect:outline src/server/http.go -c
```

### 9. File Tree Navigation (`inspect:tree`)
Inspect indexed repository tree with depth controls:
```bash
# View top 2 levels of indexed repository tree
toktoken inspect:tree -d 2
```

## Token Economy Best Practices for Autonomous Agents
1. **Prefer `inspect:symbol` over `inspect:bundle` or `inspect:outline`**: If you only need to view or edit a single function or struct, `inspect:symbol` returns 50-200 tokens. `inspect:bundle` returns imports and outlines (500-1,500 tokens). Over multiple turns, that extra context compounds.
2. **Never Dump Full Header Files**: In massive subsystem headers (e.g., `include/usb.h`, `include/efi_loader.h`), reading the file costs 9,000+ tokens. `inspect:symbol` isolates the target in **107 tokens** (a **98.9% token reduction**).
3. **Always Pass `-c` (`--compact`)**: Strips formatting spaces from JSON output to prevent token bloating.
