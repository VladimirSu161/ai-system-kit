# HyperFrames Composition Project

> **Единственный источник правды — `CLAUDE.md` в этой папке.**
> Этот файл — только указатель для агентов, которые не читают CLAUDE.md
> автоматически (Codex, Cursor, Amp, Cline и др.). Прочитай `CLAUDE.md`
> ЦЕЛИКОМ перед любой работой — там весь операционный порядок.
> Правила здесь НЕ дублируются, чтобы не расходиться.

## Куда смотреть

| Что нужно | Где |
|---|---|
| Весь workflow (inbox → транскрипт → storyboard → вёрстка → рендер → чистка) | `CLAUDE.md` |
| Тёмная тема: паттерны A–N, словарь движения, компоновка | `themes/dark-amber-reference.md` |
| Светлая тема: зоны кадра, банк поз, паттерны P1–P11 | `themes/sticker-light-reference.md` |
| Генерация своего персонажа и стикеров (промпты) | `themes/sticker-light-prompts.md` |
| CSS тем (подключать, НЕ копировать) | `shared/dark-amber.css`, `shared/sticker-light.css` |
| JS-хелперы: entrance, counters, переходы, караоке (подключать, НЕ копировать) | `shared/helpers.js` |
| Шаблоны нового видео | `templates/new-video.html`, `templates/new-video-light.html` |
| Подготовка нового видео (звук + слот очереди) | `./prep.sh` затем `scripts/queue-add.sh` |
| Превью-гейт перед рендером | `scripts/queue-preview.sh` |
| Рендер слота | `scripts/queue-render.sh` |
| QA-кадры чернового рендера | `scripts/qa-frames.sh` |
| Генератор караоке-субтитров из транскрипта | `scripts/captions-from-transcript.mjs` |
| Эталон плотности сцен и переходов | `past-videos/_reference-video64.html` (⚠ SFX-раскладка там старая) |
| Правила движка HyperFrames (data-атрибуты, timeline contract) | `CLAUDE.md` → Key Rules + `.agents/skills/hyperframes/SKILL.md` |

## Контекст проекта (кратко)

Вертикальные ролики 1080×1920, 30 fps, 50–90 сек, по-русски. Пайплайн:
автор кладёт запись голоса (или смонтированное видео) в `inbox/` → агент
делает motion-ролик с инфографикой в двух темах (автономно, один гейт —
превью) → готовые файлы уезжают в `~/Desktop/Ролики HyperFrames/`.
В тёмной теме зона аватара (`x<540 & y>1248`) всегда пустая — туда автор
накладывает говорящую голову при монтаже; в светлой теме вместо живого
аватара рисованный персонаж, и монтаж не нужен.

## История и версии

Проект под git. Ручные файлы-копии (`_backup`) не делать — коммитить.
Версия hyperframes зафиксирована в `package.json` (0.7.26), причина пина —
в `CLAUDE.md` → Commands.
