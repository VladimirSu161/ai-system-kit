# Настройка Yandex Cloud Search API (Wordstat)

Старый Wordstat API (`api.wordstat.yandex.net`, OAuth-токен) закрыт. Сейчас Wordstat доступен только
через **Yandex Cloud Search API v2** — это платный API, привязанный к каталогу (folder) в Yandex Cloud
с включённым платёжным аккаунтом.

## Шаг 1: Платёжный аккаунт и каталог

1. Зайдите на https://aistudio.yandex.cloud (Yandex Cloud AI Studio)
2. Создайте или выберите облако и каталог (folder) — понадобится его **ID** (`YANDEX_FOLDER_ID`)
3. Подключите платёжный аккаунт (billing account) — без него запросы не проходят, даже пробные

## Шаг 2: Сервисный аккаунт и роль

1. В каталоге создайте сервисный аккаунт (service account)
2. Назначьте ему роль **`search-api.webSearch.user`**
3. Создайте для этого сервисного аккаунта **API-ключ** (Api-Key, не OAuth-токен и не IAM-токен)

## Шаг 3: Настройте `.env`

```bash
cp config/.env.example config/.env
```

Впишите в `config/.env`:

```
YANDEX_API_KEY=ваш_api_ключ
YANDEX_FOLDER_ID=ваш_folder_id
```

## Проверка

```bash
bash scripts/quota.sh
```

Должно показать "Wordstat API: OK".

## Частые проблемы

- **401/403** — ключ не привязан к сервисному аккаунту с ролью `search-api.webSearch.user`, либо в каталоге нет платёжного аккаунта
- **INVALID_ARGUMENT про folderId** — `YANDEX_FOLDER_ID` пуст или указан ID облака вместо ID каталога
- **INVALID_ARGUMENT про toDate** — для `dynamics` с `period=PERIOD_MONTHLY` дата `toDate` обязана быть последним днём месяца (скрипт делает это автоматически)
- **INVALID_ARGUMENT про num_phrases** (topRequests) — поле обязательно, рабочего дефолта без него нет, несмотря на то что в некоторых источниках упоминается дефолт 20; скрипты этого скилла всегда передают его явно

## Лимиты и цены

- **10 запросов в секунду, 100 запросов в час**
- `topRequests`, `dynamics` — 20 ₽ за 1000 запросов
- `regions` — 50 ₽ за 1000 запросов
- `getRegionsTree` — бесплатно

## Важно: операторы Wordstat не поддерживаются

Новый API принимает только обычный текст в `phrase` (до 400 символов). Операторы старого Wordstat
(`!слово`, `+слово`, `"фраза"`, `(a|b)`, минус-слова) **не интерпретируются** — API не выдаст ошибку,
но и не применит их как операторы, а будет искать это как часть текста фразы. Это касается и
`scripts/missed_demand.py` / `query_total.sh` — метод «упущенного спроса» построен на OR-синтаксисе
Wordstat, который в новом API не работает как раньше (подробности — в `references/MISSED_DEMAND.md`).

## Документация

- Yandex Cloud Search API: https://yandex.cloud/en/docs/search-api/
- Wordstat в Search API: https://aistudio.yandex.ru/docs/en/search-api/wordstat/
- Регионы (getRegionsTree): https://aistudio.yandex.ru/docs/ru/search-api/operations/wordstat-getregiontree.html
