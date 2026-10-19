#!/usr/bin/env bash
# ==============================================================================
# toktoken_graph.sh - Call Hierarchy, Importers & Dead Code Helper
# ==============================================================================

set -euo pipefail

ACTION="${1:-help}"
shift || true

if ! command -v toktoken >/dev/null 2>&1; then
    echo "[ERROR] 'toktoken' is not found in PATH."
    exit 1
fi

case "${ACTION}" in
    callers)
        SYM_ID="${1:-}"
        if [[ -z "${SYM_ID}" ]]; then
            echo "Usage: $0 callers <symbol_id>"
            exit 1
        fi
        shift || true
        toktoken find:callers "${SYM_ID}" -c "$@"
        ;;
    references|refs)
        SYM_ID="${1:-}"
        if [[ -z "${SYM_ID}" ]]; then
            echo "Usage: $0 references <symbol_id>"
            exit 1
        fi
        shift || true
        toktoken find:references "${SYM_ID}" -c "$@"
        ;;
    importers)
        FILE_PATH="${1:-}"
        if [[ -z "${FILE_PATH}" ]]; then
            echo "Usage: $0 importers <file_path>"
            exit 1
        fi
        shift || true
        toktoken find:importers "${FILE_PATH}" "$@"
        ;;
    dead)
        toktoken find:dead --exclude-tests -c "$@"
        ;;
    *)
        echo "TokToken Call Hierarchy & Dependency Helper"
        echo "Usage:"
        echo "  $0 callers <symbol_id>    - Find all callers of target symbol"
        echo "  $0 references <symbol_id> - Find references to an identifier"
        echo "  $0 importers <file_path>  - Find files that import a given file"
        echo "  $0 dead                   - Scan for dead/unused code (excluding tests)"
        ;;
esac
