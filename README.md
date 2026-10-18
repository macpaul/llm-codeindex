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

The repository converts the indexing ecosystem into 7 production skills located in `skills/` and `.agents/skills/`:

1. [**`code-indexing-advisor`**](file:///home/macpaul/coding-index-for-llm/skills/code-indexing-advisor/SKILL.md): Automatically analyzes project structure, detects languages, and recommends optimal 3-tier indexing.
2. [**`toktoken-index`**](file:///home/macpaul/coding-index-for-llm/skills/toktoken-index/SKILL.md): High-speed C-native symbol and caller indexing (88%–99% token savings).
3. [**`repomix-packer`**](file:///home/macpaul/coding-index-for-llm/skills/repomix-packer/SKILL.md): Tree-sitter AST signature compression (`--compress`) cutting context by 60%–90%.
4. [**`codetree-navigator`**](file:///home/macpaul/coding-index-for-llm/skills/codetree-navigator/SKILL.md): 23 structured AST navigation tools across 11 languages via MCP.
5. [**`serena-lsp`**](file:///home/macpaul/coding-index-for-llm/skills/serena-lsp/SKILL.md): Compiler-grade semantic refactoring, find references, and diagnostics for 40+ languages.
6. [**`scip-code-graph`**](file:///home/macpaul/coding-index-for-llm/skills/scip-code-graph/SKILL.md): Protobuf code graph generation and sub-millisecond lookups via `scip-search`.
7. [**`language-lsp-tools`**](file:///home/macpaul/coding-index-for-llm/skills/language-lsp-tools/SKILL.md): Language-specific deep indexing runbook (Pyright, clangd, rust-analyzer, gopls, vtsls).
