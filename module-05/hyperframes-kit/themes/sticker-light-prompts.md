# Sticker Light — промпт-пак для Nano Banana Pro (2026-07-30)

Генерация банка поз персонажа и стартовых стикеров. Делает автор руками
в Nano Banana Pro, файлы складывает в `assets/character/` и `assets/stickers/`
с именами из таблиц. Дальше фон срезается скиллом hyperframes-media
(remove-background), масштаб выравнивается при первой вёрстке.

## Порядок (важно для консистентности)

1. **Шаг 1 — референс-лист персонажа.** Загрузи 2–3 своих фото (анфас +
   полуоборот, хорошо видно лицо) → промпт «Character sheet» ниже.
   Перегенерируй, пока не понравится сходство. Этот лист — эталон.
2. **Шаг 2 — позы.** Для КАЖДОЙ позы: прикрепи референс-лист (и одно фото)
   → базовый промпт позы. Одежда, причёска, свет — не менять между позами.
3. **Проверка партии:** все 11 поз рядом — один человек, один масштаб головы,
   один свет. Выбившиеся — перегенерировать, не «дотянем в CSS».
4. Стикеры — отдельно, референс-лист не нужен (кроме stiker-coder с персонажем).

---

## Шаг 1. Character sheet

> Create a character reference sheet of this man as a high-quality anime-style
> illustration (clean modern anime, soft cel shading, detailed hair, natural
> proportions — NOT chibi). Keep a strong likeness to the photos: face shape,
> beard, hairstyle. Outfit: dark charcoal t-shirt under a light beige overshirt,
> casual. Sheet layout: front view and 3/4 view, waist-up, neutral friendly
> expression, arms relaxed. Soft even studio lighting, plain white background,
> no text, no watermarks.

Одежду можно заменить на свою обычную — но зафиксировать один комплект
для всего банка.

## Шаг 2. Позы (11 файлов → assets/character/)

Базовый промпт (общий для всех поз):

> Using the attached character sheet as strict reference, generate the SAME
> character, identical face, hairstyle, outfit and art style (clean modern
> anime, soft cel shading). Waist-up, facing the viewer straight-on, same
> head size and framing as the sheet. Soft even lighting, plain solid white
> background, no text. Pose: {POSE}. Expression: {FACE}.

| Файл | {POSE} | {FACE} |
|---|---|---|
| `pose-base.png` | arms relaxed, one hand slightly raised mid-gesture as if talking | calm, friendly, mouth slightly open as if speaking |
| `pose-wave.png` | right hand raised waving hello, other arm relaxed | warm smile |
| `pose-five.png` | open palm raised beside shoulder, fingers spread | confident smile |
| `pose-fists.png` | both fists clenched at chest level in excited "yes!" gesture | excited, wide happy smile, eyes bright |
| `pose-think-chin.png` | one hand on chin, thinking, other arm across body | curious, slightly raised eyebrow, looking at viewer |
| `pose-think-cross.png` | arms crossed, one hand touching chin | skeptical, doubting frown |
| `pose-stop.png` | one palm pushed out to the side in a firm "stop" gesture, body slightly turned | serious, disapproving, slight frown |
| `pose-present-left.png` | open palm presenting upward toward upper-left, like showing a product | friendly, explaining, mouth open as if speaking |
| `pose-present-right.png` | open palm presenting upward toward upper-right, like showing a product | friendly, explaining, mouth open as if speaking |
| `pose-shrug.png` | both hands open at sides in a light shrug | wry half-smile, "what can you do" |
| `pose-welcome.png` | both arms open wide toward the viewer, welcoming | big warm smile |

## Стикеры (стартовый банк → assets/stickers/)

