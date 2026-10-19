#!/usr/bin/env bash
# ==============================================================================
# run_toktoken.sh - TokToken Lifecycle & Indexing Helper
# ==============================================================================

set -euo pipefail

ACTION="${1:-help}"
shift || true

if ! command -v toktoken >/dev/null 2>&1; then
    echo "[ERROR] 'toktoken' is not found in PATH."
    exit 1
fi

case "${ACTION}" in
    detect)
        TARGET="${1:-.}"
        toktoken codebase:detect "${TARGET}"
        ;;
    create|index)
        TARGET="${1:-.}"
        echo "[TokToken] Creating project index for: ${TARGET}"
        toktoken index:create "${TARGET}"
        ;;
    update)
        TARGET="${1:-.}"
        echo "[TokToken] Updating project index for: ${TARGET}"
        toktoken index:update "${TARGET}"
        ;;
    file)
        FILE_PATH="${1:-}"
        if [[ -z "${FILE_PATH}" ]]; then
            echo "Usage: $0 file <file_path>"
            exit 1
        fi
        toktoken index:file "${FILE_PATH}"
        ;;
    github)
        REPO="${1:-}"
        if [[ -z "${REPO}" ]]; then
            echo "Usage: $0 github <owner/repo>"
            exit 1
        fi
        echo "[TokToken] Cloning and indexing GitHub repository: ${REPO}"
        toktoken index:github "${REPO}"
        ;;
    stats)
        toktoken stats
        ;;
    projects)
        toktoken projects:list
        ;;
    repos)
        toktoken repos:list
        ;;
    clear)
        toktoken cache:clear
        ;;
    serve)
        echo "[TokToken] Starting MCP server on stdio..."
        exec toktoken serve
        ;;
    *)
        echo "TokToken Lifecycle Helper Script"
        echo "Usage:"
        echo "  $0 detect [path]        - Detect if path is a codebase and index status"
        echo "  $0 create [path]        - Create project index"
        echo "  $0 update [path]        - Incrementally update index"
        echo "  $0 file <file>          - Reindex a single file"
        echo "  $0 github <owner/repo>  - Clone and index a GitHub repository"
        echo "  $0 stats                - Show index statistics"
        echo "  $0 projects             - List all indexed projects"
        echo "  $0 repos                - List cloned GitHub repositories"
        echo "  $0 clear                - Clear index cache"
        echo "  $0 serve                - Start MCP stdio server"
        ;;
esac
