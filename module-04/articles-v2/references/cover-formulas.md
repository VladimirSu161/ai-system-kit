# Cover Formulas — промпты для обложек статьи Дзена

Используется в Phase 6 скилла `articles-v2`. Цель — сгенерировать комплект обложек для nano-banana-pro под одну статью: **4 фотореалистичных промпта по слотам** (человек / носитель контента ×2 / символ) + **2 дудл-обложки** (рисунок от руки в стиле YouTube-превью: одна без текста, одна с текстом). У автора получается готовый набор, из которого он выбирает. Картинки в тело статьи НЕ генерируются (убраны по решению пользователя 2026-07-02).

**Pole Star комплекта — CTR в ленте Дзена.** Обложка соревнуется в маленькой миниатюре на белом фоне ленты. Побеждает: мгновенная считываемость + эмоция/крючок + непохожесть на предыдущие обложки канала. Поэтому в системе два механизма: светлый единый свет (читаемость) и композиционная ротация (непохожесть).

---

## Главный принцип

**Не рисуем «AI как индустрию» (роботы, неон, мозг из линий). Рисуем момент, в котором человек сталкивается с последствием или пользой.** Дзен — широкая лента, аудитория сдвинута в 45-60, побеждает мгновенная понятность и бытовая релевантность, а не визуальная сложность.

**Второй главный принцип — зависимость от КОНКРЕТНОЙ статьи.** Действие героя, его эмоция, окружение, текст и иконки на носителе, сам символ — всё берётся из содержания **именно этой статьи**. Картинка должна **иллюстрировать** тему и **интриговать**: показать момент, но недоговорить механизм.

**Третий главный принцип — композиции ротируются между выпусками.** Раньше композиция каждого типа была зафиксирована («человек сидит за столом», «руки держат лист»), и обложки от статьи к статье выходили почти одинаковыми — это баннерная слепота и падение CTR. Теперь у каждого слота есть меню композиций; выбранные варианты записываются в блок вывода и **не повторяются с 2 предыдущими выпусками** (см. «Запрет повторов»).

**Два визуальных трека.** Фотореалистичные слоты — документальная съёмка, единый светлый дневной стандарт. Дудл-обложки — отдельный трек: рисунок от руки на кремовой бумаге, своя стилистика.

---

## Единый световой стандарт (для всех фото-слотов)

Паки стилей отключены от автоматики: тёмный вечерний свет плохо читается в миниатюре ленты и режет CTR. Все фото-промпты используют **светлый дневной стандарт** (бывший warm-apartment). Файлы в `cover-styles/` остаются и подключаются ТОЛЬКО если пользователь явно попросил («сделай в evening»).

**Строки света** (ротируй между промптами одного выпуска):
- `soft natural daylight from a side window`
- `soft morning daylight from a kitchen window`
- `warm afternoon daylight from the left`
- `gentle diffuse daylight from a side window`

**Палитра:** `warm neutral palette (beige, soft gray, graphite, muted olive) with one [red/green/amber] accent on [object]`
Акценты по смыслу: **красный = риск**, **зелёный = решение/готово**, **янтарный = внимание**.

---

## Принципы стиля канала (фото-слоты)

| Параметр | Правило |
|---|---|
| Реализм | Photorealistic / documentary feel, natural skin texture, ordinary apartment |
| Композиция | Один главный объект 50–70% кадра, воздух, чистый, но жизненный фон |
| Персонажи | Обычные взрослые **35-55**, ухоженные, **не глянцевые стартаперы**, **не «пенсионеры в панике»**, не «беспомощные перед техникой» |
| Эмоция | 4-6 из 10 (тревога / удивление / облегчение / интерес / задумчивость), **под ставку статьи**. НЕ «театральный шок», НЕ «стоковая улыбка» |
| Контекст | Бытовой: кухня, домашний кабинет, диван, кафе, магазин, аэропорт — **под тему статьи** |
| Текст на обложке | НЕТ подписей-плашек поверх кадра — заголовок Дзена делает текстовую работу. **Но** текст/иконки внутри сцены на реальной поверхности — обязательны для слотов-носителей, см. «Контент на поверхности» |
| Сложность | Если в кадре больше 2 смысловых элементов — упростить. Иконки — максимум 4 (см. «Иконки смысла») |

---

## Иконки смысла (разрешены, дозированно)

Крупные плоские иконки — рабочий CTR-приём в ленте Дзена (визуализируют невидимое: данные, сервисы, потоки). Правила:

