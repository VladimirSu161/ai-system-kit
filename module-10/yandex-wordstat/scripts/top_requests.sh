#!/bin/sh
# Get top search phrases from Yandex Wordstat (Yandex Cloud Search API v2)
# POSIX sh compatible — works in cloud sandboxes and locally
# Uses temp file for API response to avoid stdout buffer overflow.
# Response parsing is delegated to /usr/bin/python3 (json module) — the API
# returns pretty-printed JSON with spaces, which grep/sed can't reliably parse
# without corrupting multi-word Cyrillic phrases.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/../config/.env"
WS_API="https://searchapi.api.cloud.yandex.net/v2/wordstat"

# --- Inline config (no external source) ---

if [ -f "$CONFIG_FILE" ]; then
    # shellcheck disable=SC1090
    . "$CONFIG_FILE"
fi

if [ -z "$YANDEX_API_KEY" ] || [ -z "$YANDEX_FOLDER_ID" ]; then
    echo "Error: YANDEX_API_KEY и/или YANDEX_FOLDER_ID не заданы."
    echo "Задайте их в config/.env — см. config/README.md."
    exit 1
fi

# Defaults
PHRASE=""
REGIONS=""
DEVICES="all"
LIMIT=""
CSV_FILE=""
CSV_SEP=";"
STDOUT_MAX=20

# Temp file for API response (avoids piping huge strings through stdout)
TMPFILE="${TMPDIR:-/tmp}/ws_result_$$.json"
cleanup() { rm -f "$TMPFILE"; }
trap cleanup EXIT

# Parse args
while [ $# -gt 0 ]; do
    case $1 in
        --phrase|-p) PHRASE="$2"; shift 2 ;;
        --regions|-r) REGIONS="$2"; shift 2 ;;
        --devices|-d) DEVICES="$2"; shift 2 ;;
        --limit|-l) LIMIT="$2"; shift 2 ;;
        --csv|-c) CSV_FILE="$2"; shift 2 ;;
        --sep) CSV_SEP="$2"; shift 2 ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

if [ -z "$PHRASE" ]; then
    echo "Usage: top_requests.sh --phrase \"search query\" [options]"
    echo ""
    echo "Options:"
    echo "  --phrase, -p   Search phrase (required, no Wordstat operators — plain text only)"
    echo "  --regions, -r  Region IDs, comma-separated (optional)"
    echo "  --devices, -d  Device filter: all, desktop, phone, tablet (default: all)"
    echo "  --limit, -l    Number of results: 1-2000 (API default: 20)"
    echo "  --csv, -c      Export to CSV file (UTF-8 with BOM, semicolon-separated)"
    echo "  --sep          CSV separator (default: ;)"
    echo ""
    echo "Examples:"
    echo "  sh scripts/top_requests.sh --phrase \"юрист по дтп\""
    echo "  sh scripts/top_requests.sh --phrase \"юрист дтп\" --limit 500"
    echo "  sh scripts/top_requests.sh --phrase \"юрист дтп\" --limit 2000 --csv report.csv"
    exit 1
fi

# Validate --limit
if [ -n "$LIMIT" ]; then
    if ! echo "$LIMIT" | grep -qE '^[0-9]+$'; then
        echo "Error: --limit must be a positive integer (1-2000)"
        exit 1
    fi
    if [ "$LIMIT" -lt 1 ] || [ "$LIMIT" -gt 2000 ]; then
        echo "Error: --limit must be between 1 and 2000 (got: $LIMIT)"
        exit 1
    fi
fi

# Escape string for JSON
json_escape() {
    printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

# Map --devices to API enum
device_enum() {
    case "$1" in
        desktop) echo "DEVICE_DESKTOP" ;;
        phone) echo "DEVICE_PHONE" ;;
        tablet) echo "DEVICE_TABLET" ;;
        *) echo "DEVICE_ALL" ;;
    esac
}

# Build JSON array of quoted region-id strings from CSV (POSIX-compatible, no read -a)
build_regions_json() {
    _brj_csv="$1"
    _brj_out="["
    _brj_first=1
    _brj_saved_ifs="$IFS"
    IFS=','
    for _brj_id in $_brj_csv; do
        _brj_id=$(printf '%s' "$_brj_id" | tr -d '[:space:]')
        [ -z "$_brj_id" ] && continue
        if [ "$_brj_first" -eq 1 ]; then
            _brj_out="$_brj_out\"$_brj_id\""
            _brj_first=0
        else
            _brj_out="$_brj_out,\"$_brj_id\""
        fi
    done
    IFS="$_brj_saved_ifs"
    printf '%s]' "$_brj_out"
}

