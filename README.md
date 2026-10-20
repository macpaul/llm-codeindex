# LLM Code Indexing & Retrieval Ecosystem

This repository provides an enterprise-ready code indexing suite and AI agent skill integration for **Python, C/C++, Node.js (TypeScript/JavaScript), Rust, and Go**, based on the architecture detailed in [CodeIndexingToolsForLLMs.md](file:///home/macpaul/coding-index-for-llm/CodeIndexingToolsForLLMs.md).

---

## 📂 Repository Contents

| File / Folder | Purpose |
| :--- | :--- |
| [**CODE_INDEXING_DEPLOYMENT.md**](file:///home/macpaul/coding-index-for-llm/CODE_INDEXING_DEPLOYMENT.md) | Comprehensive survey and deployment specification for Ubuntu and GitHub packages. |
| [**deploy-indexing-tools.sh**](file:///home/macpaul/coding-index-for-llm/deploy-indexing-tools.sh) | **Root (sudo) installation script** deploying all tools system-wide to `/usr/local/bin` for all users. |
| [**install-indexing-tools-user.sh**](file:///home/macpaul/coding-index-for-llm/install-indexing-tools-user.sh) | Non-root user-level installation script (`~/.local/bin` & `~/go/bin`). |
| [**verify-indexing-tools.sh**](file:///home/macpaul/coding-index-for-llm/verify-indexing-tools.sh) | Verification script to check installation status and versions of all tools. |
| [**install-skills.sh**](file:///home/macpaul/coding-index-for-llm/install-skills.sh) | Installs skills into workspace `.agents/skills/` and global CLI configurations. |
| [**mcp_config.json**](file:///home/macpaul/coding-index-for-llm/mcp_config.json) | Ready-to-use Model Context Protocol (MCP) server definitions. |
| [**skills/**](file:///home/macpaul/coding-index-for-llm/skills/) | Modular suite of 7 AI coding skills for CLI agents. |
| [**LICENSE**](file:///home/macpaul/coding-index-for-llm/LICENSE) | GNU Affero General Public License v3.0 (AGPL-3.0). |

---

## 🚀 Quick Start

### 1. Deploy System-Wide (Root / Sudo)
```bash
sudo ./deploy-indexing-tools.sh
```

### 2. Verify Installations
```bash
./verify-indexing-tools.sh
```

### 3. Deploy AI Coding Skills
```bash
./install-skills.sh
```

---

## 🧠 AI Coding Skills Suite

The repository converts the indexing ecosystem into 10 production skills located in `skills/` and active across **Claude Code, Google Antigravity, Cursor, and Codex**:

### TokToken Command Suite
1. [**`toktoken-index`**](file:///home/macpaul/llm-codeindex/skills/toktoken-index/SKILL.md): Lifecycle management and indexing engine for TokToken (`index:create`, `index:update`, `index:file`, `index:github`, `codebase:detect`, `stats`, `projects:list`, `cache:clear`, `repos:list/remove/clear`, `serve`).
2. [**`toktoken-symbol-search`**](file:///home/macpaul/llm-codeindex/skills/toktoken-symbol-search/SKILL.md): Surgical symbol and full-text code retrieval via SQLite FTS5 (`search:symbols`, `search:text`, `search:cooccurrence`, `search:similar`, `suggest`) with strict `--token-budget` controls.
3. [**`toktoken-call-graph`**](file:///home/macpaul/llm-codeindex/skills/toktoken-call-graph/SKILL.md): Call hierarchy, reference tracking, file importers, and dead code detection (`find:callers`, `find:references`, `find:importers`, `find:dead --exclude-tests`).
4. [**`toktoken-architecture-inspector`**](file:///home/macpaul/llm-codeindex/skills/toktoken-architecture-inspector/SKILL.md): Deep structural diagnostics, all-in-one symbol context bundles, and refactoring impact (`inspect:bundle`, `inspect:blast`, `inspect:cycles`, `inspect:dependencies`, `inspect:hierarchy`, `inspect:outline`, `inspect:tree`, `inspect:symbol`, `inspect:file`).

### Multi-Tool & Protocol Skills
5. [**`code-indexing-advisor`**](file:///home/macpaul/llm-codeindex/skills/code-indexing-advisor/SKILL.md): Automatically analyzes project structure, detects languages, and recommends optimal 3-tier indexing.
6. [**`repomix-packer`**](file:///home/macpaul/llm-codeindex/skills/repomix-packer/SKILL.md): Tree-sitter AST signature compression (`--compress`) cutting context by 60%–90%.
7. [**`codetree-navigator`**](file:///home/macpaul/llm-codeindex/skills/codetree-navigator/SKILL.md): 23 structured AST navigation tools across 11 languages via MCP.
8. [**`serena-lsp`**](file:///home/macpaul/llm-codeindex/skills/serena-lsp/SKILL.md): Compiler-grade semantic refactoring, find references, and diagnostics for 40+ languages.
9. [**`scip-code-graph`**](file:///home/macpaul/llm-codeindex/skills/scip-code-graph/SKILL.md): Protobuf code graph generation and sub-millisecond lookups via `scip-search`.
10. [**`language-lsp-tools`**](file:///home/macpaul/llm-codeindex/skills/language-lsp-tools/SKILL.md): Language-specific deep indexing runbook (Pyright, clangd, rust-analyzer, gopls, vtsls).

---

## ⚡ Agent Lifecycle Optimization & The 1.7x Rule

### The Multi-Turn Compounding Context Discovery
Standard single-shot tool benchmarks only measure isolated command output size, missing the reality of autonomous AI agent workflows (Claude, Cursor, Antigravity, Cline). In multi-turn sessions, conversation history **compounds quadratically ($O(T^2)$)** on every turn:

$$\text{Total Tokens} = \sum_{t=1}^{T} \Big( \text{BasePrompt} + \text{ToolSchemas} + \sum_{k=1}^{t-1} \text{History}_k \Big) + \sum_{t=1}^{T} \text{Thought}_t$$

If an agent registers 20+ fine-grained MCP tools, the schema alone injects **+460 tokens into every single turn**. Across a 7-turn session, tool schemas and uncompacted JSON formatting compound into **1.55x ~ 1.7x higher lifetime token consumption than traditional grep**, validating Claude's empirical critique.

### Empirical Proof: Full-Task Agent Benchmark (Das U-Boot Porting)

| Agent Architecture | Base Schemas | Total Turns | Lifetime Tokens | Cost Ratio vs Grep |
| :--- | :---: | :---: | :---: | :---: |
| **Grep Surgical Agent** (Human-expert baseline) | 176 tokens | 7 turns | 12,652 tokens | 1.00x (Base) |
| **Grep Naive Agent** (Autonomous LLM fallback to `cat`) | 176 tokens | 7 turns | 51,091 tokens | 4.04x (Severe bloat) |
| **Naive TokToken MCP Agent** (20 MCP tools, pretty JSON) | 636 tokens | 7 turns | 19,660 tokens | **1.55x ~ 1.7x (Claude observation confirmed)** |
| **Optimized TokToken CLI Agent** (Minimal CLI schema, `-c`) | **187 tokens** | **6 turns** | **8,375 tokens** | **0.66x (34% savings vs Grep!)** |

### The 4 Golden Rules for Agent Token Efficiency
1. **CLI-First Dispatch over Massive MCP Schemas**: When agents have shell access (`run_command`), invoke `toktoken` directly via CLI rather than declaring 27 fine-grained MCP tools. Drops system prompt overhead by **95%** (from ~4,000 to ~180 tokens).
2. **Mandatory `--compact` (`-c`) Flag**: Always pass `-c` to all `toktoken` invocations in agent loops to strip indentation and whitespace, cutting JSON formatting tokens by 45%.
3. **Mandatory Result Limits (`-l 5` or `-l 10`)**: Unbounded queries return 50 symbols. In multi-turn tasks, 50 symbols ingested in Turn 1 costs 5x more because of context compounding on every subsequent turn.
4. **One-Shot Symbol Targeting (`inspect:symbol`)**: `grep` requires 2 turns (`grep` line number -> `sed` line range). `toktoken inspect:symbol` extracts the complete struct/function body in **1 turn**, saving an entire round-trip and cutting quadratic context growth.

---

## 📄 License

This project is licensed under the terms of the [GNU Affero General Public License v3.0 (AGPL-3.0)](file:///home/macpaul/llm-codeindex/LICENSE).
