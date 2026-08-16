#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════
# queue-preview.sh — открыть слот очереди в превью-студии для проверки
# ПЕРЕД рендером (гейт автора с 2026-08-06).
#
# Запуск:  scripts/queue-preview.sh NN [dark|light]   (по умолчанию dark)
#          scripts/queue-preview.sh --stop            погасить превью-серверы
#
# Как работает: как queue-render.sh — композиция слота «въезжает» в
# index.html (студия превьюит только корневую композицию), затем стартует
# `hyperframes preview`, браузер открывается сам. Переключить тему =
# запустить ещё раз с другой темой: файл подменится, студия перечитает
# (если вкладка не обновилась — F5). После «ок» автора превью гасится
# (--stop) и запускается обычный queue-render.sh.
# ══════════════════════════════════════════════════════════════
set -euo pipefail
cd "$(dirname "$0")/.."

HF_VERSION="0.7.26"

if [ "${1:-}" = "--stop" ]; then
  npx --yes hyperframes@${HF_VERSION} preview --kill-all
  exit 0
fi

# рендер держит index.html — превью в это время подменит ему композицию
if [ -d .render.lock ]; then
  echo "✗ Идёт рендер (.render.lock) — дождись его, превью потом."
  exit 1
fi

NN="${1:-}"
[ -n "$NN" ] || { echo "✗ Укажи номер слота: scripts/queue-preview.sh 87 [dark|light]"; exit 1; }
THEME="${2:-dark}"

SLOT="queue/video-${NN}"
[ -d "$SLOT" ] || { echo "✗ Слот не найден: $SLOT"; exit 1; }
if [ "$THEME" = light ]; then SRC="$SLOT/composition-light.html"; else SRC="$SLOT/composition.html"; fi
[ -s "$SRC" ] || { echo "✗ Композиция не найдена: $SRC (сначала вёрстка)"; exit 1; }
[ -s "$SLOT/audio.mp3" ] && cp "$SLOT/audio.mp3" inbox/audio.mp3

# ── гейт рамок-подсветок: ДО показа автору (с 2026-08-08) ───────────────
# Рамка внутри зумящегося скрина системно «съезжала» при правках зума и
# ловилась только глазами на QA-кадрах — то есть уже после рендера.
# Проверка идёт здесь, чтобы съехавшая рамка не доходила до превью.
# Обойти осознанно: SKIP_HL_CHECK=1 scripts/queue-preview.sh NN
if [ "${SKIP_HL_CHECK:-0}" != "1" ] && grep -q 'shot-hl' "$SRC"; then
  if ! node scripts/check-highlights.mjs "$SRC"; then
    echo "✗ Превью НЕ открыто: сначала почини рамки выше (кропы — в renders/hl-check/)."
    exit 1
  fi
  echo "  ↑ цифры сошлись — ОБЯЗАТЕЛЬНО посмотреть кропы глазами: на том ли объекте рамка."
fi

# ── страховка: не затереть композицию прошлого ролика (как в queue-render.sh),
#    композиции текущего слота — не «неспасённое», их копия и так в слоте ─────
if [ -f index.html ] \
   && ! cmp -s index.html templates/new-video.html \
   && ! cmp -s index.html templates/new-video-light.html; then
  ARCHIVED=no
  for a in past-videos/*.html "$SLOT"/composition*.html; do
    [ -f "$a" ] || continue
    if cmp -s index.html "$a"; then ARCHIVED=yes; break; fi
  done
  if [ "$ARCHIVED" = no ]; then
    cp index.html "past-videos/_unsaved-$(date +%Y%m%d-%H%M%S).html"
    echo "→ Прошлый index.html нигде не заархивирован — сохранил копию в past-videos/"
  fi
fi

cp "$SRC" index.html
echo "→ В превью: слот $NN, тема $THEME"
npx --yes hyperframes@${HF_VERSION} preview
