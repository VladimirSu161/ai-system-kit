#!/bin/bash
# Show Yandex region IDs — live tree from Wordstat API v2 (getRegionsTree, free)
# plus a quick static reference for the most commonly used IDs.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

load_config

CACHE_FILE="$CACHE_DIR/regions_tree.json"
mkdir -p "$CACHE_DIR"

echo "=== Yandex Wordstat: Regions Tree ==="
echo ""

if [[ -f "$CACHE_FILE" ]] && find "$CACHE_FILE" -mtime -30 >/dev/null 2>&1 && [[ -n "$(find "$CACHE_FILE" -mtime -30 2>/dev/null)" ]]; then
    echo "Using cached tree: cache/regions_tree.json (older than 30 days? delete it to refetch)"
else
    echo "Fetching region tree (free — getRegionsTree)..."
    wordstat_request "getRegionsTree" "{}" > "$CACHE_FILE"
fi

if grep -q '"message"' "$CACHE_FILE" && ! grep -q '"regions"' "$CACHE_FILE"; then
    echo "Error:"
    cat "$CACHE_FILE"
    exit 1
fi

/usr/bin/python3 - "$CACHE_FILE" <<'PYEOF'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as f:
    data = json.load(f)

regions = data.get("regions", [])


def find(node_list, target_id):
    for n in node_list:
        if n.get("id") == target_id:
            return n
        found = find(n.get("children", []), target_id)
        if found:
            return found
    return None


def count_nodes(node_list):
    total = 0
    for n in node_list:
        total += 1
        total += count_nodes(n.get("children", []))
    return total


print("Top-level (continents/countries):")
for r in regions:
    print(f"  {r.get('id'):>6}  {r.get('label')}")

russia = find(regions, "225")
if russia:
    print()
    print("Russia (225) -> federal districts:")
    for r in russia.get("children", []):
        print(f"  {r.get('id'):>6}  {r.get('label')}")

print()
print(f"Total regions in tree: {count_nodes(regions)}")
PYEOF

echo ""
echo "Full tree cached at: cache/regions_tree.json"
echo "Search it directly for a specific city, e.g.:"
echo "  grep -o '\"id\":\"[0-9]*\",\"label\":\"[^\"]*Казан[^\"]*\"' cache/regions_tree.json"
echo ""
echo "=== Quick reference: common region IDs ==="
echo ""
echo "Countries:"
echo "  225 - Россия"
echo "  159 - Казахстан"
echo "  187 - Украина"
echo "  149 - Беларусь"
echo ""
echo "Federal Districts (Russia):"
echo "  3      - Центр"
echo "  17     - Северо-Запад"
echo "  40     - Поволжье"
echo "  52     - Урал"
echo "  59     - Сибирь"
echo "  26     - Юг"
echo "  73     - Дальний Восток"
echo "  977    - Республика Крым"
echo "  102444 - Северный Кавказ"
echo ""
echo "Major Cities:"
echo "  213 - Москва"
echo "  2   - Санкт-Петербург"
echo "  54  - Екатеринбург"
echo "  65  - Новосибирск"
echo "  43  - Казань"
echo "  35  - Краснодар"
echo "  47  - Нижний Новгород"
echo "  39  - Ростов-на-Дону"
echo "  51  - Самара"
echo "  172 - Уфа"
echo ""
echo "Moscow Region:"
echo "  1   - Москва и область (город + область вместе)"
echo "  213 - Москва (только город)"
echo ""
echo "Use these IDs with --regions parameter in other scripts."
echo "Example: bash scripts/top_requests.sh --phrase \"test\" --regions 213"