- **Стиль:** flat rounded app-style icons, матовые цвета, мягкие реалистичные тени. БЕЗ свечения, неона, полупрозрачности, HUD-эффектов.
- **Где можно:** (а) крупно на экране носителя (телефон/ноутбук — как реальный интерфейс, упрощённый и крупный); (б) 2-4 иконки, аккуратно парящие рядом с носителем (gently floating beside the phone, soft shadows).
- **Сколько:** максимум 4. Гроздья мелких иконок запрещены — перегруз убивает миниатюру.
- **Цвет:** иконки в нейтрально-приглушённой гамме, ОДНА — акцентного цвета по смыслу.
- **Как писать в промпте:** `a few clean flat rounded app-style icons in muted matte colors floating gently beside the phone, one icon in [accent color], soft realistic shadows, no glow`. Анти-хвост оставляй целиком — он банит свечение и перегруз, а не сами иконки.

---

## Hard ban (никогда в фото-промптах, всегда в negative)

- Cyberpunk, neon blue/purple wash, sci-fi lighting
- AI robots, humanoid figures, mascots
- Светящиеся голограммы, glowing holographic UI (матовые flat-иконки — разрешены, см. выше)
- Brain made of lines/nodes, neural network visualizations
- Server rooms, data centers, code on screens (as decoration)
- Startup glam, crypto-style visuals
- Overloaded dashboards, гроздья мелких иконок, multiple screens with dense UI
- Text captions, watermarks, logos **поверх кадра** (overlay-плашки). Диегетический текст на поверхности внутри сцены — разрешён и обязателен для слотов-носителей
- Stock smile, posed photo, model-like glamour
- Helpless elderly stereotype
- Glossy 3D render, stock-illustration look, vector art

---

## Анти-AI хвост (вставлять целиком в каждый фото-промпт)

> **Исключение для контент-поверхности.** Если на обложке есть лист / экран с текстом или иконками — в хвосте этого промпта **убери токен `no text,`** (остальное оставь). Для обложек без контента на поверхности хвост без изменений.

Для промптов с человеком:

```
Photorealistic, documentary feel, natural skin texture and materials, ordinary apartment or home office context, clean uncluttered background, one main subject occupying 50-70% of frame, soft natural daylight, warm neutral palette (beige, soft gray, graphite, muted olive), one accent color only, authentic ordinary adult, natural understated expression, no text, no captions, no watermarks, no logos, no robots, no glowing holograms, no neon, no cyberpunk, no sci-fi interfaces, no server rooms, no glossy 3D, no stock illustration look, no overloaded interfaces, no startup glam, no posed studio smile, no helpless-elderly stereotype
```

Для промптов без человека (символ):

```
Photorealistic, documentary feel, natural materials and textures, ordinary apartment or home office context, clean uncluttered background, one main subject occupying 50-70% of frame, soft natural daylight, warm neutral palette (beige, soft gray, graphite, muted olive), one accent color only, no text, no captions, no watermarks, no logos, no people, no faces, no hands, no robots, no glowing holograms, no neon, no cyberpunk, no sci-fi interfaces, no server rooms, no glossy 3D, no stock illustration look, no overloaded interfaces, no startup glam
```

Дудл-обложки этот хвост **не используют** — у них свой стилевой блок и свой бан, см. раздел «Дудл-обложки».

---

## Ростер героев (ротация лиц)

Раньше было 2 фиксированные карточки — одно и то же лицо на каждой обложке усиливало одинаковость. Теперь ростер из 6; **выбирай под тему и НЕ бери героя из 2 предыдущих выпусков** (см. «Запрет повторов»). Пользователь может переопределить («сделай с женщиной»).

| Код | Карточка (вставлять в промпт целиком) |
|---|---|
| М-44 | `a 44-year-old man, short dark-brown hair with light grey at the temples, light short stubble, ordinary friendly approachable face, medium build, wearing a plain dark-teal crewneck sweater over a light shirt collar; natural adult male hands, clean, no rings` |
| Ж-45 | `a 45-year-old woman, shoulder-length dark-blonde hair loosely tied back, minimal natural makeup, warm ordinary approachable face, slim build, wearing a soft oatmeal-beige knit sweater; natural adult female hands, short neutral manicure, no flashy rings` |
| М-36 | `a 36-year-old man, short dark hair, thin round glasses, clean-shaven, friendly ordinary face, wearing a casual grey zip cardigan over a plain t-shirt; natural adult male hands, no rings` |
| Ж-38 | `a 38-year-old woman, dark shoulder-length wavy hair, minimal makeup, lively ordinary face, wearing a relaxed light-blue denim shirt; natural adult female hands, short neutral manicure` |
| М-52 | `a 52-year-old man, short salt-and-pepper hair, neat short grey beard, calm ordinary face, wearing a soft brown cardigan over a plain shirt; natural adult male hands, simple wedding band` |
| Ж-50 | `a 50-year-old woman, chin-length silver-streaked bob, minimal makeup, kind ordinary face, wearing a muted terracotta blouse; natural adult female hands, short neutral manicure` |

