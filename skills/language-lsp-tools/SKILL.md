---
name: language-lsp-tools
description: >-
  Language-specific deep indexing and LSP configuration for Python (Pyright flow-sensitive typing),
  C/C++ (clangd), Rust (rust-analyzer & rust-analyzer-mcp), Go (gopls), and Node.js/TypeScript (vtsls & path aliases).
---

# Language-Specific LSP & Compiler Indexing Runbook

Detailed configuration and best practices for integrating compiler-grade Language Servers into AI coding agents across Python, C/C++, Node.js/TypeScript, Rust, and Go.

## 1. Python: Pyright & Flow-Sensitive Typing

Pyright offers flow-sensitive type analysis (tracking narrowing inside `if isinstance(x, int):` blocks) and PEP 695 type parameters.

### Setup & Configuration
Create `pyrightconfig.json` at project root:
```json
{
  "include": ["src"],
  "venvPath": ".",
  "venv": ".venv",
  "pythonVersion": "3.12",
  "typeCheckingMode": "standard"
}
```
* **Execution**:
  ```bash
  # Check diagnostics
  pyright src/
  # Run as language server daemon
  pyright-langserver --stdio
  ```

---

## 2. C / C++: Clangd

Clangd requires a compilation database (`compile_commands.json`) to understand include paths, macro defines, and compilation flags.

### Generating `compile_commands.json`
* **CMake**: `cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -B build` (and symlink `ln -s build/compile_commands.json .`)
* **Bear (Make)**: `bear -- make`
* **Execution**:
  ```bash
  clangd --background-index --compile-commands-dir=.
  ```

---

## 3. Node.js & TypeScript: Path Aliases & Monorepos

Modern monorepos (Turborepo, Yarn/pnpm workspaces) use path aliases that break simple regex searches.

### Configuring `tsconfig.json`
```json
{
  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      "@/*": ["src/*"],
      "@components/*": ["src/components/*"]
    }
  }
}
```
* **LSP Daemon**:
  Use `typescript-language-server --stdio` or `vtsls --stdio`.
  When indexing statically, always use `scip-typescript index`.

---

## 4. Rust: rust-analyzer & rust-analyzer-mcp

### Synchronous Channel Optimization
Standard Tokio async MCP servers introduce context-switching latency for short-lived AI agent subprocesses. Use `rust-analyzer-mcp` for zero-contention synchronous channel communication:
```json
{
  "mcpServers": {
    "rust-analyzer": {
      "command": "rust-analyzer-mcp"
    }
  }
}
```

### Memory Management for Large Rust Projects
In `.cargo/config.toml` or `rust-analyzer` settings:
* Disable proc-macro expansion if memory exceeds 4GB:
  ```json
  { "rust-analyzer.procMacro.enable": false }
  ```

---

## 5. Go: Gopls

Go features uniform package definitions and transparent imports.
* **Initialization**: Ensure `go.mod` exists.
* **Execution**:
  ```bash
  gopls -mode=stdio
  ```
* For instant static queries without running `gopls`, compile with `scip-go index` and query via `scip-search`.
