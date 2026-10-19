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

## 📄 License

This project is licensed under the terms of the [GNU Affero General Public License v3.0 (AGPL-3.0)](file:///home/macpaul/llm-codeindex/LICENSE).