В слотах-носителях, где в кадре только руки — бери строку про руки из карточки выбранного героя.

---

## Слот 1 — Человек (1 промпт, композиция из меню)

Выбери ОДНУ композицию под ставку статьи (и не ту, что в 2 прошлых выпусках):

| # | Композиция | Что в кадре | Когда выбирать |
|---|---|---|---|
| Ч1 | **Реакция крупным планом** | Лицо и плечи героя, читаемая эмоция; объект-виновник частично в кадре (край экрана, угол листа) | Риск, неожиданный факт, «я был в шоке» |
| Ч2 | **Двое** | Герой + второй человек: показывает, подсматривает, консультирует, обсуждают вместе | Темы про других людей, чужие руки/данные, HR, работа, семья |
| Ч3 | **Сцена-локация** | Герой в узнаваемом месте ИЗ СТАТЬИ: кухня, магазин, пункт выдачи, аэропорт, кафе | Статьи с бытовым/сюжетным контекстом |
| Ч4 | **Через плечо** | Камера из-за плеча героя, в фокусе носитель с контентом | Гайды, настройка, «как сделать» |
| Ч5 | **Человек + метафора** | Герой рядом с физическим воплощением смысла (стопка бумаг против одного листа, гора коробок) | Экономия времени, до/после, масштаб рутины |
| Ч6 | **Руки + предмет макро** | Только руки героя и предмет-якорь крупно, лица нет | Когда предмет важнее эмоции |

Правила: эмоция под ставку статьи (риск→настороженность, выгода→облегчение, выбор→задумчивость, навык→сосредоточенный интерес), 4-6/10, без театра. Один акцентный цвет. Интрига: герой реагирует на что-то, что зритель видит не целиком.

---

## Слоты 2-3 — Носитель контента (2 промпта, комбинация двух осей)

Каждый промпт = **носитель × ракурс**. Два промпта выпуска берут **разные носители И разные ракурсы** (и не те, что в 2 прошлых выпусках).

**Ось «носитель» (выбирай под тему):**

| Носитель | Когда органичен |
|---|---|
| Телефон | Мобильные приложения, боты, уведомления, бытовые сценарии |
| Ноутбук | Рабочие инструменты, сервисы, настройка, код-без-кода |
| Лист А4 / блокнот | Списки, планы, чек-листы, «выписал главное» |
| Стикеры на стене/мониторе | Шаги, привычки, напоминания, процессы |
| Распечатка с пометками маркером | Разборы, аудит, «нашёл ошибки» |
| Планшет | Чтение, обучение, курсы |

**Ось «ракурс»:**

| Ракурс | Эффект |
|---|---|
| В руках, к камере | Прямое предъявление контента |
| На столе сверху (flat-lay) | Журнальный порядок, обзорность |
| Палец тапает по экрану | Действие, инструкция, «сделай так» |
| Через плечо героя | Вовлечение, подглядывание |
| Крупный план экрана под углом | Документальность, «реальный скрин» |
| Прислонён/стоит на столе, сцена вокруг | Бытовая жизнь носителя |

**Контент на поверхности обязателен** (см. следующий раздел): русский текст-структура ИЛИ крупные иконки (см. «Иконки смысла») ИЛИ их сочетание. На одном из двух промптов можно использовать парящие иконки рядом с носителем.

---

## Контент на поверхности (лист / экран)

Слоты-носители **всегда несут читаемый контент** на поверхности. Это не нарушение запрета на текст: запрещены **подписи-плашки поверх кадра**, а текст внутри сцены — нативная часть кадра.

**Три режима наполнения — выбери под статью:**

1. **Структурный.** 3-6 коротких русских строк = структура статьи (пункты, шаги, подзаголовки). Последний пункт — с крючком/недоговорённостью («…и тот самый пятый», «4. ?»).
2. **Тизер-фрагмент.** Раскрытый кусок одного блока — короткая интригующая фраза, обрывается на самом интересном. Не пиши «читай дальше» — просто оборви естественно.
3. **Иконочный экран.** Крупные простые иконки на экране носителя (упрощённый интерфейс по теме) + минимум текста. Для тем про приложения и сервисы.

**Общие правила:**
- Язык — **русский**. Кириллицу держим короткой и крупной — длинные фразы модель рисует криво.
- Источник — **реальные формулировки из текста статьи**, ужатые до фрагмента. Не дублирует заголовок Дзена.
- Один элемент подсвечен акцентным цветом (галочка, подчёркивание, пометка) — это и есть «один акцент».
- **Как описать в промпте:** перечисли строки прямо в кавычках: `a paper notebook showing a short handwritten Russian list of 5 short items: «...», «...»`.
- **Правка хвоста:** из анти-AI хвоста этих промптов **убери токен `no text,`**. Остальное оставь.

---

