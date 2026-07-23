#!/bin/bash
# Общие функции для Yandex Wordstat (Yandex Cloud Search API v2)
#
# Старый api.wordstat.yandex.net (OAuth) закрыт. Актуальный API:
#   https://searchapi.api.cloud.yandex.net/v2/wordstat/{method}
#   Методы: topRequests, dynamics, regions, getRegionsTree
#   Авторизация: заголовок "Authorization: Api-Key <ключ>" (НЕ Bearer)
#   В теле каждого запроса обязателен "folderId"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/../config/.env"
CACHE_DIR="$SCRIPT_DIR/../cache"
WORDSTAT_API="https://searchapi.api.cloud.yandex.net/v2/wordstat"
# Легаси-эндпоинт Yandex Direct — не используется скриптами этого скилла, см. api_request() ниже
DIRECT_API_URL="https://api.direct.yandex.com/json/v5/"

# Load config
load_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        # shellcheck disable=SC1090
        source "$CONFIG_FILE"
    fi

    if [[ -z "$YANDEX_API_KEY" || -z "$YANDEX_FOLDER_ID" ]]; then
        echo "Error: YANDEX_API_KEY и/или YANDEX_FOLDER_ID не заданы."
        echo "Задайте их в config/.env — см. config/README.md для инструкции."
        exit 1
    fi
}

# Легаси-функция для Yandex Direct API (json/v5). В скриптах скилла не используется —
# оставлена для совместимости, если понадобится обращение к Директу. Не тестировалась
# после перехода на Api-Key (Директ обычно требует OAuth Bearer + Client-Login).
# Usage: api_request "method" "params_json"
api_request() {
    local method="$1"
    local params="$2"

    local payload
    if [[ -n "$params" ]]; then
        payload="{\"method\":\"$method\",\"params\":$params}"
    else
        payload="{\"method\":\"$method\"}"
    fi

    curl -s -X POST "$DIRECT_API_URL" \
        -H "Authorization: Bearer $YANDEX_API_KEY" \
        -H "Content-Type: application/json; charset=utf-8" \
        -H "Accept-Language: ru" \
        -d "$payload"
}

# Добавляет "folderId" в JSON-тело запроса (обязателен для каждого метода Wordstat API v2)
# Usage: inject_folder_id '{"phrase":"тест"}' -> {"phrase":"тест","folderId":"..."}
inject_folder_id() {
    local params="$1"
    if [[ -z "$params" || "$params" == "{}" ]]; then
        printf '{"folderId":"%s"}' "$YANDEX_FOLDER_ID"
    else
        printf '%s,"folderId":"%s"}' "${params%\}}" "$YANDEX_FOLDER_ID"
    fi
}

# Make Wordstat API v2 request. folderId подставляется автоматически — вызывающему
# скрипту передавать его в params не нужно.
# Usage: wordstat_request "method" "params_json"
# Методы: topRequests, dynamics, regions, getRegionsTree
wordstat_request() {
    local method="$1"
    local params="$2"

    local body
    body="$(inject_folder_id "$params")"

    curl -s -X POST "$WORDSTAT_API/$method" \
        -H "Authorization: Api-Key $YANDEX_API_KEY" \
        -H "Content-Type: application/json; charset=utf-8" \
        -d "$body"
}

# Map --devices значение в enum API (default: DEVICE_ALL)
device_enum() {
    case "$1" in
        desktop) echo "DEVICE_DESKTOP" ;;
        phone) echo "DEVICE_PHONE" ;;
        tablet) echo "DEVICE_TABLET" ;;
        *) echo "DEVICE_ALL" ;;
    esac
}

# Map --period значение в enum API (default: PERIOD_MONTHLY)
period_enum() {
    case "$1" in
        daily) echo "PERIOD_DAILY" ;;
        weekly) echo "PERIOD_WEEKLY" ;;
        *) echo "PERIOD_MONTHLY" ;;
    esac
}

# Map --region-type значение в enum API (default: REGION_ALL)
region_type_enum() {
    case "$1" in
        cities) echo "REGION_CITIES" ;;
        regions) echo "REGION_REGIONS" ;;
        *) echo "REGION_ALL" ;;
    esac
}

# Строит JSON-массив строк из CSV списка ID регионов (API v2 требует regions как массив строк)
# Usage: build_regions_json "213,1" -> ["213","1"]
build_regions_json() {
    local csv="$1"
    local out="["
    local first=1
    local id
    IFS=',' read -ra _ids <<< "$csv"
    for id in "${_ids[@]}"; do
        id="$(echo "$id" | tr -d '[:space:]')"
        [[ -z "$id" ]] && continue
        if [[ $first -eq 1 ]]; then
            out="$out\"$id\""
            first=0
        else
            out="$out,\"$id\""
        fi
    done
    out="$out]"
    echo "$out"
}

# Последний день месяца для даты YYYY-MM-DD (нужен для dynamics с PERIOD_MONTHLY)
# macOS/BSD date, с фолбэком на GNU date
last_day_of_month() {
    local d="$1"
    date -j -v1d -v+1m -v-1d -f "%Y-%m-%d" "$d" "+%Y-%m-%d" 2>/dev/null \
        || date -d "$(echo "$d" | cut -c1-7)-01 +1 month -1 day" "+%Y-%m-%d" 2>/dev/null \
        || echo "$d"
}

# Превращает YYYY-MM-DD в RFC3339-таймстамп, требуемый API (google.protobuf.Timestamp)
# Usage: to_rfc3339 "2026-06-30" -> 2026-06-30T00:00:00Z
to_rfc3339() {
    local d="$1"
    case "$d" in
        *T*Z|*T*+*) echo "$d" ;;  # уже похоже на полный timestamp
        *) echo "${d}T00:00:00Z" ;;
    esac
}

# Извлечь JSON-значение по ключу (число или строка-число, включая обёрнутые в кавычки
# protobuf int64 вида "count":"123"). Всегда возвращает "чистое" значение без кавычек.
# Usage: json_value "$json" "key"
json_value() {
    local json="$1"
    local key="$2"
    echo "$json" | grep -o "\"$key\":[^,}]*" | head -1 | sed 's/.*://' | tr -d '"[:space:]'
}

# Extract JSON string value (handles strings with quotes)
json_string() {
    local json="$1"
    local key="$2"
    echo "$json" | grep -o "\"$key\":\"[^\"]*\"" | head -1 | sed 's/.*:"//' | tr -d '"'
}

# Extract JSON array
json_array() {
    local json="$1"
    local key="$2"
    echo "$json" | grep -o "\"$key\":\[[^]]*\]" | head -1 | sed 's/.*:\[/[/'
}

# Escape string for JSON
json_escape() {
    local str="$1"
    str="${str//\\/\\\\}"
    str="${str//\"/\\\"}"
    str="${str//$'\n'/\\n}"
    str="${str//$'\t'/\\t}"
    echo "$str"
}

# Format number with thousands separator (macOS compatible)
format_number() {
    local num="$1"
    # Убираем кавычки на случай, если передали "count":"123" как есть
    num="${num//\"/}"
    # Use printf for cross-platform compatibility
    printf "%'d" "$num" 2>/dev/null || echo "$num"
}
