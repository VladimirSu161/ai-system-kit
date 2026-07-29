#!/bin/bash
# Get regional search statistics from Yandex Wordstat (Yandex Cloud Search API v2)
# Response parsing delegated to /usr/bin/python3 — the API returns pretty-printed
# JSON with spaces, which grep/sed can't reliably parse.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Defaults
PHRASE=""
REGION_TYPE="all"
DEVICES="all"

# Parse args
while [[ $# -gt 0 ]]; do
    case $1 in
        --phrase|-p) PHRASE="$2"; shift 2 ;;
        --region-type|-t) REGION_TYPE="$2"; shift 2 ;;
        --devices|-d) DEVICES="$2"; shift 2 ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

if [[ -z "$PHRASE" ]]; then
    echo "Usage: regions_stats.sh --phrase \"search query\" [options]"
    echo ""
    echo "Options:"
    echo "  --phrase, -p       Search phrase (required, plain text — no Wordstat operators)"
    echo "  --region-type, -t  Filter: cities, regions, all (default: all)"
    echo "  --devices, -d      Device filter: all, desktop, phone, tablet (default: all)"
    echo ""
    echo "Examples:"
    echo "  bash scripts/regions_stats.sh --phrase \"юрист дтп\""
    echo "  bash scripts/regions_stats.sh --phrase \"юрист\" --region-type cities"
    exit 1
fi

load_config

# Escape phrase for JSON
PHRASE_ESCAPED=$(json_escape "$PHRASE")

# Build JSON params (API v2: field is "region", enum REGION_ALL/REGION_CITIES/REGION_REGIONS)
PARAMS="{\"phrase\":\"$PHRASE_ESCAPED\",\"region\":\"$(region_type_enum "$REGION_TYPE")\""

if [[ "$DEVICES" != "all" ]]; then
    PARAMS="$PARAMS,\"devices\":\"$(device_enum "$DEVICES")\""
fi

PARAMS="$PARAMS}"

echo "=== Yandex Wordstat: Regional Statistics ==="
echo "Phrase: $PHRASE"
echo "Region type: $REGION_TYPE"
echo "Devices: $DEVICES"
echo ""
echo "Fetching data..."

TMPFILE="${TMPDIR:-/tmp}/ws_regions_$$.json"
trap 'rm -f "$TMPFILE"' EXIT

wordstat_request "regions" "$PARAMS" > "$TMPFILE"

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
# count is a protobuf-int64-as-string; sort descending by numeric value
try:
    results = sorted(results, key=lambda r: int(r.get("count", 0)), reverse=True)
except (TypeError, ValueError):
    pass

print()
print("=== Top 30 Regions ===")
print()
print("| Region ID | Count | Affinity |")
print("|-----------|-------|----------|")
for r in results[:30]:
    region_id = r.get("region", "")
    count = fmt(r.get("count", "0"))
    affinity = r.get("affinityIndex")
    affinity_str = f"{affinity:.1f}" if isinstance(affinity, (int, float)) else str(affinity)
    print(f"| {region_id} | {count} | {affinity_str} |")

print()
print("Note: Use search_region.sh --name \"City\" to find region names, or scripts/regions_tree.sh for the full tree")
print()
print("=== Raw JSON (first 2000 chars) ===")
print(json.dumps(obj, ensure_ascii=False)[:2000])
print()
print("[truncated]")
PYEOF