## Слот 4 — Символ (1 промпт, подача × символ)

Символ — минималистичное воплощение центральной идеи статьи одним-двумя физическими предметами. Материал реальный (матовая керамика, стекло, бумага, дерево, металл) — не иконка и не 3D-рендер.

**Ось «подача» (раньше была одна — «предмет на столе», отсюда одинаковость; выбирай не ту, что в 2 прошлых выпусках):**

| # | Подача | Что в кадре |
|---|---|---|
| С1 | Классика | Один предмет на фактурной поверхности (лён, дерево), воздух вокруг |
| С2 | **Контраст-пара** | Два предмета рядом: до/после, дорого/дёшево, старое/новое (толстая стопка ↔ один лист) |
| С3 | **Нарушение ожидания** | Предмет в неожиданном состоянии или месте (ключ, вставленный в книгу; будильник в холодильнике) |
| С4 | **Масштаб** | Крошечное против огромного в одном кадре |
| С5 | **Ряд с выбивающимся** | N одинаковых предметов + 1 другой (он акцентного цвета) |
| С6 | **В руке** | Предмет протянут в кадр на открытой ладони (руки из карточки героя) |
| С7 | **Замерший момент** | Предмет подвешен / в падении / балансирует на грани |
| С8 | **Макро-деталь** | Сверхкрупная фактура значимой части предмета |

**Банк символов по смыслам (выбери 3-4 кандидата под идею статьи, возьми самый специфичный и неочевидный; не бери символ из 2 прошлых выпусков):**

| Смысл статьи | Кандидаты-символы |
|---|---|
| Приватность / слежка | перечёркнутый глаз, микрофон с красной точкой, замок на стопке фотографий, заклеенная веб-камера, замочная скважина с光 светом |
| Экономия времени | песочные часы наполовину, толстая стопка бумаг → тонкая рядом, будильник без стрелок, календарь с вычеркнутыми днями |
| Автоматизация | один тумблер, бумажный самолётик из списка задач, падающее домино, заводной ключ в спине игрушки, конвейерная лента из бумаги |
| Рост дохода / навыки | восходящая стопка монет, ступени из книг, росток в чашке, лестница-стремянка к полке |
| Сравнение / выбор | две чаши весов, два одинаковых предмета разного состояния, развилка из дорожек, три двери разного цвета |
| Риск / обман | рыболовный крючок с бумажной наживкой, треснувший экран, красный конверт, оборванная нить, мышеловка с сыром |
| Скорость / ускорение | бумажный самолётик против бумажного кома, спидометр из бумаги, гепард-оригами |
| Память / база знаний | картотечный ящик, книга с сотней закладок, узелок на платке, полка с одной подсвеченной папкой |
| Обучение / старт с нуля | ластик и первая буква, велосипедные боковые колёсики, пустая тетрадь с одной строкой |
| Замена человека / страх | пустой офисный стул, перчатка, пожимающая перчатку, шахматная пешка против ферзя |
| Контроль / управление | пульт с одной кнопкой, марионеточные нити, вентиль |
| Ошибка / сбой | пролитый кофе на чертёж, спутанный клубок кабелей, кнопка залипшая |
| Цена / бесплатно | ценник с нулём, копилка-свинья, перерезанная банковская карта из бумаги |
| Новое против старого | печатная машинка рядом со смартфоном, свеча и LED-лампа, счёты и калькулятор |
| Зависимость от сервиса | вилка у чужой розетки, ключ на чужом брелоке, зонт, который держит другая рука |
| «Под капотом» / устройство | открытый часовой механизм, разобранная матрёшка, срез слоёного пирога |

Акцентный цвет = смысл (красный риск / зелёный решение / янтарный внимание). В хвосте — `no people, no faces, no hands` (кроме подачи С6 — там руки из карточки).

---

## Дудл-обложки (2 слота)

Помимо 4 фото-слотов, статья получает **2 обложки в дудл-стиле** — рисунок от руки на кремовой бумаге в духе YouTube-превью (стик-фигурки с эмоциями, каракули по теме, жирный короткий заголовок с одним словом-акцентом). Это отдельный визуальный трек: **своя стилистика, не зависит от фото-стандарта**.

### Два слота — зачем именно два

- **Слот «без текста».** Чистая дудл-сцена без надписей. Текстовую работу делает заголовок статьи на Дзене (как и у фотореалистичных типов). Кириллицу модель тут не испортит — рисовать буквы не нужно. Безопасный вариант.
- **Слот «с текстом».** Как ютуб-превью: короткий жирный русский заголовок прямо на картинке, одно слово акцентом. Цепляет сильнее, но буквы рисует нейросеть — поэтому держим **1-3 слова, крупно**. Если кириллица вышла кривой — автор перегенерит (короткий текст ошибается заметно реже).

