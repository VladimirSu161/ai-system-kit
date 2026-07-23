# Cover Style Pack: cinematic-evening

Тёплое вечернее освещение, одиночный источник света (лампа, окно на закате), мягкие тени, кинематографичная тишина. Подходит для прогнозов, личных кейсов и тем «вдумчивости», когда нужно создать ощущение паузы и размышления.

## Когда выбирать (по умолчанию)

- Тренды и прогнозы («куда движется X», «что будет в 2027»)
- Личные кейсы автора («как я переехал на X», «полгода с Y»)
- Карьера, доход, переходы в новую профессию
- Итоги, ретроспективы, «год с инструментом»
- Opinion-форматы, рефлексии
- Темы со ставкой на «вдумчивость, выбор, тихий момент решения»

## Подстановки в шаблон промпта

### Строка света (`warm single-source evening light ...`)

Варианты для ротации:
- `warm single-source desk lamp light from the left, soft fall-off into shadow`
- `golden hour daylight from a low window, soft warm fall-off`
- `single warm table lamp glow as the only light source, gentle shadow`
- `late afternoon golden window light, warm directional fall-off`
- `evening reading-lamp light from above, soft pool of warmth`

Принципиально: **один источник**, **тёплый**, **с мягким падением в тень**. Никогда не «полностью ровный» свет — должна быть направленность.

### Строка палитры

База: `cinematic warm palette with one [color] accent on [object]`

Доступные акценты: **deep amber** (внимание/тепло), **muted bronze** (предмет/символ), **soft cream** (свет/подсветка), **deep red** (если риск, но приглушённо).

Этот пак темнее остальных. Тени допускаются глубже, общая экспозиция ниже на 1-1.5 стопа, но всё ещё легко читается в thumbnail.

### Строки контекста / сцены

Сцены для ротации:
- evening home office with a desk lamp on
- living room sofa side table at dusk
- kitchen counter at golden hour with low window light
- bedroom nightstand with a warm reading lamp
- a quiet cafe table near a window at sunset
- a study desk lit by a single warm pendant lamp
- a windowsill at golden hour, warm side light

## Анти-AI хвост (вставлять целиком в каждый промпт)

> **Исключение для контент-поверхности.** Если на обложке есть лист / экран / телефон с текстом структуры статьи (правило «Текст на поверхности» в `cover-formulas.md`) — в хвосте этого промпта **убери токен `no text,`** (остальное оставь; `no captions, no watermarks, no logos` продолжают запрещать плашки-подписи поверх кадра). Для обложек без текста на поверхности хвост без изменений.

Для промптов с человеком:

```
Photorealistic, cinematic film-still feel, natural skin texture and materials, ordinary apartment or home office context, single warm light source with soft directional fall-off, deeper graphite shadows acceptable, clean uncluttered background, one main subject occupying 50-70% of frame, cinematic warm palette (deep graphite, soft cream, warm amber, muted bronze), one accent color only, authentic adult 40-50, natural contemplative expression, no text, no captions, no watermarks, no logos, no robots, no holograms, no neon, no cyberpunk, no futuristic interfaces, no server rooms, no glossy 3D, no stock illustration look, no overloaded interfaces, no startup glam, no posed studio smile, no helpless-elderly stereotype, no horror lighting, no harsh contrast
```

Для промптов без человека:

```
Photorealistic, cinematic film-still feel, natural materials and textures, ordinary apartment or home office context, single warm light source with soft directional fall-off, deeper graphite shadows acceptable, clean uncluttered background, one main subject occupying 50-70% of frame, cinematic warm palette (deep graphite, soft cream, warm amber, muted bronze), one accent color only, no text, no captions, no watermarks, no logos, no people, no faces, no hands, no robots, no holograms, no neon, no cyberpunk, no futuristic interfaces, no server rooms, no glossy 3D, no stock illustration look, no overloaded interfaces, no startup glam, no horror lighting, no harsh contrast
```

## Mood words для main subject phrase

Используй естественно: contemplative, quiet, evening, considered, paused, thoughtful, intimate, unhurried, late-hour, reflective.

## Важно: не уйти в moody-перебор

Этот пак — **не horror и не noir**. Это уютный вечер, не тревожный полумрак. Главные ограничители:
- Свет тёплый (amber/cream), никогда не синий и не зелёный
- Тени мягкие, не контрастные
- Лицо человека хорошо освещено с одной стороны, противоположная сторона мягко угасает
- Никаких силуэтов, никакого «лица из тени»

Если кадр читается как «триллер на Netflix» — это слишком далеко, нужно вернуть теплоты и поднять экспозицию.

## Пример полного промпта (Тип 5 — символ на чистом фоне, «стрелка вверх»)

```
Type5-Symbol cinematic cover:
a single matte bronze upward-pointing arrow as a sculptural physical object on a dark walnut desk surface,
positioned beside a closed leather notebook and a warm brass desk lamp turned on at the edge of frame,
single warm table lamp glow as the only light source, gentle shadow falling to the right,
cinematic warm palette with one deep amber accent on the arrow tip catching the lamplight.

Photorealistic, cinematic film-still feel, natural materials and textures, ordinary apartment or home office context, single warm light source with soft directional fall-off, deeper graphite shadows acceptable, clean uncluttered background, one main subject occupying 50-70% of frame, cinematic warm palette (deep graphite, soft cream, warm amber, muted bronze), one accent color only, no text, no captions, no watermarks, no logos, no people, no faces, no hands, no robots, no holograms, no neon, no cyberpunk, no futuristic interfaces, no server rooms, no glossy 3D, no stock illustration look, no overloaded interfaces, no startup glam, no horror lighting, no harsh contrast
```
