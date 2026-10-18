---
name: repomix-packer
description: >-
  Uses Repomix and repomix-rs to pack repositories into token-compressed XML/Markdown
  representations using Tree-sitter AST signature stripping (--compress), cutting context size
  by 60%-90% for architecture reviews and initial onboarding.
---

# Repomix: Tree-sitter AST Codebase Packer

Repomix (and its Rust version `repomix-rs`) packs an entire codebase into a single AI-friendly format (XML, Markdown, or JSON) while dramatically reducing tokens.

## When to Use This Skill
* Onboarding into a new repository to understand global architecture and dependencies.
* Passing broad context to large context models (Gemini 1.5 Pro, Claude 3.5 Sonnet) without hitting rate limits or attention dilution.
* Preparing clean code bundles while excluding secrets and vendored dependencies.

## Key Capabilities & Arguments

### 1. High-Compression Mode (`--compress`)
The `--compress` flag invokes Tree-sitter parsers (Python, TypeScript, Go, Rust, C++) to strip function and class bodies, replacing them with stubs:
```bash
repomix --compress --output codebase-summary.xml
```
* **Token Reduction**: Typically **60% to 90%** (e.g. 1.9M raw tokens -> 90K compressed tokens).
* **Information Preserved**: Function signatures, type annotations, class interfaces, module exports, and docstrings.

### 2. Output Styles
* **XML (Default)**: Best for Claude and Gemini structured comprehension:
  ```bash
  repomix --style xml --output repomix-output.xml
  ```
* **Markdown**: Best for human review or standard LLM prompt copy-paste:
  ```bash
  repomix --style markdown --output repomix-output.md
  ```

### 3. File Filtering and Security
Exclude build artifacts and test fixtures:
```bash
repomix --ignore "**/dist/**,**/build/**,**/*.lock"
```
Repomix automatically scans for and redacts API keys, credentials, and suspicious secrets using Secretlint rules.

### 4. Running repomix-rs (High Throughput)
For codebases with > 2,000 files, `repomix-rs` processes file I/O and Tree-sitter parsing in parallel with zero-copy readers:
```bash
npm install -g repomix-rs
repomix --compress
```