### Ротация композиций (отсюда вариативность)

Оба слота **тасуются по 5 композициям**. Скилл выбирает их под смысл статьи и следит, чтобы **два слота в одной статье не взяли одну и ту же композицию** (иначе обе обложки на одно лицо). Цель — чтобы от статьи к статье картинки заметно отличались, как на канале-референсе.

| # | Композиция | Что это | Под какие статьи |
|---|---|---|---|
| 1 | **Герой и каракули** | Одна центральная стик-фигура с яркой эмоцией, вокруг — рисованные от руки значки по теме (стрелки, иконки приложений, формулы, восклицательные знаки) | Почти любая тема. Самая гибкая, дефолт при сомнениях |
| 2 | **До / После** | Две стик-фигурки рядом: слева уставшая/грустная, справа довольная; разное состояние одного человека | Сравнения «с ИИ vs без», «было/стало», «до автоматизации и после» |
| 3 | **Триптих (3 этапа)** | Три вертикальные панели на одном листе, в каждой — фигурка на своём этапе. Слева направо = было → процесс → стало, или 3 шага | Гайды, пошаговые разборы, методы из N шагов |
| 4 | **Герой и толпа** | Спокойная фигура в центре, вокруг — мелкие фигурки реагируют (тычут пальцем, шепчутся, удивляются, восхищаются) | Темы про реакцию людей, мнение окружающих, социальный эффект |
| 5 | **Крупный скетч-портрет** | Один крупный чернильный/карандашный портрет лица или силуэта (детальнее стик-фигурки) с сильным акцентом — лампочка над головой, красные глаза, хитрая ухмылка | «Секрет / трюк / разоблачение», один сильный приём, драматичная подача |

**Привязка к статье — как у фото-слотов:** что за герой, какая эмоция, какие каракули вокруг — всё выводится из содержания **этой** статьи, а не из дефолта. Композиция 5 допускает более детальный чернильный рисунок (не обязательно примитивный стик), но всё равно монохромная линия на кремовой бумаге, не фото.

### Текст в слоте «с текстом»

- Русский, **1-3 слова**, крупно, жирным «маркерным» начертанием от руки (как заголовки на рефах).
- **Одно слово — акцентным цветом** по смыслу (красный = риск, зелёный = решение, янтарный = внимание; дефолт для выделенного слова — красный, как на YouTube-рефах).
- Источник — **ставка статьи**, короткий крючок. Не дублирует заголовок Дзена дословно.
- В промпте задавай текст явно в кавычках и указывай, какое слово выделить цветом. Пример: `bold hand-lettered Russian headline «ПИШЕТ САМ» across the top, the word «САМ» in red`.

### Стилевой блок дудла (positive)

Добавляется к каждому дудл-промпту вместо фотореалистичного хвоста:

```
Hand-drawn black ink doodle illustration on warm cream paper background with a subtle vignette darkening toward the edges, simple stick figures with big expressive faces, loose sketchy felt-tip marker lines, a few minimal hand-drawn doodle icons related to the topic around the subject, flat 2D, one accent color used sparingly
```

### Анти-хвост дудла (negative)

Общий бан для обоих слотов:

```
no photorealism, no 3D render, no color photography, no realistic textures, no detailed shading, no gradient mesh, no corporate flat vector, no neon, no cyberpunk, no glossy, no stock illustration look, no watermarks, no logos
```

- Для слота **«без текста»** добавь в конец: `, no text, no captions, no lettering, no words`.
- Для слота **«с текстом»** токен про текст НЕ добавляй (надпись — часть кадра), но оставь `no watermarks, no logos` и добавь `no paragraph text` — чтобы был только крупный заголовок, без мелких подписей.

---

## Запрет повторов между выпусками

Перед сборкой промптов:

1. Найди 2 предыдущие статьи канала: `ls -t <папка статей из профиля>` → возьми 2 свежих файла (кроме текущего).
2. В каждом найди блок «## Промпты для обложек» и строки `**Герой:**` и `**Композиции:**`.
3. Новый комплект НЕ должен повторять из этих двух выпусков: героя, композицию слота «человек», комбинации носитель×ракурс, подачу символа и сам символ.
4. **Дудлы — исключение по глубине:** композиций всего 5, поэтому дудлы не повторяют только ПРЕДЫДУЩИЙ выпуск (1 назад), иначе правило математически невыполнимо (2 выпуска × 2 слота = 4 занятых из 5).
5. Если прошлые статьи старого формата (без строки «Композиции:») — просто выбери осознанно контрастные варианты.

---

## Шаблон промпта

**Фото-слоты:**

