#!/usr/bin/env bash
# ==============================================================================
# run_toktoken.sh
# Helper script to initialize and query TokToken on any project
# ==============================================================================

set -euo pipefail

ACTION="${1:-help}"
shift || true

if ! command -v toktoken >/dev/null 2>&1; then
    echo "[ERROR] 'toktoken' is not found in PATH."
    echo "Run './deploy-indexing-tools.sh' or './install-indexing-tools-user.sh' to install it."
    exit 1
fi

case "${ACTION}" in
    index)
        TARGET_DIR="${1:-.}"
        echo "[TokToken] Creating project index for: ${TARGET_DIR}"
        toktoken index:create "${TARGET_DIR}"
        ;;
    search)
        QUERY="${1:-}"
        if [[ -z "${QUERY}" ]]; then
            echo "Usage: $0 search <symbol_name>"
            exit 1
        fi
        echo "[TokToken] Searching for symbol: ${QUERY}"
        toktoken search:symbols "${QUERY}" -ck class,method,function,struct,interface
        ;;
    inspect)
        SYMBOL_ID="${1:-}"
        if [[ -z "${SYMBOL_ID}" ]]; then
            echo "Usage: $0 inspect <symbol_id>"
            exit 1
        fi
        echo "[TokToken] Inspecting symbol: ${SYMBOL_ID}"
        toktoken inspect:symbol "${SYMBOL_ID}"
        ;;
    outline)
        FILE_PATH="${1:-}"
        if [[ -z "${FILE_PATH}" ]]; then
            echo "Usage: $0 outline <file_path>"
            exit 1
        fi
        echo "[TokToken] Inspecting outline for: ${FILE_PATH}"
        toktoken inspect:outline "${FILE_PATH}"
        ;;
    callers)
        SYMBOL_ID="${1:-}"
        toktoken find:callers "${SYMBOL_ID}"
        ;;
    *)
        echo "TokToken Helper Script"
        echo "Usage:"
        echo "  $0 index [path]            - Create index for project"
        echo "  $0 search <query>          - Search symbols (functions, classes)"
        echo "  $0 inspect <symbol_id>     - Retrieve full code of symbol"
        echo "  $0 outline <file_path>     - View symbol hierarchy of a file"
        echo "  $0 callers <symbol_id>     - Find callers across the codebase"
        ;;
esac
