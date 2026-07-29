# Cover Style Pack: warm-apartment

Текущий базовый стиль канала. Тёплый дневной свет в обычной квартире/кухне/кафе. Подходит для большинства объяснялок и бытовых тем, когда нужно показать AI как обычный домашний предмет.

## Когда выбирать (по умолчанию)

- Объяснялки «что такое X простыми словами»
- Гайды и пошаговые туториалы для новичка
- Smart home, голосовые ассистенты, бытовое использование AI
- Базовые инструменты для повседневной работы
- Темы со ставкой на «спокойствие, понятность, доступность»

## Подстановки в шаблон промпта

### Строка света (`soft natural daylight from ...`)

Варианты для ротации между 5 промптами в одном выпуске:
- `soft natural daylight from a side window`
- `soft morning daylight from a kitchen window`
- `warm afternoon daylight from the left`
- `gentle diffuse daylight from a side window`

### Строка палитры (`warm neutral palette with one [color] accent ...`)

База: `warm neutral palette with one [red/green/amber] accent on [object]`

Доступные акценты в этом паке: **red** (риск), **green** (решение/готово), **amber** (внимание).

### Строки контекста (для main subject phrase)

Сцены для ротации (используй разные между 5 промптами):
- ordinary apartment kitchen
- home office desk
- living room sofa side table
- windowsill with a plant
- wooden shelf with books
- cafe with wooden tables
- bedroom nightstand
- small dining area with linen tablecloth

## Анти-AI хвост (вставлять целиком в каждый промпт)

> **Исключение для контент-поверхности.** Если на обложке есть лист / экран / телефон с текстом структуры статьи (правило «Текст на поверхности» в `cover-formulas.md`) — в хвосте этого промпта **убери токен `no text,`** (остальное оставь; `no captions, no watermarks, no logos` продолжают запрещать плашки-подписи поверх кадра). Для обложек без текста на поверхности хвост без изменений.

Для промптов с человеком (типы 1-4: человек, телефон, лист, ноутбук):

```
Photorealistic, documentary feel, natural skin texture and materials, ordinary apartment or home office context, clean uncluttered background, one main subject occupying 50-70% of frame, soft natural daylight, warm neutral palette (beige, soft gray, graphite, muted olive), one accent color only, authentic adult 40-50, natural understated expression, no text, no captions, no watermarks, no logos, no robots, no holograms, no neon, no cyberpunk, no futuristic interfaces, no server rooms, no glossy 3D, no stock illustration look, no overloaded interfaces, no startup glam, no posed studio smile, no helpless-elderly stereotype
```

Для промптов без человека (тип 5 — символ):

```
Photorealistic, documentary feel, natural materials and textures, ordinary apartment or home office context, clean uncluttered background, one main subject occupying 50-70% of frame, soft natural daylight, warm neutral palette (beige, soft gray, graphite, muted olive), one accent color only, no text, no captions, no watermarks, no logos, no people, no faces, no hands, no robots, no holograms, no neon, no cyberpunk, no futuristic interfaces, no server rooms, no glossy 3D, no stock illustration look, no overloaded interfaces, no startup glam
```

## Mood words для main subject phrase

Используй естественно, не списком: calm, quiet, ordinary, everyday, soft, attentive, unhurried.

## Пример полного промпта (Тип 1 — человек, лицо + облегчение)

```
Type1-Person-relief cover:
a 50-year-old man at a normal home-office desk looking at his open laptop with a calm expression of relief,
beside the laptop a paper notebook with a short checklist, all items crossed out with a green pencil,
a coffee mug and a small plant in soft focus,
warm afternoon daylight from the left,
warm neutral palette with one muted green accent on the crossed-off lines.

Photorealistic, documentary feel, natural skin texture and materials, ordinary apartment or home office context, clean uncluttered background, one main subject occupying 50-70% of frame, soft natural daylight, warm neutral palette (beige, soft gray, graphite, muted olive), one accent color only, authentic adult 40-50, natural understated expression, no text, no captions, no watermarks, no logos, no robots, no holograms, no neon, no cyberpunk, no futuristic interfaces, no server rooms, no glossy 3D, no stock illustration look, no overloaded interfaces, no startup glam, no posed studio smile, no helpless-elderly stereotype
```