```
[SLOT_NAME] cover:
[main subject phrase: hero card OR hands/object, composition from the menu, action and emotion tied to the article],
[surface content in Russian quotes / flat icons description, if слот-носитель | symbol staging with color cue],
[context/scene from the rotation list, chosen for the topic],
[light line from the daylight standard],
warm neutral palette (beige, soft gray, graphite, muted olive) with one [red/green/amber] accent on [object].

[ANTI-AI TAIL — из этого файла, раздел «Анти-AI хвост»]
```

**Дудл-обложки:**

```
Doodle cover ([composition name], [with text | no text]):
[scene: stick figure(s) / sketch, action and emotion from the article],
[hand-drawn doodle icons related to the topic around the subject],
[bold hand-lettered Russian headline «...» with the accent word in red — ONLY for the with-text slot],

[DOODLE STYLE BLOCK] [DOODLE NEGATIVE TAIL]
```

---

## Fewshot-примеры (EN)

### Слот «Человек», композиция Ч2 «Двое» (статья «Что видит сервис, когда вы даёте ему доступ к почте»)

```
Person cover (two-people composition):
a 38-year-old woman, dark shoulder-length wavy hair, minimal makeup, lively ordinary face, wearing a relaxed light-blue denim shirt — showing her phone screen to a colleague across a cafe table, her expression quietly concerned, one eyebrow raised; the colleague leaning in, surprised,
the phone screen partially visible with a simple permissions dialog,
cafe with wooden tables, cups in soft focus,
soft natural daylight from a side window,
warm neutral palette (beige, soft gray, graphite, muted olive) with one red accent on a small dot on the phone screen.

Photorealistic, documentary feel, natural skin texture and materials, ordinary apartment or home office context, clean uncluttered background, one main subject occupying 50-70% of frame, soft natural daylight, warm neutral palette (beige, soft gray, graphite, muted olive), one accent color only, authentic ordinary adult, natural understated expression, no text, no captions, no watermarks, no logos, no robots, no glowing holograms, no neon, no cyberpunk, no sci-fi interfaces, no server rooms, no glossy 3D, no stock illustration look, no overloaded interfaces, no startup glam, no posed studio smile, no helpless-elderly stereotype
```

### Слот «Носитель», телефон × палец тапает + иконки на экране (статья «5 ботов, которые заменяют платные приложения»)

```
Carrier cover (phone, finger-tap, icon screen):
a close-up of natural adult male hands holding a smartphone, index finger tapping the screen,
the screen showing a clean simple grid of 5 large flat rounded app-style icons in muted matte colors, one icon highlighted in green, a short Russian label under the highlighted icon: «бесплатно»,
a blurred kitchen table with a mug behind,
soft morning daylight from a kitchen window,
warm neutral palette (beige, soft gray, graphite, muted olive) with one green accent on the highlighted icon.

Photorealistic, documentary feel, natural skin texture and materials, ordinary apartment or home office context, clean uncluttered background, one main subject occupying 50-70% of frame, soft natural daylight, warm neutral palette (beige, soft gray, graphite, muted olive), one accent color only, no captions, no watermarks, no logos, no robots, no glowing holograms, no neon, no cyberpunk, no sci-fi interfaces, no server rooms, no glossy 3D, no stock illustration look, no overloaded interfaces, no startup glam
```

### Слот «Носитель», распечатка с пометками × flat-lay (статья «Аудит промптов: где вы теряете качество ответов»)

```
Carrier cover (marked printout, flat-lay):
top-down view of a printed A4 page lying on a wooden desk, a hand holding an amber marker over it,
the page showing a plain Russian numbered list of 4 short lines: «1. Роль», «2. Контекст», «3. Формат», «4. …и главное», the last line circled with the amber marker as the accent,
reading glasses and a mug at the edge of frame,
warm afternoon daylight from the left,
warm neutral palette (beige, soft gray, graphite, muted olive) with one amber accent on the circled line.

Photorealistic, documentary feel, natural skin texture and materials, ordinary apartment or home office context, clean uncluttered background, one main subject occupying 50-70% of frame, soft natural daylight, warm neutral palette (beige, soft gray, graphite, muted olive), one accent color only, no captions, no watermarks, no logos, no robots, no glowing holograms, no neon, no cyberpunk, no sci-fi interfaces, no server rooms, no glossy 3D, no stock illustration look, no overloaded interfaces, no startup glam
```

### Слот «Символ», подача С2 «Контраст-пара» (статья «Ручная сборка отчётов против одного сценария»)

```
Symbol cover (contrast pair):
a tall messy stack of printed paper reports on the left and a single clean sheet with a short list on the right, side by side on a beige linen surface,
a small green checkmark drawn on the single sheet as the accent,
soft ambient daylight creating gentle shadows,
warm neutral palette (beige, soft gray, graphite, muted olive) with one green accent on the checkmark.

Photorealistic, documentary feel, natural materials and textures, ordinary apartment or home office context, clean uncluttered background, one main subject occupying 50-70% of frame, soft natural daylight, warm neutral palette (beige, soft gray, graphite, muted olive), one accent color only, no text, no captions, no watermarks, no logos, no people, no faces, no hands, no robots, no glowing holograms, no neon, no cyberpunk, no sci-fi interfaces, no server rooms, no glossy 3D, no stock illustration look, no overloaded interfaces, no startup glam
```

