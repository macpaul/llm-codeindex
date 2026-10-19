#!/usr/bin/env bash
# ==============================================================================
# toktoken_search.sh - Precision Symbol & Text Search Helper
# ==============================================================================

set -euo pipefail

ACTION="${1:-help}"
shift || true

if ! command -v toktoken >/dev/null 2>&1; then
    echo "[ERROR] 'toktoken' is not found in PATH."
    exit 1
fi

case "${ACTION}" in
    symbols|sym)
        QUERY="${1:-}"
        if [[ -z "${QUERY}" ]]; then
            echo "Usage: $0 symbols <query> [extra_toktoken_flags]"
            exit 1
        fi
        shift || true
        toktoken search:symbols "${QUERY}" -c "$@"
        ;;
    func|function)
        QUERY="${1:-}"
        shift || true
        toktoken search:symbols "${QUERY}" -ck function,method -c "$@"
        ;;
    class|type)
        QUERY="${1:-}"
        shift || true
        toktoken search:symbols "${QUERY}" -ck class,struct,interface,typedef -c "$@"
        ;;
    text)
        QUERY="${1:-}"
        if [[ -z "${QUERY}" ]]; then
            echo "Usage: $0 text <query> [extra_toktoken_flags]"
            exit 1
        fi
        shift || true
        toktoken search:text "${QUERY}" -g file "$@"
        ;;
    cooccur)
        SYMS="${1:-}"
        if [[ -z "${SYMS}" ]]; then
            echo "Usage: $0 cooccur <symA,symB>"
            exit 1
        fi
        toktoken search:cooccurrence "${SYMS}"
        ;;
    similar)
        SYM_ID="${1:-}"
        if [[ -z "${SYM_ID}" ]]; then
            echo "Usage: $0 similar <symbol_id>"
            exit 1
        fi
        toktoken search:similar "${SYM_ID}"
        ;;
    suggest)
        toktoken suggest
        ;;
    *)
        echo "TokToken Symbol & Text Search Helper"
        echo "Usage:"
        echo "  $0 symbols <query> [flags]  - Search symbols (compact JSON)"
        echo "  $0 func <query>             - Search functions and methods"
        echo "  $0 class <query>            - Search classes, structs, interfaces"
        echo "  $0 text <query>             - Full-text search grouped by file"
        echo "  $0 cooccur <symA,symB>      - Find co-occurring symbols"
        echo "  $0 similar <symbol_id>      - Find similar symbols"
        echo "  $0 suggest                  - Get exploration suggestions"
        ;;
esac
