#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════
# Генератор ambient-подложки для роликов (assets/audio/ambient-soft.mp3).
#
# ЗАЧЕМ СВОЙ, А НЕ СКАЧАННЫЙ ТРЕК: ролики уходят в Instagram, где чужая
# музыка ловится Content ID — звук глушат или ролик ограничивают. Этот пад
# синтезируется локально из ffmpeg-осцилляторов, правообладателей нет.
#
# Запуск из корня проекта:  scripts/make-ambient.sh [длительность_сек]
# По умолчанию 44с (хватает на ролик до ~40с).
#
# Результат: assets/audio/ambient-soft.mp3, нормализован до -30 LUFS.
# В композиции ставить с data-volume="0.3" → ≈-42 dB в миксе (~25 dB под речью).
# ══════════════════════════════════════════════════════════════
set -euo pipefail
cd "$(dirname "$0")/.."
eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || true

DUR="${1:-44}"
OUT="assets/audio/ambient-soft.mp3"
TMP="$(mktemp -t ambient).mp3"

FADE_OUT=$(echo "$DUR - 5" | bc)

echo "→ Синтез пада, ${DUR}с…"
# Состав: низкий гул (A2) + квинта/октава для теплоты + очень тихая верхняя нота
# + отфильтрованный розовый шум («воздух»). Медленный tremolo на каждом слое
# даёт «дыхание», aecho — ощущение пространства.
ffmpeg -y -hide_banner -loglevel error \
 -f lavfi -i "sine=f=110:d=${DUR}:sample_rate=48000" \
 -f lavfi -i "sine=f=164.81:d=${DUR}:sample_rate=48000" \
 -f lavfi -i "sine=f=220:d=${DUR}:sample_rate=48000" \
 -f lavfi -i "sine=f=329.63:d=${DUR}:sample_rate=48000" \
 -f lavfi -i "anoisesrc=d=${DUR}:c=pink:a=0.35:r=48000" \
 -filter_complex "\
[0]volume=0.42,tremolo=f=0.12:d=0.25[a1];\
[1]volume=0.22,tremolo=f=0.10:d=0.30[a2];\
[2]volume=0.13,tremolo=f=0.16:d=0.25[a3];\
[3]volume=0.05,tremolo=f=0.10:d=0.35[a4];\
[4]volume=0.30,highpass=f=400,lowpass=f=2600,tremolo=f=0.14:d=0.4[a5];\
[a1][a2][a3][a4][a5]amix=inputs=5:normalize=0[m];\
[m]highpass=f=70,lowpass=f=1900,aecho=0.8:0.85:220|380:0.22|0.15,\
afade=t=in:st=0:d=3.5,afade=t=out:st=${FADE_OUT}:d=5[o]" \
 -map "[o]" -ac 2 -ar 48000 -b:a 192k "$TMP"

echo "→ Нормализация до -30 LUFS…"
ffmpeg -y -hide_banner -loglevel error -i "$TMP" \
  -af loudnorm=I=-30:TP=-6:LRA=7 -ac 2 -ar 48000 -b:a 192k "$OUT"
rm -f "$TMP"

echo "✓ $OUT"
ffmpeg -hide_banner -i "$OUT" -af ebur128=framelog=quiet -f null - 2>&1 | grep -E "I:|LRA:"
