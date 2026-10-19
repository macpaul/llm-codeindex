#!/usr/bin/env bash
# ==============================================================================
# toktoken_inspect.sh - Architecture & Deep Inspection Helper
# ==============================================================================

set -euo pipefail

ACTION="${1:-help}"
shift || true

if ! command -v toktoken >/dev/null 2>&1; then
    echo "[ERROR] 'toktoken' is not found in PATH."
    exit 1
fi

case "${ACTION}" in
    bundle)
        SYM_ID="${1:-}"
        if [[ -z "${SYM_ID}" ]]; then
            echo "Usage: $0 bundle <symbol_id> [--include-callers]"
            exit 1
        fi
        shift || true
        toktoken inspect:bundle "${SYM_ID}" "$@"
        ;;
    blast)
        SYM_ID="${1:-}"
        if [[ -z "${SYM_ID}" ]]; then
            echo "Usage: $0 blast <symbol_id> [-d depth]"
            exit 1
        fi
        shift || true
        toktoken inspect:blast "${SYM_ID}" "$@"
        ;;
    cycles)
        toktoken inspect:cycles "$@"
        ;;
    deps|dependencies)
        FILE_PATH="${1:-}"
        if [[ -z "${FILE_PATH}" ]]; then
            echo "Usage: $0 deps <file_path>"
            exit 1
        fi
        shift || true
        toktoken inspect:dependencies "${FILE_PATH}" "$@"
        ;;
    hierarchy)
        FILE_PATH="${1:-}"
        if [[ -z "${FILE_PATH}" ]]; then
            echo "Usage: $0 hierarchy <file_path>"
            exit 1
        fi
        shift || true
        toktoken inspect:hierarchy "${FILE_PATH}" "$@"
        ;;
    outline)
        FILE_PATH="${1:-}"
        if [[ -z "${FILE_PATH}" ]]; then
            echo "Usage: $0 outline <file_path>"
            exit 1
        fi
        shift || true
        toktoken inspect:outline "${FILE_PATH}" "$@"
        ;;
    tree)
        DEPTH="${1:-2}"
        toktoken inspect:tree -d "${DEPTH}"
        ;;
    symbol)
        SYM_ID="${1:-}"
        if [[ -z "${SYM_ID}" ]]; then
            echo "Usage: $0 symbol <symbol_id>"
            exit 1
        fi
        shift || true
        toktoken inspect:symbol "${SYM_ID}" "$@"
        ;;
    file)
        FILE_PATH="${1:-}"
        if [[ -z "${FILE_PATH}" ]]; then
            echo "Usage: $0 file <file_path> [--lines <start-end>]"
            exit 1
        fi
        shift || true
        toktoken inspect:file "${FILE_PATH}" "$@"
        ;;
    *)
        echo "TokToken Architecture & Inspection Helper"
        echo "Usage:"
        echo "  $0 bundle <symbol_id> [--include-callers] - Get complete context bundle"
        echo "  $0 blast <symbol_id> [-d depth]          - Calculate refactoring blast radius"
        echo "  $0 cycles [--cross-dir]                  - Detect circular import cycles"
        echo "  $0 deps <file_path>                      - Trace transitive import tree"
        echo "  $0 hierarchy <file_path>                 - Show class/struct hierarchy"
        echo "  $0 outline <file_path>                   - Get file symbol outline"
        echo "  $0 tree [depth]                          - View indexed project file tree"
        echo "  $0 symbol <symbol_id>                    - Get exact symbol implementation"
        echo "  $0 file <file_path> [--lines s-e]        - Read file with optional line range"
        ;;
esac
