# Code Indexing and Retrieval Tools for LLMs: Comprehensive Survey & Deployment Guide

## 1. Executive Summary & Paradigm Overview

In the era of massive context windows (e.g., Gemini 1M–2M tokens, Claude 200K, GPT-4o 128K), feeding entire repositories into an AI coding assistant is a costly anti-pattern. Beyond prohibitive API token costs, dumping large codebases triggers severe **Attention Dilution** and the **"Lost in the Middle"** phenomenon, impairing the LLM's reasoning over function signatures, type boundaries, and cross-module dependencies.

To achieve **zero-hallucination, cost-effective autonomous coding**, modern engineering combines three complementary indexing paradigms:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                       3-TIER CODE RETRIEVAL PYRAMID                         │
├─────────────────────────────────────────────────────────────────────────────┤
│  Tier 3: Deep Semantic LSP & Graphs (Highest Precision, Compile-time Truth) │
│  - Real Language Servers: Pyright, clangd, rust-analyzer, gopls, vtsls      │
│  - MCP Orchestration: Serena MCP, rust-analyzer-mcp                         │
│  - Static Code Intelligence Graphs: SCIP (scip-search, scip-typescript...) │
├─────────────────────────────────────────────────────────────────────────────┤
│  Tier 2: On-Demand Symbol & Caller Retrieval (88% - 99% Token Reduction)   │
│  - TokToken: Single C binary, SQLite FTS5 + universal-ctags                │
│  - CodeTree: MCP server with 23 tools over Tree-sitter AST + SQLite graph   │
│  - CodeRLM: Recursive Language Model server in Rust                         │
├─────────────────────────────────────────────────────────────────────────────┤
│  Tier 1: High-Compression AST Maps & Packing (60% - 90% Token Reduction)    │
│  - Repomix & repomix-rs: Tree-sitter code signature stripping (--compress) │
│  - Aider Repo Map: Tree-sitter tags + PageRank dependency centrality graph  │
│  - universal-ctags & Tree-sitter CLI                                        │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Multi-Language Indexing Survey: Python, C, Node.js, Rust, and Go

| Language | Primary Challenges for LLMs | Recommended Indexing Suite | Key Tools & Engines |
| :--- | :--- | :--- | :--- |
| **Python** | Dynamic typing, duck typing, PEP 695 generics, virtual environment (`venv`) isolation. AST alone cannot deduce attribute types. | **Pyright** (flow-sensitive type analysis), **Serena MCP** (LSP bridge), **scip-python**, **Repomix** (AST signature stripping). | Microsoft Pyright, `serena-agent`, `mcp-server-codetree`, `scip-python` |
| **C / C++** | Preprocessor macros, complex header dependencies, lack of native modules, huge repositories (e.g. Linux Kernel, Redis). | **TokToken** (SQLite FTS5 + universal-ctags), **clangd** (LLVM LSP), **scip-clang**, **universal-ctags**. | `toktoken`, `clangd`, `scip-clang`, `universal-ctags` |
| **Node.js (TS/JS)** | Monorepo structures (turborepo, pnpm/yarn workspaces), `tsconfig.json` path aliases (e.g. `@/components`), `node_modules` depth. | **scip-typescript** (unfolds aliases into Protobuf graph), **vtsls / tsserver**, **Repomix** (native TypeScript AST packer). | `@sourcegraph/scip-typescript`, `repomix`, `vtsls`, `typescript` |
| **Rust** | Strict borrow checker, lifetime annotations, hygienic and procedural macros, heavy memory footprint of `rust-analyzer`. | **rust-analyzer-mcp** (zero-contention sync channel), **rust-analyzer**, **repomix-rs** (Rust-native speed), **CodeRLM**. | `rust-analyzer`, `rust-analyzer-mcp`, `repomix-rs`, `coderlm` |
| **Go** | Rigid syntax, explicit imports matching directory tree, no macros, fast compilation. Highly predictable for AST. | **gopls** (official LSP), **scip-go**, **scip-search** (sub-millisecond queries), **TokToken** / **CodeTree**. | `gopls`, `scip-go`, `scip-search`, `toktoken`, `codetree` |

---

## 3. Tool Architecture, Mechanism, and Token Efficiency

