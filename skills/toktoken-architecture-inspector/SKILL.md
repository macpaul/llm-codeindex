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

### 1. Symbol Context Bundle (`inspect:bundle`)
The ultimate context tool for AI agents. Extracts the target symbol implementation, all imports used by the file, and the parent file outline in one token-optimized JSON object:
```bash
# Retrieve full context bundle for a target symbol
toktoken inspect:bundle "src/auth/jwt.go::VerifyToken#function"

# Include all callers directly inside the context bundle
toktoken inspect:bundle "src/auth/jwt.go::VerifyToken#function" --include-callers
```

### 2. Blast Radius Analysis (`inspect:blast`)
Forecast the ripple effect of changing or deleting a symbol:
```bash
# Analyze impact blast radius of a symbol
toktoken inspect:blast "src/db/pool.go::GetConnection#function"

# Limit blast radius traversal depth (e.g. depth 2)
toktoken inspect:blast "src/core/config.h::GlobalConfig#struct" -d 2
```

### 3. Circular Import Cycle Detection (`inspect:cycles`)
Detect problematic circular dependencies across modules:
```bash
# Detect all import cycles in the repository
toktoken inspect:cycles

# Focus strictly on cross-directory import cycles
toktoken inspect:cycles --cross-dir

# Filter cycles by minimum path length
toktoken inspect:cycles --min-length 3
```

### 4. Transitive Dependency Graph (`inspect:dependencies`)
Trace the complete tree of modules imported by a file:
```bash
# Trace transitive dependencies for a file
toktoken inspect:dependencies src/main.go
```

### 5. Symbol & Class Hierarchy (`inspect:hierarchy`)
Examine class and struct hierarchies, nested functions, and methods:
```bash
# Show structural hierarchy within a module
toktoken inspect:hierarchy src/models/user.go
```

### 6. File Outline (`inspect:outline`)
Inspect all symbols declared in a file without reading full lines of implementation:
```bash
# Extract high-level symbol outline
toktoken inspect:outline src/server/http.go
```

### 7. File Tree Navigation (`inspect:tree`)
Inspect indexed repository tree with depth controls:
```bash
# View top 2 levels of indexed repository tree
toktoken inspect:tree -d 2
```

### 8. Exact Symbol Code & Line Slicing (`inspect:symbol` & `inspect:file`)
```bash
# Inspect only the exact implementation of a symbol
toktoken inspect:symbol "src/utils.go::HashPassword#function"

# Read specific line ranges from a file
toktoken inspect:file src/main.go --lines 20-50
```

## Token Economy Best Practices
1. **Prefer `inspect:bundle` over reading full files**: In a 2,000-line file, inspecting a 30-line function with `inspect:bundle` costs ~300 tokens, whereas reading the full file costs ~8,000 tokens (**96% token savings**).
2. **Always check `inspect:blast` before large refactors**: Avoid breaking downstream consumers by inspecting the blast radius depth.
3. **Use `inspect:outline` first**: Outline a file first to discover exact symbol IDs, then use `inspect:symbol` on the target.
