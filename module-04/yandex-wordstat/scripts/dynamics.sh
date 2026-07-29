#!/bin/bash
# Get search volume dynamics from Yandex Wordstat (Yandex Cloud Search API v2)
# Response parsing delegated to /usr/bin/python3 — the API returns pretty-printed
# JSON with spaces, which grep/sed can't reliably parse.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Defaults
PHRASE=""
PERIOD="monthly"
FROM_DATE=""
TO_DATE=""
REGIONS=""
DEVICES="all"

# Parse args
while [[ $# -gt 0 ]]; do
    case $1 in
        --phrase|-p) PHRASE="$2"; shift 2 ;;
        --period) PERIOD="$2"; shift 2 ;;
        --from-date|-f) FROM_DATE="$2"; shift 2 ;;
        --to-date|-t) TO_DATE="$2"; shift 2 ;;
        --regions|-r) REGIONS="$2"; shift 2 ;;
        --devices|-d) DEVICES="$2"; shift 2 ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

if [[ -z "$PHRASE" ]]; then
    echo "Usage: dynamics.sh --phrase \"search query\" [options]"
    echo ""
    echo "Options:"
    echo "  --phrase, -p    Search phrase (required, plain text — no Wordstat operators)"
    echo "  --period        Grouping: daily, weekly, monthly (default: monthly)"
    echo "  --from-date, -f Start date YYYY-MM-DD (default: 1 year ago)"
    echo "  --to-date, -t   End date YYYY-MM-DD (default: today; for monthly period"
    echo "                  it's auto-adjusted to the last day of its month)"
    echo "  --regions, -r   Region IDs, comma-separated (optional)"
    echo "  --devices, -d   Device filter: all, desktop, phone, tablet (default: all)"
    echo ""
    echo "Examples:"
    echo "  bash scripts/dynamics.sh --phrase \"юрист дтп\" --from-date 2025-01-01"
    echo "  bash scripts/dynamics.sh --phrase \"юрист\" --period weekly --from-date 2025-06-01"
    exit 1
fi

load_config

# Set default from_date if not provided
if [[ -z "$FROM_DATE" ]]; then
    FROM_DATE=$(date -v-1y +%Y-%m-%d 2>/dev/null || date -d "1 year ago" +%Y-%m-%d 2>/dev/null || echo "2025-01-01")
fi

# Set default to_date if not provided
if [[ -z "$TO_DATE" ]]; then
    TO_DATE=$(date +%Y-%m-%d)
fi

PERIOD_ENUM="$(period_enum "$PERIOD")"

# API requires toDate to be the last day of the month for PERIOD_MONTHLY, else INVALID_ARGUMENT
if [[ "$PERIOD_ENUM" == "PERIOD_MONTHLY" ]]; then
    ADJUSTED_TO_DATE="$(last_day_of_month "$TO_DATE")"
    if [[ "$ADJUSTED_TO_DATE" != "$TO_DATE" ]]; then
        echo "Note: period=monthly requires toDate to be the last day of the month." >&2
        echo "      Adjusted --to-date from $TO_DATE to $ADJUSTED_TO_DATE" >&2
        TO_DATE="$ADJUSTED_TO_DATE"
    fi
fi

FROM_DATE_TS="$(to_rfc3339 "$FROM_DATE")"
TO_DATE_TS="$(to_rfc3339 "$TO_DATE")"

# Escape phrase for JSON
PHRASE_ESCAPED=$(json_escape "$PHRASE")

# Build JSON params (folderId is added automatically by wordstat_request)
PARAMS="{\"phrase\":\"$PHRASE_ESCAPED\",\"period\":\"$PERIOD_ENUM\",\"fromDate\":\"$FROM_DATE_TS\",\"toDate\":\"$TO_DATE_TS\""

if [[ -n "$REGIONS" ]]; then
    PARAMS="$PARAMS,\"regions\":$(build_regions_json "$REGIONS")"
fi

if [[ "$DEVICES" != "all" ]]; then
    PARAMS="$PARAMS,\"devices\":\"$(device_enum "$DEVICES")\""
fi

PARAMS="$PARAMS}"

echo "=== Yandex Wordstat: Dynamics ==="
echo "Phrase: $PHRASE"
echo "Period: $PERIOD ($PERIOD_ENUM)"
echo "From: $FROM_DATE"
echo "To: $TO_DATE"
[[ -n "$REGIONS" ]] && echo "Regions: $REGIONS"
echo "Devices: $DEVICES"
echo ""
echo "Fetching data..."

TMPFILE="${TMPDIR:-/tmp}/ws_dynamics_$$.json"
trap 'rm -f "$TMPFILE"' EXIT

wordstat_request "dynamics" "$PARAMS" > "$TMPFILE"

/usr/bin/python3 - "$TMPFILE" <<'PYEOF'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as f:
    raw = f.read()

try:
    obj = json.loads(raw)
except json.JSONDecodeError:
    print("Error: invalid JSON response")
    print(raw[:2000])
    sys.exit(1)

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

print()
print("=== Results ===")
print()
print("| Date | Count | Share |")
print("|------|-------|-------|")
for r in results:
    date = (r.get("date") or "").split("T")[0]
    count = fmt(r.get("count", "0"))
    share = r.get("share")
    share_str = f"{share:.4f}" if isinstance(share, (int, float)) else str(share)
    print(f"| {date} | {count} | {share_str} |")

print()
print("=== Raw JSON ===")
print(json.dumps(obj, ensure_ascii=False)[:2000])
print()
print("[truncated if > 2000 chars]")
PYEOF
