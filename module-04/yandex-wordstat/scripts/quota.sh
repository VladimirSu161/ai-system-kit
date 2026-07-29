#!/bin/bash
# Check Yandex Wordstat API v2 connection (Yandex Cloud Search API)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

load_config

echo "Checking Wordstat API v2 connection..."
echo ""

TMPFILE="${TMPDIR:-/tmp}/ws_quota_$$.json"
trap 'rm -f "$TMPFILE"' EXIT

# Test with a cheap regions request
wordstat_request "regions" '{"phrase":"тест","region":"REGION_ALL"}' > "$TMPFILE"

/usr/bin/python3 - "$TMPFILE" <<'PYEOF'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as f:
    obj = json.load(f)

if "message" in obj and "results" not in obj:
    print("Wordstat API: Error")
    print(json.dumps(obj, ensure_ascii=False, indent=2))
    sys.exit(1)

results = obj.get("results", [])
print("Wordstat API: OK")
print()
print(f"Test query 'тест' returned data for {len(results)} regions")
PYEOF

echo ""
echo "=== API Limits ==="
echo "- Rate limit: 10 requests/second"
echo "- Hourly quota: 100 requests/hour"
echo ""
echo "=== Pricing ==="
echo "- topRequests, dynamics: 20 RUB / 1000 requests"
echo "- regions: 50 RUB / 1000 requests"
echo "- getRegionsTree: free"
echo ""
echo "=== Available endpoints ==="
echo "- /v2/wordstat/topRequests    - top search phrases"
echo "- /v2/wordstat/dynamics       - search volume over time"
echo "- /v2/wordstat/regions        - regional distribution"
echo "- /v2/wordstat/getRegionsTree - region ID tree (free)"
echo ""
echo "Note: Wordstat operators (!, +, \"...\", (a|b), minus-words) are NOT supported by API v2."
echo ""
echo "API key is valid and Wordstat API v2 is accessible."