### Дудл-обложки (по одной на композицию; чередуют слоты «с текстом»/«без текста»)

**Композиция 1 — Герой и каракули, с текстом** (статья «Нейросеть пишет посты за тебя»)

```
Doodle cover (hero-and-doodles, with text):
a single black-ink stick figure sitting at a tiny desk, overwhelmed wide-eyed expression, throwing hands up,
scattered hand-drawn doodle icons around it: speech bubbles, a lightning bolt, small gears, scribbled arrows, a tiny laptop,
bold hand-lettered Russian headline «ПИШЕТ САМ» across the top, the word «САМ» in red,

Hand-drawn black ink doodle illustration on warm cream paper background with a subtle vignette darkening toward the edges, simple stick figures with big expressive faces, loose sketchy felt-tip marker lines, a few minimal hand-drawn doodle icons related to the topic around the subject, flat 2D, one accent color used sparingly. no photorealism, no 3D render, no color photography, no realistic textures, no detailed shading, no gradient mesh, no corporate flat vector, no neon, no cyberpunk, no glossy, no stock illustration look, no watermarks, no logos, no paragraph text
```

**Композиция 2 — До / После, без текста** (статья «Рутина вручную против автоматизации»)

```
Doodle cover (before-after, no text):
two black-ink stick figures side by side; the left one slumped and tired buried under a tall stack of papers, droopy sad face; the right one relaxed and smiling, leaning back with a single glowing green checkmark beside it,
a thin hand-drawn vertical divider between them,

Hand-drawn black ink doodle illustration on warm cream paper background with a subtle vignette darkening toward the edges, simple stick figures with big expressive faces, loose sketchy felt-tip marker lines, a few minimal hand-drawn doodle icons related to the topic around the subject, flat 2D, one accent color used sparingly. no photorealism, no 3D render, no color photography, no realistic textures, no detailed shading, no gradient mesh, no corporate flat vector, no neon, no cyberpunk, no glossy, no stock illustration look, no watermarks, no logos, no text, no captions, no lettering, no words
```

**Композиция 3 — Триптих, с текстом** (статья «Настроить автоматизацию за 3 шага»)

```
Doodle cover (triptych, with text):
three vertical panels on one cream sheet divided by thin hand-drawn lines; panel 1 a stick figure staring at a messy tangle of arrows (confused), panel 2 the same figure connecting two boxes with a line (working), panel 3 the figure relaxed with a glowing checkmark (done),
bold hand-lettered Russian headline «3 ШАГА» at the bottom, the «3» in red,

Hand-drawn black ink doodle illustration on warm cream paper background with a subtle vignette darkening toward the edges, simple stick figures with big expressive faces, loose sketchy felt-tip marker lines, a few minimal hand-drawn doodle icons related to the topic around the subject, flat 2D, one accent color used sparingly. no photorealism, no 3D render, no color photography, no realistic textures, no detailed shading, no gradient mesh, no corporate flat vector, no neon, no cyberpunk, no glossy, no stock illustration look, no watermarks, no logos, no paragraph text
```

**Композиция 4 — Герой и толпа, без текста** (статья «Как коллеги реагируют на то, что ты всё автоматизировал»)

```
Doodle cover (hero-and-crowd, no text):
a calm confident black-ink stick figure standing in the center with a slight smile, arms relaxed,
around it several smaller stick figures reacting: one pointing, two whispering to each other, one with a surprised open mouth, one with a small red exclamation mark above its head,

Hand-drawn black ink doodle illustration on warm cream paper background with a subtle vignette darkening toward the edges, simple stick figures with big expressive faces, loose sketchy felt-tip marker lines, a few minimal hand-drawn doodle icons related to the topic around the subject, flat 2D, one accent color used sparingly. no photorealism, no 3D render, no color photography, no realistic textures, no detailed shading, no gradient mesh, no corporate flat vector, no neon, no cyberpunk, no glossy, no stock illustration look, no watermarks, no logos, no text, no captions, no lettering, no words
```

**Композиция 5 — Скетч-портрет, с текстом** (статья «Один промпт меняет всё»)