### 3.1 TokToken (`mauriziofonte/toktoken`)
* **Core Tech**: C native single binary; pairs `universal-ctags` with SQLite FTS5 full-text indexing, import graph resolution, and centrality ranking.
* **Storage**: Global cache in `~/.cache/toktoken/` (never pollutes workspace code).
* **Token Savings**: **88% to 99%**. In Redis (45K symbols), inspecting a single function costs ~2,699 tokens instead of 84,193 tokens (97% reduction).
* **CLI & MCP**: `toktoken index:create`, `toktoken search:symbols`, `toktoken inspect:symbol`, `toktoken serve` (MCP mode).

### 3.2 Repomix & repomix-rs (`yamadashy/repomix` & `sopaco/repomix-rs`)
* **Core Tech**: Codebase packer into XML/Markdown. With `--compress`, it uses Tree-sitter to parse AST and replaces function/class bodies with stubs (`pass`, `{ ... }`), preserving signatures, interfaces, and docstrings.
* **Token Savings**: **60% to 90%** reduction (e.g., 1.9M tokens compressed to 90K tokens).
* **Performance**: `repomix-rs` is a Rust reimplementation using `rayon` and `ignore` crate, delivering 5x–7x speedup over Node.js version.

### 3.3 CodeTree (`ThinkyMiner/codeTree`)
* **Core Tech**: Python MCP server offering **23 structured code navigation tools** across 11 languages via Tree-sitter + SQLite symbol graph.
* **Token Savings**: Cuts 2,000 token whole-file reads down to ~80 token AST node queries (~25x reduction).

### 3.4 CodeRLM (`JaredStewart/coderlm`)
* **Core Tech**: Implements MIT's Recursive Language Model (RLM) pattern in Rust. Code is treated as external static memory. AI queries structure, callers, and exact lines via JSON API without loading whole files.

### 3.5 Aider Repo Map (`aider-chat`)
* **Core Tech**: Tree-sitter symbol tags + directed graph PageRank algorithm. Ranks definitions by centrality and injects optimal code map into context.

### 3.6 Serena (`oraios/serena`)
* **Core Tech**: Multi-language MCP server bridging LLMs directly to real Language Servers (LSP) for 40+ languages (Pyright, clangd, rust-analyzer, gopls, vtsls).
* **Capabilities**: Exact compiler-level Find References, Go to Definition, Workspace Symbol Renaming, and `ReplaceSymbolBodyTool`. Eliminates syntax and typing hallucinations.

### 3.7 rust-analyzer-mcp
* **Core Tech**: Dedicated Rust MCP server for `rust-analyzer` utilizing a synchronous `mpsc` channel and 3 dedicated threads instead of Tokio async runtime.
* **Advantage**: Sub-2ms response latency, zero async contention, ideal for short-lived agent subprocess queries.

### 3.8 SCIP Ecosystem (Sourcegraph Code Intelligence Protocol)
* **Core Tech**: Protobuf-based, language-agnostic code graph protocol. Indexing is performed statically once (e.g. in CI/CD or local build), generating `.scip` files.
* **scip-search (`liza-mas/scip-search`)**: Millisecond Go CLI for querying symbols, references, and callers from `.scip` files without running heavy LSP daemons.
* **Indexers**: `scip-go`, `scip-typescript`, `scip-python`, `scip-clang`, `rust-analyzer scip`.

---

## 4. Comprehensive Package & Component Inventory

### 4.1 Ubuntu Operating System Packages (via `apt-get`)
Required for system libraries, compilation, AST runtime, and standard C/C++ LSP:

| Ubuntu Package | Purpose | Category |
| :--- | :--- | :--- |
| `build-essential` | GCC, G++, Make compiler toolchain | Build Core |
| `pkg-config` | Package compilation flags resolver | Build Core |
| `libsqlite3-dev` & `sqlite3` | SQLite development headers & CLI (for TokToken & CodeTree) | Database / Index |
| `universal-ctags` | Modern Universal Ctags (mandatory for TokToken symbol extraction) | Symbol Parsing |
| `clangd` | LLVM official Language Server for C and C++ | C/C++ LSP |
| `curl`, `wget` | Binary retrieval utilities | Utilities |
| `git` | Version control & repository map baseline | VCS |
| `jq` | JSON query processor for release parsing | Utilities |
| `unzip`, `tar`, `gzip` | Archive extraction utilities | Utilities |
| `python3`, `python3-pip`, `python3-venv` | Python 3 runtime & environment support | Python Core |
| `nodejs`, `npm` | Node.js JavaScript runtime & package manager | Node.js Core |
| `golang-go` | Go compiler and tools | Go Core |

