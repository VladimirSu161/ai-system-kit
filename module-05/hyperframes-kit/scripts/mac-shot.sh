#!/bin/bash
# ══════════════════════════════════════════════════════════════
# mac-shot.sh — скриншот окна программы на Mac для вставки в ролик.
#
# Пара к shot.mjs (публичный веб) и Claude in Chrome (страницы за логином):
# третий маршрут — программы самого Mac (Obsidian, Finder, терминал, редактор).
# Правила вставки — CLAUDE.md, раздел «Скриншоты и видеоклипы».
#
#   scripts/mac-shot.sh <Приложение> inbox/screenshots/<якорь>.png [--url <uri>] [--wait <сек>]
#
#   <Приложение> — имя как в /Applications (Obsidian, Finder, TextEdit…)
#   --url  — открыть контекст перед съёмкой (obsidian://…, file:///путь)
#   --wait — пауза после активации, сек (по умолчанию 2; тяжёлым окнам — больше)
#
# Снимает ТОЛЬКО прямоугольник переднего окна программы; на retina-экране
# PNG получается ×2 — в кадре 1080 хрустит.
#
# Разовая настройка macOS (Настройки → Конфиденциальность и безопасность):
#   «Запись экрана и системный звук» — терминалу (для screencapture),
#   «Универсальный доступ»          — терминалу (для позиции окна).
# Первый запуск сам покажет системные диалоги — выдать и повторить команду.
# ══════════════════════════════════════════════════════════════
set -euo pipefail

APP="${1:-}"; OUT="${2:-}"
if [[ -z "$APP" || -z "$OUT" ]]; then
  echo "Использование: scripts/mac-shot.sh <Приложение> inbox/screenshots/<якорь>.png [--url <uri>] [--wait <сек>]" >&2
  exit 1
fi
shift 2
URL=""; WAIT=2
while [[ $# -gt 0 ]]; do
  case "$1" in
    --url)  URL="$2";  shift 2 ;;
    --wait) WAIT="$2"; shift 2 ;;
    *) echo "✗ Неизвестный аргумент: $1" >&2; exit 1 ;;
  esac
done

# 1. Открыть контекст (если задан) и вывести программу на передний план
if [[ -n "$URL" ]]; then open "$URL"; fi
open -a "$APP"
sleep "$WAIT"

# 2. Кто реально на переднем плане + прямоугольник его переднего окна.
#    Берём frontmost-процесс (а не ищем по имени): у некоторых программ
#    имя процесса не совпадает с именем приложения.
FRONT=$(osascript -e 'tell application "System Events" to get name of first process whose frontmost is true')
if [[ "$FRONT" != "$APP" ]]; then
  echo "⚠ На переднем плане «${FRONT}», а не «${APP}» — снимаю его окно; проверь скрин глазами" >&2
fi
BOUNDS=$(osascript -e '
tell application "System Events"
  tell (first process whose frontmost is true)
    set {x, y} to position of front window
    set {w, h} to size of front window
  end tell
end tell
return (x as text) & "," & (y as text) & "," & (w as text) & "," & (h as text)')

# 3. Снять только это окно (-x — без звука затвора)
mkdir -p "$(dirname "$OUT")"
screencapture -x -R"$BOUNDS" "$OUT"

if [[ ! -s "$OUT" ]]; then
  echo "✗ Файл не создан — проверь разрешение «Запись экрана» у терминала" >&2
  exit 1
fi
PX=$(sips -g pixelWidth -g pixelHeight "$OUT" | awk '/pixel/ {printf "%s×", $2}' | sed 's/×$//')
echo "✓ $OUT  ($FRONT, окно $BOUNDS pt → ${PX}px)"