# Build JSON payload (folderId added at the end)
PHRASE_ESCAPED=$(json_escape "$PHRASE")
PARAMS="{\"phrase\":\"$PHRASE_ESCAPED\""

# numPhrases обязателен для API v2 — рабочего дефолта без него нет (INVALID_ARGUMENT)
if [ -n "$LIMIT" ]; then
    PARAMS="$PARAMS,\"numPhrases\":$LIMIT"
else
    PARAMS="$PARAMS,\"numPhrases\":20"
fi

if [ -n "$REGIONS" ]; then
    PARAMS="$PARAMS,\"regions\":$(build_regions_json "$REGIONS")"
fi

if [ "$DEVICES" != "all" ]; then
    PARAMS="$PARAMS,\"devices\":\"$(device_enum "$DEVICES")\""
fi

PARAMS="$PARAMS,\"folderId\":\"$YANDEX_FOLDER_ID\"}"

echo "=== Yandex Wordstat: Top Requests ==="
echo "Phrase: $PHRASE"
[ -n "$REGIONS" ] && echo "Regions: $REGIONS"
echo "Devices: $DEVICES"
[ -n "$LIMIT" ] && echo "Limit: $LIMIT"
[ -n "$CSV_FILE" ] && echo "Export: $CSV_FILE (sep='$CSV_SEP')"
echo ""
echo "Fetching data..."

# API request — save raw JSON to temp file, not variable
curl -s -X POST "$WS_API/topRequests" \
    -H "Authorization: Api-Key $YANDEX_API_KEY" \
    -H "Content-Type: application/json; charset=utf-8" \
    -d "$PARAMS" > "$TMPFILE"

/usr/bin/python3 - "$TMPFILE" "$CSV_FILE" "$CSV_SEP" "$STDOUT_MAX" <<'PYEOF'
import csv
import json
import sys

tmp_file, csv_file, csv_sep, stdout_max = sys.argv[1], sys.argv[2], sys.argv[3], int(sys.argv[4])

with open(tmp_file, encoding="utf-8") as f:
    raw = f.read()

try:
    obj = json.loads(raw)
except json.JSONDecodeError:
    print("Error: invalid JSON response")
    print(raw[:2000])
    sys.exit(1)

# Yandex Cloud Search API v2 error format: {"code":.., "message":"...", "details":[...]}
if "message" in obj and "results" not in obj:
    print("Error:")
    print(json.dumps(obj, ensure_ascii=False, indent=2))
    sys.exit(1)


def fmt(n):
    try:
        return f"{int(n):,}".replace(",", " ")
    except (TypeError, ValueError):
        return str(n)


results = obj.get("results", [])
associations = obj.get("associations", [])
total_count = obj.get("totalCount")

print()
print("=== Top Requests ===")
if total_count is not None:
    print(f"Total count (broad match): {fmt(total_count)}")
print()
print("| # | Phrase | Impressions |")
print("|---|--------|-------------|")

csv_rows = []


def render(entries, type_label):
    for i, e in enumerate(entries, start=1):
        phrase = e.get("phrase", "")
        count = e.get("count", "0")
        if not csv_file or i <= stdout_max:
            print(f"| {i} | {phrase} | {fmt(count)} |")
        elif i == stdout_max + 1:
            print(f"| ... | ... and {len(entries) - stdout_max} more rows in CSV | ... |")
        if csv_file:
            csv_rows.append((i, phrase, count, type_label))


render(results, "top")

if associations:
    print()
    print("=== Associations (similar queries) ===")
    print()
    print("| # | Phrase | Impressions |")
    print("|---|--------|-------------|")
    render(associations, "assoc")

print()
if csv_file:
    with open(csv_file, "w", encoding="utf-8-sig", newline="") as f:
        w = csv.writer(f, delimiter=csv_sep)
        w.writerow(["n", "phrase", "impressions", "type"])
        for row in csv_rows:
            w.writerow(row)
    print(f"CSV exported: {csv_file} ({len(csv_rows)} rows, sep='{csv_sep}')")
PYEOF
