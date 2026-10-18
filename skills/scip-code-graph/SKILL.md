---
name: scip-code-graph
description: >-
  Creates and queries language-agnostic SCIP Protobuf code intelligence graphs using
  scip-search, scip-go, scip-typescript, scip-python, and scip-clang for instant
  sub-millisecond symbol lookups in large monorepos.
---

# SCIP: Code Intelligence Protocol & Graph Search

The Sourcegraph Code Intelligence Protocol (SCIP) is a modern, language-agnostic Protobuf format for code intelligence. By offloading compilation analysis to an index step, SCIP graphs can be queried with sub-millisecond cold start times using `scip-search`.

## When to Use This Skill
* Monorepos with multiple languages or packages.
* TypeScript/JavaScript projects with complex `tsconfig.json` path aliases (`@/`) where standard AST or regex tools lose track of imported symbols.
* CI/CD environments where pre-indexed code knowledge graphs can be consumed directly by AI agents without spinning up heavy LSP servers.

## Workflow

### 1. Generate the SCIP Index
Run the appropriate indexer for the language or use `./scripts/build_scip_index.sh`:

* **Go**:
  ```bash
  scip-go index --output index.scip
  ```
* **TypeScript / JavaScript**:
  ```bash
  scip-typescript index --output index.scip
  ```
* **Python**:
  ```bash
  scip-python index . --project-name=myproject --output index.scip
  ```
* **C / C++**:
  ```bash
  scip-clang --compdb-path=compile_commands.json --index-file=index.scip
  ```
* **Rust**:
  ```bash
  rust-analyzer scip . --output index.scip
  ```

### 2. Querying with `scip-search` (High-Speed CLI)

`scip-search` reads pre-generated `.scip` Protobuf files in milliseconds without requiring language servers or compilers to be running:

#### Find Symbols
```bash
scip-search symbols --index index.scip --name SymbolName
# Output format: JSON or nested JSON for automated parsing
scip-search symbols --index index.scip --name SymbolName --json
```

#### Find References
```bash
scip-search references --index index.scip --name SymbolName --location-only
```

#### Find Callers & Callees
```bash
scip-search callers --index index.scip --name SymbolName --markdown
scip-search callees --index index.scip --name SymbolName --markdown
```

#### Impact Analysis
```bash
scip-search impact --index index.scip --name SymbolName --markdown
```

### 3. Inspecting Raw SCIP Protobuf
Use the `scip` CLI to inspect, validate, or print the raw graph:
```bash
scip print --json index.scip | head -n 50
scip stats index.scip
```
