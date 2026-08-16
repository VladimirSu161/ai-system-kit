#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════
# queue-add.sh — завести СЛОТ очереди под один ролик.
#
# Зачем слоты: transcript.json, inbox/audio.mp3 и index.html — имена, общие
# на весь проект. Пока ролик был один, это не мешало; при очереди из
# нескольких роликов второй прогон затирал транскрипт первого. Слот даёт
# каждому ролику свой комплект файлов, и они не дерутся.
#
# Запуск:  scripts/queue-add.sh inbox/NAME-prep.mp4 [NN] [dark|light|both]
#   NN    — номер ролика (по умолчанию: следующий свободный)
#   тема  — both (по умолчанию, обе версии), dark или light
#
# Делает: транскрипция (whisper, ru) → нормализованный голос −14 LUFS →
#         караоке-массив → заготовка композиции из шаблона темы.
# Творческая часть (storyboard, вёрстка, вычитка субтитров) — за агентом.
#
# Результат — queue/video-NN/:
#   audio.mp3          голос, нормализованный до −14 LUFS
#   transcript.json    пословный транскрипт ЭТОГО ролика
#   captions.js        караоке-массив (вычитать ошибки Whisper!)
#   composition.html   заготовка из шаблона — сюда верстать
#   meta.txt           исходник, тема, длительность
# ══════════════════════════════════════════════════════════════
set -euo pipefail
cd "$(dirname "$0")/.."

HF_VERSION="0.7.26"

FILE="${1:-}"
if [ -z "$FILE" ] || [ ! -f "$FILE" ]; then
  echo "✗ Укажи файл: scripts/queue-add.sh inbox/NAME-prep.mp4 [NN] [dark|light]"
  exit 1
fi

# ── номер слота: аргумент → номер из имени файла → следующий свободный ────────
NN="${2:-}"
if [ -z "$NN" ]; then
  FROM_NAME=$(basename "$FILE" | grep -oE '[0-9]{2,3}' | tail -1 || true)
  LAST_ARCH=$(ls past-videos/video-*.html 2>/dev/null | sed -E 's/.*video-([0-9]+)\.html/\1/' | sort -n | tail -1 || true)
  LAST_QUEUE=$(ls -d queue/video-* 2>/dev/null | sed -E 's/.*video-([0-9]+)/\1/' | sort -n | tail -1 || true)
  LAST=$(printf '%s\n%s\n0\n' "${LAST_ARCH:-0}" "${LAST_QUEUE:-0}" | sort -n | tail -1)
  # Номер из имени берём, только если он больше уже занятых И недалеко от них.
  # Без верхней границы дата или счётчик камеры в имени (IMG_4501 → «450»)
  # заводил бы слот video-450 и уводил всю нумерацию.
  if [ -n "$FROM_NAME" ] && [ "$FROM_NAME" -gt "$LAST" ] 2>/dev/null && [ "$FROM_NAME" -le $((LAST + 20)) ]; then
    NN="$FROM_NAME"
  else
    NN=$((LAST + 1))
  fi
fi

# Тема: по умолчанию ОБЕ версии (решение автора 2026-08-03) — тёмная
# dark-amber и светлая Sticker Light. Транскрипт и голос у них общие, разная
# только вёрстка, поэтому обе заготовки живут в одном слоте.
THEME="${3:-both}"
case "$THEME" in
  dark|light|both) ;;
  *) echo "✗ Тема: dark, light или both (передано: $THEME)"; exit 1 ;;
esac
[ "$THEME" = light ] || [ -f "templates/new-video.html" ]       || { echo "✗ Нет templates/new-video.html"; exit 1; }
[ "$THEME" = dark  ] || [ -f "templates/new-video-light.html" ] || { echo "✗ Нет templates/new-video-light.html"; exit 1; }

SLOT="queue/video-${NN}"
if [ -d "$SLOT" ]; then
  echo "✗ Слот уже существует: $SLOT (удали его или задай другой номер)"
  exit 1
fi
mkdir -p "$SLOT"

EXT=$(echo "${FILE##*.}" | tr '[:upper:]' '[:lower:]')
case "$EXT" in
  mp4|mov|m4v|mkv|avi) KIND="видео" ;;
  *)                   KIND="аудио" ;;
esac
echo "→ Слот video-${NN}: $(basename "$FILE") ($KIND, тема $THEME)"

# ── 1. транскрипция — ВСЕГДА заново под этот файл ─────────────────────────────
# transcribe пишет transcript.json жёстко (в корень проекта или рядом с входом),
# своего --output для него нет. Поэтому сразу уносим результат в слот, и
# следующий ролик очереди уже ничего не затирает.
rm -f transcript.json inbox/transcript.json
npx --yes hyperframes@${HF_VERSION} transcribe "$FILE" --model small --language ru
if [ ! -s transcript.json ] && [ -s inbox/transcript.json ]; then
  mv inbox/transcript.json transcript.json