```
Doodle cover (sketch-portrait, with text):
a detailed black-ink sketch portrait of a face with a sly knowing half-smile, looking at the viewer, a hand-drawn glowing lightbulb doodle above the head as the single accent,
bold hand-lettered Russian headline «ОДИН ПРОМПТ» across the top, the word «ОДИН» in red,

Hand-drawn black ink doodle illustration on warm cream paper background with a subtle vignette darkening toward the edges, expressive ink sketch line work, loose sketchy felt-tip marker lines, flat 2D, one accent color used sparingly. no photorealism, no 3D render, no color photography, no realistic textures, no detailed shading, no gradient mesh, no corporate flat vector, no neon, no cyberpunk, no glossy, no stock illustration look, no watermarks, no logos, no paragraph text
```

---

## Список бытовых фонов для ротации (фото-слоты)

Между фото-обложками сцены должны различаться (где сцена видна). Бери разные:

1. Кухонный стол утром у окна
2. Домашний рабочий стол с ноутбуком
3. Журнальный столик у дивана
4. Подоконник с растением
5. Деревянная полка с книгами
6. Прихожая, ключи и сумка на тумбе
7. Балкон / лоджия со столиком
8. Кафе, деревянный стол с чашкой
9. Магазин / касса / пункт выдачи
10. Спальня, тумбочка у кровати
11. Маленькая столовая, скатерть
12. Угол офиса с растением
13. Аэропорт / вокзал, зона ожидания
14. Парк, скамейка

---

## Чек-лист обложек (применить к комплекту из 4 фото + 2 дудла)

Если на 3+ пункта «нет» — переписать.

1. Все 4 фото-слота на месте (человек / носитель ×2 / символ) + 2 дудла (без текста / с текстом)?
2. **Композиции выбраны из меню и НЕ повторяют 2 предыдущих выпуска** (герой, композиция человека, носитель×ракурс, подача символа; дудлы — не повторяют предыдущий выпуск)? Строка «Композиции:» заполнена?
3. **Действие, эмоция и окружение героя вытекают из ЭТОЙ статьи**, а не из дефолта?
4. Эмоция естественная (4-6/10), **под ставку статьи** (риск→настороженность, выгода→облегчение, выбор→задумчивость)?
5. На носителях — **русский контент из статьи + крючок** (структура / тизер / иконочный экран)? Убран ли `no text` из хвоста этих промптов?
6. Символ **выведен из идеи статьи, специфичен** (не дефолтный замок/шестерёнка/стрелка) и подача — не «просто предмет на столе» третий раз подряд?
7. **Дудл-обложки: две РАЗНЫЕ композиции**, герой/эмоция/каракули из статьи, дудл-стиль и дудл-хвост на месте?
8. **Дудл «с текстом»: 1-3 русских слова, одно слово акцентом**; «без текста» — действительно без надписей?
9. Иконки (если есть): максимум 4, плоские матовые, без свечения, одна акцентная?
10. Один главный объект, один акцентный цвет на смысл?
11. Свет везде светлый дневной (тёмного вечернего нет, если пользователь явно не просил)?
12. Картинка недоговаривает механизм (не дублирует заголовок слово в слово)?
13. Если уменьшить до thumbnail — главный смысл считывается за секунду?
14. Сцены фото-обложек различаются между собой?

---

## Output формат для дописывания в файл статьи

В конец .md файла статьи (после CTA-блока) добавляется отдельный блок:

```markdown
---

## Промпты для обложек (nano-banana-pro)

**Свет:** дневной стандарт {или явно заданный пак}
**Герой:** {код из ростера} — [одна строка, почему под эту статью]
**Композиции:** человек={Ч#}; носитель={носитель}×{ракурс}, {носитель}×{ракурс}; символ={С#}+{предмет}; дудлы={композиция А}, {композиция Б}

Четыре фото-обложки + две дудл-обложки.

### Слот 1 — человек ({композиция})
**Логика:** [что герой делает и чувствует по теме статьи]

```
[full EN prompt with hero card + anti-AI tail]
```

### Слот 2 — носитель ({носитель} × {ракурс})
**Контент:** [структура / тизер / иконочный экран + крючок]

```
[full EN prompt, no text removed from tail]
```

### Слот 3 — носитель ({носитель} × {ракурс})
**Контент:** [...]

```
[full EN prompt, no text removed from tail]
```

### Слот 4 — символ ({подача})
**Символ и почему:** [какой предмет и из какой идеи статьи выведен]

```
[full EN prompt, no people in tail (кроме подачи «в руке»)]
```

### Дудл-обложка А — без текста
**Композиция:** [...] — [почему под статью]

```
[full EN doodle prompt, no-text tail]
```

### Дудл-обложка Б — с текстом
**Композиция:** [другая, не как у А] — [почему под статью]
**Текст:** «...» (выделить слово «...» красным)

```
[full EN doodle prompt, with-text tail]
```
```

Анти-AI хвост (фото) и дудл-стиль вставляются в каждый промпт **целиком** (не ссылкой), чтобы можно было скопировать промпт одной кнопкой.
