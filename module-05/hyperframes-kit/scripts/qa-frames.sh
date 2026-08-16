#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════
# QA-кадры: по ДВА кадра на каждую сцену — СТЫК (start+0.25с, переход в
# разгаре) и СЕРЕДИНА окна.
#
#   scripts/qa-frames.sh                      — свежайший MP4 из renders/
#   scripts/qa-frames.sh путь/x.mp4           — конкретный файл
#   scripts/qa-frames.sh путь/x.mp4 comp.html — явно указать композицию
#
# Сцены (div class="scene clip" + data-start/data-duration) скрипт берёт из
# РОДНОЙ композиции ролика: по имени MP4 ищет queue/video-NN/…, затем
# past-videos/video-NN…; только если не нашёл — index.html. Раньше всегда
# читался index.html, а там после queue-render лежит ПОСЛЕДНЯЯ отрендеренная
# тема — для кадров другой версии тайминги сцен могли не совпадать.
# Если сцен не нашлось нигде — фолбэк: кадр каждые 4с.
# Кадры → renders/qa-frames/  (папка пересоздаётся).
#
# Что проверять глазами на каждом кадре:
#   • overflow — текст не уходит за 1080×1920
#   • зона аватара (x<540, y>1248) ПУСТАЯ
#   • правый-нижний угол НЕ пустой (rb-chip)
#   • субтитры в своей полосе (y 1080–1250), не под контентом
#   • паттерн сцены читается, акцент-цвет на месте
#   • на кадрах *-cut-*: переход отрабатывает чисто — от уходящей сцены нет
#     хвостов (недосброшенный transform/overflow), входящая не застряла в
#     стартовой позе за кадром
#   • КРАСНЫЕ РАМКИ на кадрах — UI-зоны площадок (TikTok/Reels/Shorts):
#     справа x>940 (иконки лайк/коммент/шер, y 840–1750) и низ y>1690
#     (подпись/прогресс). ТЕКСТ и смысловые элементы в них не ставить;
#     персонаж и фон — можно. Отключить разметку: ZONES=0 scripts/qa-frames.sh
# ══════════════════════════════════════════════════════════════
set -euo pipefail
cd "$(dirname "$0")/.."

MP4="${1:-$(ls -t renders/*.mp4 2>/dev/null | head -1)}"
[ -n "$MP4" ] && [ -f "$MP4" ] || { echo "✗ Нет MP4 (renders/ пуст?)"; exit 1; }
OUT=renders/qa-frames
rm -rf "$OUT" && mkdir -p "$OUT"
echo "→ Источник: $MP4"

DUR=$(ffprobe -v error -show_entries format=duration -of default=nw=1:nk=1 "$MP4")
COUNT=0

# ── родная композиция ролика: второй аргумент → queue → past-videos → index ──
HTML="${2:-}"
if [ -z "$HTML" ]; then
  HTML=index.html
  BASE="$(basename "$MP4")"
  if [[ "$BASE" =~ ^video-([0-9]+)(-light)?-final\.mp4$ ]]; then
    nn="${BASH_REMATCH[1]}"
    if [ "${BASH_REMATCH[2]:-}" = "-light" ]; then
      CANDS="queue/video-${nn}/composition-light.html past-videos/video-${nn}-light.html"
    else
      CANDS="queue/video-${nn}/composition.html past-videos/video-${nn}.html"
    fi
    for c in $CANDS; do
      [ -s "$c" ] && { HTML="$c"; break; }
    done
  fi
fi
echo "→ Сцены из: $HTML"

# Разметка UI-зон площадок (красные рамки) на каждом кадре, ZONES=0 — выкл.
# Правая колонка иконок: x 940–1080, y 840–1750. Низ (подпись/прогресс): y>1690.
VF="null"
if [ "${ZONES:-1}" != 0 ]; then
  VF="drawbox=x=940:y=840:w=139:h=910:color=red@0.85:t=4,drawbox=x=0:y=1690:w=1079:h=229:color=red@0.85:t=4"
fi

# по два кадра на сцену: стык перехода (start+0.25) и середина окна
while IFS=$'\t' read -r id start dur; do
  tcut=$(python3 -c "print(max(0.05, min(round($start + 0.25, 2), $DUR - 0.1)))")
  tmid=$(python3 -c "print(min(round($start + $dur/2, 2), $DUR - 0.1))")
  ffmpeg -y -loglevel error -ss "$tcut" -i "$MP4" -vf "$VF" -frames:v 1 "$OUT/${id}-cut-${tcut}s.png"
  ffmpeg -y -loglevel error -ss "$tmid" -i "$MP4" -vf "$VF" -frames:v 1 "$OUT/${id}-mid-${tmid}s.png"
  COUNT=$((COUNT+2))
done < <(grep -o '<div id="[^"]*" class="scene clip" data-start="[^"]*" data-duration="[^"]*"' "$HTML" 2>/dev/null \
  | sed -E 's/<div id="([^"]*)" class="scene clip" data-start="([^"]*)" data-duration="([^"]*)"/\1\t\2\t\3/' || true)

# фолбэк: каждые 4 секунды
if [ "$COUNT" -eq 0 ]; then
  echo "⚠ Сцены в index.html не найдены — фолбэк: кадр каждые 4с"
  t=1
  while python3 -c "exit(0 if $t < $DUR else 1)"; do
    ffmpeg -y -loglevel error -ss "$t" -i "$MP4" -vf "$VF" -frames:v 1 "$OUT/t-${t}s.png"
    COUNT=$((COUNT+1)); t=$((t+4))
  done
fi

echo "✓ $COUNT кадров в $OUT/ — чеклист проверки в шапке этого скрипта"