fi
[ -s transcript.json ] || { echo "✗ transcript.json не создан"; exit 1; }
mv transcript.json "$SLOT/transcript.json"

# ── 2. голос: извлечь и нормализовать до −14 LUFS ─────────────────────────────
# Тихий голос — корневая причина жалобы «эффекты громче речи» (видео 84: −31 LUFS).
if [ "$KIND" = "видео" ]; then
  ffmpeg -y -loglevel error -i "$FILE" -vn -c:a libmp3lame -q:a 2 "$SLOT/_raw-audio.mp3"
else
  ffmpeg -y -loglevel error -i "$FILE" -c:a libmp3lame -q:a 2 "$SLOT/_raw-audio.mp3"
fi

MEAS=$(ffmpeg -hide_banner -i "$SLOT/_raw-audio.mp3" \
       -af loudnorm=I=-14:TP=-1.5:LRA=11:print_format=json -f null - 2>&1 \
       | tr -d ' \t",' | grep -E '^(input_i|input_tp|input_lra|input_thresh|target_offset):')
m_i=$(echo   "$MEAS" | grep '^input_i:'      | cut -d: -f2)
m_tp=$(echo  "$MEAS" | grep '^input_tp:'     | cut -d: -f2)
m_lra=$(echo "$MEAS" | grep '^input_lra:'    | cut -d: -f2)
m_th=$(echo  "$MEAS" | grep '^input_thresh:' | cut -d: -f2)
m_off=$(echo "$MEAS" | grep '^target_offset:'| cut -d: -f2)

ffmpeg -y -loglevel error -i "$SLOT/_raw-audio.mp3" \
  -af "loudnorm=I=-14:TP=-1.5:LRA=11:measured_I=${m_i}:measured_TP=${m_tp}:measured_LRA=${m_lra}:measured_thresh=${m_th}:offset=${m_off}:linear=true" \
  -c:a libmp3lame -q:a 2 -ar 48000 "$SLOT/audio.mp3"
rm -f "$SLOT/_raw-audio.mp3"

NEW_I=$(ffmpeg -hide_banner -i "$SLOT/audio.mp3" -af ebur128=framelog=quiet -f null - 2>&1 \
        | grep -A1 "Integrated loudness" | grep "I:" | awk '{print $2}')
DUR=$(ffprobe -v error -show_entries format=duration -of default=nw=1:nk=1 "$SLOT/audio.mp3")
echo "→ Голос: ${NEW_I} LUFS, длительность ${DUR}s"

# ── 3. караоке-массив + заготовка композиции ──────────────────────────────────
node scripts/captions-from-transcript.mjs "$SLOT/transcript.json" "$SLOT/captions.js"

# Длительность ролика проставляем сразу: в шаблоне на весь ролик рассчитаны
# 4–5 элементов с data-duration="60" (корень, голос, ambient, полоса
# субтитров; в светлом шаблоне ещё зона персонажа).
# Тайминги отдельных сцен верстальщик расставляет сам.
# Округляем через bc, а НЕ printf/awk. В системном bash 3.2 при LANG=ru_RU
# printf падает («invalid number»), а awk выдаёт «27,2» с запятой — такая
# запятая ломает атрибут data-duration в HTML. bc от локали не зависит.
DUR_R=$(echo "scale=1; ($DUR+0.05)/1" | bc)
make_draft () {  # $1 — шаблон, $2 — куда положить заготовку
  cp "$1" "$2"
  sed -i '' "s/data-duration=\"60\"/data-duration=\"${DUR_R}\"/g" "$2"
}
[ "$THEME" = light ] || make_draft templates/new-video.html       "$SLOT/composition.html"
[ "$THEME" = dark  ] || make_draft templates/new-video-light.html "$SLOT/composition-light.html"

# ── 4. исходник — из inbox в _done, чтобы очередь не взяла его повторно ───────
mkdir -p inbox/_done
mv -f "$FILE" "inbox/_done/$(basename "$FILE")"

cat > "$SLOT/meta.txt" <<EOF
источник:     $(basename "$FILE")
тема:         $THEME
длительность: ${DUR}s
громкость:    ${NEW_I} LUFS
заведён:      $(date '+%Y-%m-%d %H:%M')
EOF

echo ""
echo "✓ Слот готов: $SLOT"
echo "  • transcript.json — прочитать целиком, построить storyboard"
[ "$THEME" = light ] || echo "  • composition.html — тёмная вёрстка (data-duration ${DUR_R}s)"
[ "$THEME" = dark  ] || echo "  • composition-light.html — светлая вёрстка (data-duration ${DUR_R}s)"
echo "  • captions.js — вычитать ошибки Whisper, вставить CAP"
echo "  • рендер: scripts/queue-render.sh ${NN}"
