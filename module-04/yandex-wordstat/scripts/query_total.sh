#!/bin/sh
# Get totalCount from Yandex Wordstat API v2 (Yandex Cloud Search API) for a query.
# Thin wrapper: reads key/folderId from config/.env, delegates to missed_demand.py.
#
# ВНИМАНИЕ: API v2 не поддерживает операторы Wordstat (!, +, "...", (a|b), минус-слова).
# Если phrase содержит такой синтаксис, он не будет применён как оператор — API будет
# искать его как обычный текст. Методика "упущенного спроса" (build-query/merge-slots)
# была рассчитана на старый API и требует пересмотра — см. config/README.md.
#
# Usage:
#   bash scripts/query_total.sh --phrase "купить заказать телефон ретро" [--regions "213"]
#
# Output: JSON {"total_count": N, "query": "..."} or {"error": "...", "query": "..."}

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/../config/.env"

# Load key/folderId (same pattern as top_requests.sh)
if [ -f "$CONFIG_FILE" ]; then
    # shellcheck disable=SC1090
    . "$CONFIG_FILE"
fi

if [ -z "$YANDEX_API_KEY" ] || [ -z "$YANDEX_FOLDER_ID" ]; then
    echo "Error: YANDEX_API_KEY и/или YANDEX_FOLDER_ID не заданы."
    echo "Задайте их в config/.env — см. config/README.md."
    exit 1
fi

# Parse arguments
PHRASE=""
REGIONS=""

while [ $# -gt 0 ]; do
    case $1 in
        --phrase|-p) PHRASE="$2"; shift 2 ;;
        --regions|-r) REGIONS="$2"; shift 2 ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

if [ -z "$PHRASE" ]; then
    echo "Usage: query_total.sh --phrase \"query text\" [--regions \"213\"]"
    echo ""
    echo "Options:"
    echo "  --phrase, -p   Search phrase (required; plain text — operators not supported by API v2)"
    echo "  --regions, -r  Region IDs, comma-separated (optional)"
    echo ""
    echo "Output: JSON with total_count"
    exit 1
fi

# Delegate to Python (только /usr/bin/python3 — brew-python не совместим с uv-скриптом в этом окружении)
/usr/bin/python3 "$SCRIPT_DIR/missed_demand.py" query-total \
    --token "$YANDEX_API_KEY" \
    --folder-id "$YANDEX_FOLDER_ID" \
    --phrase "$PHRASE" \
    ${REGIONS:+--regions "$REGIONS"}
