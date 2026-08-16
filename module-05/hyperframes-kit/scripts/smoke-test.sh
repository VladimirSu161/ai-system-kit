#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════
# Смоук-тест рендер-пайплайна HyperFrames.
#
#   scripts/smoke-test.sh          — на текущей (пиновой) версии
#   scripts/smoke-test.sh 0.8.3    — на другой версии (проверка ПЕРЕД
#                                    обновлением пина в package.json)
#
# Рендерит templates/smoke-test.html (4с, shared-файлы + локальные
# шрифты) и вытаскивает 2 контрольных кадра. Смотреть глазами:
#   кадр 1 — пилюля (JetBrains Mono), «ТЕСТ» + счётчик (Inter 900),
#            karaoke-пилюля с амбер-подсветкой, rb-chip;
#   кадр 2 — rainbow-заголовок, зелёный бар 85%, субтитры.
# Если кадры выглядят как обычно — версию можно пиновать.
# ══════════════════════════════════════════════════════════════
set -euo pipefail
cd "$(dirname "$0")/.."

PIN=$(grep -o 'hyperframes@[0-9][0-9.]*' package.json | head -1 | cut -d@ -f2)
VER="${1:-$PIN}"
echo "→ Смоук-тест на hyperframes@${VER} (пин в package.json: ${PIN})"

# композиция должна лежать в корне (относительные пути shared/, assets/)
cp templates/smoke-test.html __smoke-test.html
trap 'rm -f __smoke-test.html' EXIT

npx --yes "hyperframes@${VER}" render -c __smoke-test.html \
  -o renders/__smoke-test.mp4 -q draft --quiet

mkdir -p renders/smoke-frames
ffmpeg -y -loglevel error -ss 1.2 -i renders/__smoke-test.mp4 -frames:v 1 renders/smoke-frames/frame-1.png
ffmpeg -y -loglevel error -ss 3.2 -i renders/__smoke-test.mp4 -frames:v 1 renders/smoke-frames/frame-2.png

echo ""
echo "✓ Рендер прошёл. Проверить глазами контрольные кадры:"
echo "  renders/smoke-frames/frame-1.png  (пилюля, ТЕСТ, счётчик, караоке)"
echo "  renders/smoke-frames/frame-2.png  (rainbow, бар 85%, субтитры)"
echo "  видео: renders/__smoke-test.mp4"