### 4.2 GitHub Releases & Precompiled Binaries
Stand-alone, self-contained single binaries deployed directly to `/usr/local/bin`:

| Tool | Source Repository | Target Binary | Architecture / Asset |
| :--- | :--- | :--- | :--- |
| **TokToken** | `mauriziofonte/toktoken` | `/usr/local/bin/toktoken` | `toktoken-linux-x86_64` / `toktoken-linux-aarch64` |
| **rust-analyzer** | `rust-lang/rust-analyzer` | `/usr/local/bin/rust-analyzer` | `rust-analyzer-x86_64-unknown-linux-gnu.gz` |
| **scip CLI** | `scip-code/scip` | `/usr/local/bin/scip` | `scip-linux-amd64.tar.gz` / `scip-linux-arm64.tar.gz` |
| **scip-clang** | `sourcegraph/scip-clang` | `/usr/local/bin/scip-clang` | `scip-clang-x86_64-linux` |
| **uv / uvx** | `astral-sh/uv` | `/usr/local/bin/uv`, `uvx` | `uv-x86_64-unknown-linux-gnu.tar.gz` |

### 4.3 Node.js / NPM Packages (System-wide Global)
Deployed via `npm install -g` into `/usr/local/bin` and `/usr/local/lib/node_modules`:

| NPM Package | Executables Provided | Description |
| :--- | :--- | :--- |
| `repomix` | `repomix` | Original TypeScript repository packer with Tree-sitter compression |
| `repomix-rs` | `repomix` (Rust build) | Blazing-fast Rust build of Repomix |
| `tree-sitter-cli` | `tree-sitter` | Tree-sitter CLI for grammar generation & syntax queries |
| `pyright` | `pyright`, `pyright-langserver` | Microsoft flow-sensitive Python type checker & LSP |
| `typescript` | `tsc`, `tsserver` | Official TypeScript compiler and Language Server |
| `typescript-language-server` | `typescript-language-server` | LSP bridge for `tsserver` |
| `@vtsls/language-server` | `vtsls` | Fast alternative TypeScript language server wrapper |
| `@sourcegraph/scip-typescript` | `scip-typescript` | Sourcegraph SCIP indexer for TypeScript/JavaScript |
| `@sourcegraph/scip-python` | `scip-python` | Sourcegraph SCIP indexer for Python |

### 4.4 Python Packages (System-wide via `uv` / isolated venvs)
Deployed into `/usr/local/bin` using `uv tool install --system` or `pipx`:

| Python Package | Command Provided | Description |
| :--- | :--- | :--- |
| `serena-agent` | `serena` | Language Server MCP toolkit for 40+ languages |
| `mcp-server-codetree` | `codetree` | Tree-sitter + SQLite MCP server with 23 tools |
| `aider-chat` | `aider` | AI coding assistant featuring the Repo Map PageRank engine |
| `python-lsp-server` | `pylsp` | Python LSP server (alternative to Pyright) |

### 4.5 Go Packages (Compiled via `go install` to `/usr/local/bin`)
Compiled using `go install` and placed in `/usr/local/bin` for multi-user access:

| Go Package Import Path | Executable Name | Description |
| :--- | :--- | :--- |
| `golang.org/x/tools/gopls@latest` | `gopls` | Official Go Language Server |
| `github.com/scip-code/scip-go/cmd/scip-go@latest` | `scip-go` | Sourcegraph SCIP indexer for Go modules |
| `github.com/liza-mas/scip-search/cmd/scip-search@latest` | `scip-search` | High-speed CLI for querying SCIP Protobuf graphs |

### 4.6 Rust Crates & Tools (Compiled via Cargo to `/usr/local/bin`)
Installed via `cargo install` or direct binary release:

| Rust Crate / Repo | Executable Name | Description |
| :--- | :--- | :--- |
| `rust-analyzer-mcp` | `rust-analyzer-mcp` | Low-latency synchronous MCP wrapper for `rust-analyzer` |
| `JaredStewart/coderlm` | `coderlm` | MIT Recursive Language Model (RLM) code indexing server |

