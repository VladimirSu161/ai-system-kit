#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════
# queue-render.sh — отрендерить слот очереди (обе версии или одну).
#
# Запуск:  scripts/queue-render.sh NN [dark|light|both] [доп. флаги render]
#          по умолчанию — тема из meta.txt слота (обычно both)
#
# Почему через подстановку в index.html, а не рендер прямо из queue/:
# линтер движка запрещает несколько корневых композиций
# (multiple_root_compositions), а относительные пути к shared/ и assets/
# внутри композиции рассчитаны на корень проекта. Поэтому слот на время
# рендера «въезжает» в index.html — рендер-таргет всегда ровно один.
#
# ⚠ Рендеры идут строго ПО ОЧЕРЕДИ. Движок сам разбрасывает работу по ядрам
# (--workers auto, каждый воркер = отдельный Chrome ~256 МБ). Два параллельных
# рендера делят те же ядра, не ускоряя итог, зато упираются в память — а при
# нехватке памяти капчур срывается в capture-attempt-N.
#
# Финалы уезжают в ~/Desktop/Ролики HyperFrames/ — оттуда автор смотрит и
# отбирает ролики для автопостинга. Кухня (work-*, qa-frames, smoke-frames)
# остаётся в renders/ внутри проекта.
# ══════════════════════════════════════════════════════════════
set -euo pipefail
cd "$(dirname "$0")/.."

# ── лок: два параллельных рендера дерутся за index.html и за память ──────────
# (запрет словами уже был в SKILL.md, лок делает его физическим)
LOCK=".render.lock"
if ! mkdir "$LOCK" 2>/dev/null; then
  echo "✗ Похоже, уже идёт другой рендер (${LOCK}/ существует)."
  echo "  Дождись его. Если это остаток после сбоя — удали: rmdir ${LOCK}"
  exit 1
fi
trap 'rmdir "$LOCK" 2>/dev/null || true' EXIT

HF_VERSION="0.7.26"
DESKTOP_OUT="$HOME/Desktop/Ролики HyperFrames"

NN="${1:-}"
[ -n "$NN" ] || { echo "✗ Укажи номер слота: scripts/queue-render.sh 87 [dark|light|both]"; exit 1; }
shift

SLOT="queue/video-${NN}"
[ -d "$SLOT" ]           || { echo "✗ Слот не найден: $SLOT"; exit 1; }
[ -s "$SLOT/audio.mp3" ] || { echo "✗ Нет голоса: $SLOT/audio.mp3"; exit 1; }

# ── какие темы рендерим: аргумент → meta.txt → both ───────────────────────────
WANT=""
case "${1:-}" in
  dark|light|both) WANT="$1"; shift ;;
esac
if [ -z "$WANT" ]; then
  WANT=$(grep -E '^тема:' "$SLOT/meta.txt" 2>/dev/null | awk '{print $2}' || true)
fi
[ -n "$WANT" ] || WANT=both
case "$WANT" in
  dark)  THEMES="dark" ;;
  light) THEMES="light" ;;
  *)     THEMES="dark light" ;;
esac

mkdir -p "$DESKTOP_OUT"

# ── страховка: не затереть композицию прошлого ролика, если её не сохранили ───
if [ -f index.html ] \
   && ! cmp -s index.html templates/new-video.html \
   && ! cmp -s index.html templates/new-video-light.html; then
  ARCHIVED=no
  for a in past-videos/*.html; do
    [ -f "$a" ] || continue
    if cmp -s index.html "$a"; then ARCHIVED=yes; break; fi
  done
  if [ "$ARCHIVED" = no ]; then
    cp index.html "past-videos/_unsaved-$(date +%Y%m%d-%H%M%S).html"
    echo "→ Прошлый index.html нигде не заархивирован — сохранил копию в past-videos/"
  fi
fi

cp "$SLOT/audio.mp3" inbox/audio.mp3

render_one () {
  local theme="$1" src arch out
  shift   # дальше в "$@" остаются только доп. флаги render, без темы
  if [ "$theme" = light ]; then
    src="$SLOT/composition-light.html"; arch="past-videos/video-${NN}-light.html"
    out="$DESKTOP_OUT/video-${NN}-light-final.mp4"
  else
    src="$SLOT/composition.html";       arch="past-videos/video-${NN}.html"
    out="$DESKTOP_OUT/video-${NN}-final.mp4"
  fi

  if [ ! -s "$src" ]; then
    echo "⤼ Пропускаю $theme — нет вёрстки $src"
    return 0
  fi

  echo ""
  echo "════ video-${NN} · тема $theme ════"
  cp "$src" index.html

  # Линт БЛОКИРУЕТ рендер при ошибках: рендер долгий, и словить сломанную
  # композицию до него дешевле, чем через N минут на QA-кадрах.
  # Итоговая строка линтера выглядит как «◇  1 error(s), 1 warning(s)».
  # Предупреждения не блокируют. Обойти разово: LINT_SOFT=1 scripts/queue-render.sh …
  echo "→ Линт…"
  local lint_out
  lint_out=$(npx --yes hyperframes@${HF_VERSION} lint 2>&1 || true)
  echo "$lint_out"
  if echo "$lint_out" | grep -qE '[1-9][0-9]* error' && [ "${LINT_SOFT:-}" != 1 ]; then
    echo "✗ Линтер нашёл ошибки в композиции $theme — останавливаюсь (следующие темы тоже не пойдут)."
    echo "  Почини и повтори, или осознанно продави: LINT_SOFT=1 scripts/queue-render.sh ${NN} ${theme}"
    return 1
  fi

  # Инспектор геометрии: ловит content_overlap контента сцен со словами
  # караоке (#cw*) и container_overflow — то есть ровно тот дефект, когда
  # блок сцены наезжает на полосу субтитров. Раньше не запускался, и
  # наложения находились только глазами на QA-кадрах, уже после рендера.
  # Шум на стыках сцен — норма (окна переходов специально перекрываются);
  # тревожно, когда пересечение держится на нескольких сэмплах подряд.
  echo "→ Геометрия (наложения на субтитры)…"
  npx --yes hyperframes@${HF_VERSION} inspect 2>&1 \
    | grep -E "content_overlap|container_overflow|layout issues|error\(s\)" | head -20 || true

  echo "→ Рендер → $out"
  npx --yes hyperframes@${HF_VERSION} render --output "$out" "$@"

  cp index.html "$arch"
  echo "финал $theme: $out ($(date '+%Y-%m-%d %H:%M'))" >> "$SLOT/meta.txt"
  echo "✓ $out"
}

for t in $THEMES; do
  render_one "$t" "$@"
done

echo ""
echo "✓ Слот video-${NN} отрендерен. Смотреть: $DESKTOP_OUT"
