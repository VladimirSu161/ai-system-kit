#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════
# Проверка звука готового рендера: попадаем ли в норму соцсетей и
# не перебивают ли эффекты речь.
#
# Запуск:  scripts/audio-check.sh renders/video-NN-final.mp4 [старт_чистого_SFX]
#
# ЧТО ДОЛЖНО ПОЛУЧИТЬСЯ (норма с 2026-08-02):
#   • Integrated  ≈ -14 LUFS  (цель Instagram; ±0.5 — ок)
#   • True peak   ≤ -1 dBFS
#   • max SFX на ~10–12 dB НИЖЕ mean речи
#
# Второй аргумент — момент, где свуш звучит БЕЗ речи (обычно переход на CTA).
# Без него скрипт меряет только общий уровень: SFX в окне с речью замерить
# нельзя — измеришь голос.
# ══════════════════════════════════════════════════════════════
set -euo pipefail
cd "$(dirname "$0")/.."
eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || true

MP4="${1:?Укажи файл: scripts/audio-check.sh renders/video-NN-final.mp4 [старт_SFX]}"
SFX_AT="${2:-}"

echo "── Мастер-уровень: $MP4 ──"
ffmpeg -hide_banner -i "$MP4" -af ebur128=peak=true:framelog=quiet -f null - 2>&1 \
  | grep -E "I:|LRA:|Peak:"

echo ""
echo "── Речь (окно 5.0–8.0с) ──"
ffmpeg -hide_banner -ss 5.0 -t 3.0 -i "$MP4" -af volumedetect -f null - 2>&1 \
  | grep -E "max_volume|mean_volume"

if [ -n "$SFX_AT" ]; then
  echo ""
  echo "── Чистый SFX (окно ${SFX_AT}с, +0.55с) ──"
  ffmpeg -hide_banner -ss "$SFX_AT" -t 0.55 -i "$MP4" -af volumedetect -f null - 2>&1 \
    | grep -E "max_volume|mean_volume"
  echo ""
  echo "Сверка: max SFX должен быть на ~10–12 dB ниже mean речи."
else
  echo ""
  echo "(Передай вторым аргументом момент свуша без речи — обычно переход на CTA —"
  echo " чтобы сверить баланс эффектов.)"
fi