> **Что показала практика 2026-08-03 (6 новых стикеров):**
> - Генератор **часто игнорирует белую окантовку**, хотя промпт её просит: у
>   `price-tag`, `handshake`, `mirror`, `hero-cape`, `heart` её в исходнике не было
>   (проверено по пикселям — обработка тут ни при чём). Часть банка со «стикерной»
>   каймой, часть без. Если кайма принципиальна — просить её отдельным
>   предложением в конце промпта и проверять глазами до обработки.
> - Фон приходит **серым с ореолом**, а не белым. Для обработки это нормально:
>   `scripts/sticker-prep.py` определяет фон по краям.
> - **Для светлых объектов** (лист бумаги, облако, снег, полароид) в промпте
>   менять фон на `plain solid mid-gray canvas`: на белом фоне белый объект
>   неотделим, и заливка съедает его собственную светлую кайму.

Базовый промпт стикера:

> Die-cut sticker illustration of {OBJECT}, bold vibrant cartoon style with
> clean outlines and soft cel shading, thick white sticker border around the
> silhouette, no drop shadow, no background (plain solid white canvas),
> no text, high detail, centered.

| Файл | {OBJECT} |
|---|---|
| `terminal.png` | a dark computer terminal window with green command line text symbols |
| `robot.png` | a cute friendly white-and-blue robot assistant holding a wrench |
| `brain.png` | a pink brain with a yellow lightning bolt |
| `rocket-phone.png` | a smartphone with a growth chart on screen and a rocket launching behind it |
| `coins.png` | a stack of shiny gold coins on banknotes |
| `camera.png` | a professional video camera on a tripod |
| `mic.png` | a studio condenser microphone in a shock mount |
| `factory.png` | a whimsical blue content factory machine with funnel, gears and small screens on a conveyor |
| `bulb.png` | a glowing yellow lightbulb with a green checkmark |
| `hourglass.png` | a blue hourglass with sand falling |
| `coder.png` | *(с референс-листом персонажа)* the attached character sitting cross-legged with a laptop, coding, hoodie version |
| `error.png` | a red warning sign with a bold white cross, cracked around the edges |
| `magnet.png` | a big red horseshoe magnet attracting small user avatar figures |
| `fire.png` | a bright orange-and-yellow flame with sparks |
| `book.png` | an open book with a lightbulb rising from the pages |

### Волна 2 (по разбору 10 рилсов референс-автора, 2026-07-30)

| Файл | {OBJECT} |
|---|---|
| `wallet-moths.png` | a worn brown leather wallet riddled with holes, with a cartoon moth flying out of it and one gold coin falling through a hole |
| `mentor-elder.png` | a wise old bearded mentor character in a dark turtleneck sweater and round glasses, giving a thumbs-up |
| `notepad-checklist.png` | a green spiral-bound notepad with a checked checklist and a pencil tucked into the spiral |
| `scroll-questions.png` | an unrolled ancient parchment scroll covered in tiny illegible text with large question marks floating above it |
| `robot-subagents.png` | three small orange robot characters each holding a wrench, standing side by side like a little team |
| `friend-group.png` | three diverse cartoon friends of different skin tones sitting together with laptops, smiling and cheering |
| `golden-scale.png` | a golden justice balance scale perfectly level |
| `magic-wand.png` | a golden magic wand with a star tip, surrounded by small sparkles |
| `treasure-map.png` | an old folded treasure map with a dotted path and an X mark, with a magnifying glass hovering over it |
| `keyword-bubble.png` | a glowing blue speech bubble with sparkles and a golden key floating inside it |

Новые стикеры под конкретные ролики — тем же базовым промптом, файл в
`assets/stickers/`, имя по смыслу. Бренд-логотипы стикерами НЕ генерить —
для брендов есть `assets/icons/` (manifest.json).

## После генерации

```bash
# срезать фон у всех поз и стикеров (скилл hyperframes-media)
# → PNG с прозрачностью поверх исходников
```

Затем сказать Клоду «позы в assets/character/, собери тестовый ролик» —
дальше всё по `themes/sticker-light-reference.md`.
