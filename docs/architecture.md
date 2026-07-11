# Архитектура Mushketon Live Scoring

## Схема потока данных

```
Судья открывает секретную ссылку (?token=...)
        │
        ▼
judge/index.html (GitHub Pages)
        │  INSERT / UPDATE с заголовком x-judge-token
        ▼
Supabase DB (PostgreSQL)
        │  Realtime broadcast (WebSocket push, без polling)
        ▼
scoreboard/index.html (GitHub Pages)
        │
        ▼
Зрители
```

## Сервисы

| Сервис | Назначение | Тариф |
|--------|-----------|-------|
| GitHub | хранение кода | бесплатно |
| GitHub Pages | хостинг HTML | бесплатно |
| Supabase | БД + Realtime + RLS | бесплатно |

## Авторизация судьи

- Токен передаётся в URL: `?token=...`
- JS читает токен и добавляет в каждый запрос заголовок `x-judge-token`
- Supabase RLS проверяет заголовок через функцию `get_judge_token()`
- Токен хранится ТОЛЬКО в: Supabase (функция) + URL у судьи
- В коде репозитория токена нет
- Anon key в коде — публичный по дизайну, защита через RLS

## RLS политики

```
Все (анонимы)        → только SELECT
Запрос с токеном     → SELECT + INSERT + UPDATE + DELETE
```

## База данных

### Таблица `competitions`

| Поле | Тип | Описание |
|------|-----|----------|
| `id` | uuid | PK |
| `date` | date | дата (проставляется автоматически) |
| `is_active` | boolean | активное соревнование |

### Таблица `shooters`

| Поле | Тип | Описание |
|------|-----|----------|
| `id` | uuid | PK |
| `competition_id` | uuid | FK → competitions |
| `target` | integer | номер щита (1–20) |
| `name` | text | фамилия |
| `position` | integer | всегда 1 (один стрелок на щит) |
| `s1`..`s6` | decimal | суммы серий |

## Логика пар

Пара = два соседних щита:

```
Пара 1  = щит  1 + щит  2
Пара 2  = щит  3 + щит  4
...
Пара 10 = щит 19 + щит 20
```

Итого пары = сумма всех `s1..s6` обоих стрелков.
Группировка в JS: `Math.floor((target - 1) / 2)`

## Realtime

Scoreboard не опрашивает базу по таймеру. Supabase пушит изменения через WebSocket:

```
Судья нажал Enter
  → Supabase UPDATE shooters
    → Realtime broadcast
      → scoreboard получает событие
        → пересчитывает рейтинг
          → перерисовывает таблицу (~100–300 мс)
```
