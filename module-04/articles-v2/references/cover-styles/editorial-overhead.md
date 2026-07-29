# Cover Style Pack: editorial-overhead

Журнальный flat-lay сверху. Ровный мягкий свет, продуманная композиция объектов, чувствуется рука редактора. Подходит для разборов, сравнений и структурных тем, когда важна аналитичность и «взгляд сверху на ситуацию».

## Когда выбирать (по умолчанию)

- Сравнения инструментов («n8n vs Make», «Claude vs ChatGPT»)
- Разборы и обзоры одного инструмента
- Списки и нумерованные подборки («5 ошибок», «3 типа», «6 видов»)
- Структурный анализ, классификации
- Темы со ставкой на «системность, объективность, разложение по полочкам»

## Подстановки в шаблон промпта

### Строка света (`soft even daylight from above ...`)

Варианты для ротации:
- `soft even diffuse daylight from above, no harsh shadows`
- `bright overcast daylight from a large window above, soft fall-off`
- `gentle skylight from above the surface, even illumination across the frame`
- `soft top-down daylight, minimal shadow direction`

### Строка палитры

База: `editorial neutral palette with one [color] accent on [object]`

Доступные акценты: **red** (риск), **muted teal/sage** (решение, рост), **amber** (внимание). В этом паке акценты немного приглушённее, чем в warm-apartment.

### Строки контекста / сцены (top-down всегда)

Поверхности для ротации:
- a clean wooden tabletop shot from directly above
- a linen-covered surface, top-down composition
- a pale stone or concrete tabletop, overhead view
- a textured cream paper background, flat-lay composition
- a matte ceramic tile surface from above
- a darker walnut wooden desk from directly above

В этом паке **все 5 промптов делаются top-down** (вид сверху), даже если формула изначально подразумевает фронтальный кадр. Лицо тогда переводится в close-up рук/предметов сверху, либо в портрет, снятый над плечом сверху-вниз.

## Анти-AI хвост (вставлять целиком в каждый промпт)

> **Исключение для контент-поверхности.** Если на обложке есть лист / экран / телефон с текстом структуры статьи (правило «Текст на поверхности» в `cover-formulas.md`) — в хвосте этого промпта **убери токен `no text,`** (остальное оставь; `no captions, no watermarks, no logos` продолжают запрещать плашки-подписи поверх кадра). Для обложек без текста на поверхности хвост без изменений.

Для промптов с человеком (только руки/частично лицо сверху):

```
Photorealistic, editorial flat-lay composition, top-down overhead view, natural skin texture and materials, considered arrangement, clean uncluttered surface, one main subject occupying 50-70% of frame, soft even diffuse daylight, editorial neutral palette (cream, soft gray, graphite, muted teal-sage), one accent color only, authentic adult 40-50 hands or partial figure if present, natural understated mood, no text, no captions, no watermarks, no logos, no robots, no holograms, no neon, no cyberpunk, no futuristic interfaces, no server rooms, no glossy 3D, no stock illustration look, no overloaded interfaces, no startup glam, no posed studio smile, no helpless-elderly stereotype
```

Для промптов без человека:

```
Photorealistic, editorial flat-lay composition, top-down overhead view, natural materials and textures, considered arrangement, clean uncluttered surface, one main subject occupying 50-70% of frame, soft even diffuse daylight, editorial neutral palette (cream, soft gray, graphite, muted teal-sage), one accent color only, no text, no captions, no watermarks, no logos, no people, no faces, no hands, no robots, no holograms, no neon, no cyberpunk, no futuristic interfaces, no server rooms, no glossy 3D, no stock illustration look, no overloaded interfaces, no startup glam
```

## Mood words для main subject phrase

Используй естественно: editorial, considered, arranged, structured, balanced, deliberate, magazine-style, overhead, top-down.

## Адаптация 5 типов под top-down

Чтобы 5 фиксированных типов работали в этом паке:

- **Тип 1 (человек)** — снимай сверху над плечом, лицо частично в кадре сверху-вниз, либо руки героя + лицо в расфокусе
- **Тип 2 (телефон в руке)** — естественно top-down, руки держат телефон над столом, экран читается сверху
- **Тип 3 (лист в руках)** — лист лежит на столе или в руках, top-down, текст читается сверху
- **Тип 4 (ноутбук)** — экран снят сверху-сбоку под наклоном, либо макро экрана сверху
- **Тип 5 (символ)** — лежит на чистой поверхности, top-down макро

## Пример полного промпта (Тип 2 — телефон в руке, контент на экране)

```
Type2-Phone-in-hand editorial cover:
top-down overhead view of adult hands aged 44-50 holding a smartphone over a clean walnut wooden desk,
the screen showing a single large green toggle switch in the on position, everything else on screen clean,
a closed notebook and a fountain pen arranged deliberately beside the hands,
soft even diffuse daylight from above, no harsh shadows,
editorial neutral palette with one muted sage-green accent on the toggle.

Photorealistic, editorial flat-lay composition, top-down overhead view, natural skin texture and materials, considered arrangement, clean uncluttered surface, one main subject occupying 50-70% of frame, soft even diffuse daylight, editorial neutral palette (cream, soft gray, graphite, muted teal-sage), one accent color only, authentic adult 40-50 hands or partial figure if present, natural understated mood, no text, no captions, no watermarks, no logos, no robots, no holograms, no neon, no cyberpunk, no futuristic interfaces, no server rooms, no glossy 3D, no stock illustration look, no overloaded interfaces, no startup glam, no posed studio smile, no helpless-elderly stereotype
```