---

## 5. Deployment Architecture: Root / Multi-User Layout

To ensure all tools are immediately available to every user on the system without requiring individual PATH adjustments or local tool installations, the deployment script installs everything into standard POSIX system directories:

```
/usr/local/bin/
├── aider                    # Aider Repo Map CLI
├── clangd                   # LLVM C/C++ LSP (from Ubuntu apt or LLVM)
├── coderlm                  # Recursive Language Model server
├── codetree                 # CodeTree 23-tool AST MCP server
├── gopls                    # Official Go language server
├── pyright                  # Microsoft Python type checker / LSP
├── pyright-langserver       # Pyright LSP daemon
├── repomix                  # Repomix AST compression repository packer
├── rust-analyzer            # Official Rust compiler language server
├── rust-analyzer-mcp        # Ultra-low latency Rust MCP server
├── scip                     # SCIP Protobuf inspector CLI
├── scip-clang               # SCIP indexer for C/C++
├── scip-go                  # SCIP indexer for Go
├── scip-python              # SCIP indexer for Python
├── scip-search              # Sub-millisecond SCIP index query tool
├── scip-typescript          # SCIP indexer for TypeScript/JavaScript
├── serena                   # Serena LSP MCP orchestrator
├── toktoken                 # Fast C/multi-language symbol indexer (FTS5)
├── tree-sitter              # Tree-sitter CST/AST CLI
├── typescript-language-server
├── universal-ctags          # Universal Ctags parser (via /usr/bin/ctags)
├── uv, uvx                  # Fast Python tool runner
└── vtsls                    # Fast TypeScript language server
```

---

## 6. Model Context Protocol (MCP) Integration Configuration

AI coding clients (Claude Code, Antigravity, Gemini CLI, Cursor, Windsurf) connect to these indexing tools via `mcp_config.json`. Below is the unified multi-language configuration:

```json
{
  "mcpServers": {
    "toktoken": {
      "command": "/usr/local/bin/toktoken",
      "args": ["serve"]
    },
    "codetree": {
      "command": "/usr/local/bin/codetree",
      "args": ["--root", "."]
    },
    "serena": {
      "command": "/usr/local/bin/serena",
      "args": ["start-mcp-server"]
    },
    "rust-analyzer": {
      "command": "/usr/local/bin/rust-analyzer-mcp",
      "args": []
    }
  }
}
```

---

## 7. Token Savings & Benchmark Matrix

| Tool | Indexing Strategy | Cold Start | Memory Footprint | Token Savings | Best For |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **TokToken** | Universal-ctags + SQLite FTS5 | < 1 sec | Very Low (10–50MB) | **88% – 99%** | Instant C/C++, Go, Python symbol search, call graphs, dead-code analysis |
| **Repomix (--compress)** | Tree-sitter AST signature stripping | ~1–3 sec | Low (50–150MB) | **60% – 90%** | Full repository architecture overview, initial onboarding into LLM context |
| **CodeTree** | Tree-sitter + SQLite AST graph | ~1 sec | Low (40–100MB) | **90% – 96%** | Structural queries, class outline, function extraction across 11 languages |
| **Aider Repo Map** | Tree-sitter tags + PageRank | ~2–5 sec | Moderate (100–300MB) | **80% – 90%** | Priority-ranked dependency mapping for multi-file refactoring |
| **Serena / Real LSP** | True compiler language servers | 5–30 sec | High (500MB – 4GB+) | Dynamic | Exact cross-file rename, type inference, find references, safe refactoring |
| **SCIP + scip-search** | Static Protobuf pre-indexed graph | < 10 ms | Minimal (10–30MB) | **95% – 99%** | Large monorepos, CI/CD generated graphs, sub-millisecond query latency |

---

## 8. Deployment Execution Guide

To deploy this entire infrastructure on Ubuntu, execute the provided scripts:

```bash
# 1. System-wide Root / Multi-user Installation (Recommended)
sudo ./deploy-indexing-tools.sh

# 2. Verify all installed tools and version outputs
./verify-indexing-tools.sh

# 3. For non-root environments (Installs to ~/.local/bin and ~/go/bin):
./install-indexing-tools-user.sh
```
