# Архитектура Mushketon Final

## Обзор

```
Судья открывает секретную ссылку
  judge/?token=tbZaFybX5JWrjgdXmDcT
        │
        │  INSERT / UPDATE
        │  заголовок: x-judge-token: TOKEN
        ▼
Supabase DB (PostgreSQL)
  ├─ RLS: анонимы → только SELECT
  └─ RLS: с токеном → SELECT + INSERT + UPDATE + DELETE
        │
        │  Realtime broadcast (WebSocket push)
        ▼
scoreboard/index.html  (GitHub Pages)
        │
        ▼
Зрители — любой браузер, любое устройство
```

---

## Сервисы

| Сервис | Роль | Тариф |
|--------|------|-------|
| **GitHub** | хранение кода | бесплатно |
| **GitHub Pages** | хостинг HTML | бесплатно |
| **Supabase** | БД + Realtime + RLS | бесплатно |

**URL:**
- Судья: `https://sst1xx.github.io/mushketon-final/judge/?token=tbZaFybX5JWrjgdXmDcT`
- Зрители: `https://sst1xx.github.io/mushketon-final/scoreboard/`

---

## Авторизация судьи

Секретный токен в URL — без формы входа, без email.

```
1. JS читает токен из URL-параметра: ?token=...
2. Supabase-клиент создаётся с заголовком:
     x-judge-token: TOKEN
3. RLS-политика проверяет:
     current_setting('request.headers')::json->>'x-judge-token'
     = get_judge_token()
4. Совпадает → запись разрешена
   Не совпадает / нет токена → только чтение
```

Токен хранится в двух местах:
- Функция `get_judge_token()` в Supabase (не публично)
- URL ссылки у судьи

В коде репозитория токена **нет**.

---

## База данных

### Таблица `competitions`

| Поле | Тип | Описание |
|------|-----|----------|
| `id` | uuid | первичный ключ |
| `date` | date | дата (проставляется автоматически) |
| `is_active` | boolean | текущее активное соревнование |

### Таблица `shooters`

| Поле | Тип | Описание |
|------|-----|----------|
| `id` | uuid | первичный ключ |
| `competition_id` | uuid | ссылка на соревнование |
| `target` | integer | номер щита (1–20) |
| `name` | text | фамилия участника |
| `position` | integer | всегда 1 (один стрелок на щит) |
| `s1`..`s6` | decimal | суммы серий |

---

## Логика пар

Пара = два соседних щита:

```
Пара 1 = щит 1 + щит 2
Пара 2 = щит 3 + щит 4
Пара 3 = щит 5 + щит 6
...
Пара 10 = щит 19 + щит 20
```

Группировка: `Math.floor((target - 1) / 2)`

Итого пары = сумма всех `s1..s6` обоих стрелков.

---

## Серии

Заголовки колонок серий = количество выстрелов в серии:

```
5 | 5 | 5 | 3 | 3 | 3
```

Всегда 6 колонок. Значение ячейки = сумма серии (судья смотрит на экран установки и вводит).

---

## Realtime

Scoreboard не опрашивает базу по таймеру. Supabase пушит изменения через WebSocket:

```
Судья нажал Enter
  → Supabase UPDATE shooters
    → Realtime broadcast
      → scoreboard получает событие
        → пересчитывает рейтинг
          → перерисовывает таблицу
```

Задержка: ~100–300 мс.

---

## Страница судьи

### Навигация в таблице

| Клавиша | Действие |
|---------|---------|
| Enter | ↓ следующая строка (тот же столбец) |
| Tab | → следующий столбец |
| Shift+Tab | ← предыдущий столбец |
| ↑ ↓ | строка выше/ниже |
| ← → | столбец влево/вправо |

### Рейтинг внизу

Под таблицей ввода отображается текущий рейтинг пар.
Данные берутся из того же массива `shooters` (нет дублирования запросов).
Обновляется после каждого сохранения.

---

## Структура репозитория

```
mushketon-final/
├── judge/
│   └── index.html          — страница судьи
├── scoreboard/
│   └── index.html          — экран зрителей
├── docs/
│   └── architecture.md     — этот файл
├── supabase_setup.sql       — SQL для первоначальной настройки
└── README.md                — инструкция по настройке
```

---

## RLS политики

```sql
-- Все могут читать
CREATE POLICY "read" ON shooters FOR SELECT TO anon USING (true);

-- Судья может писать (только с правильным токеном)
CREATE POLICY "judge_write" ON shooters FOR INSERT TO anon
  WITH CHECK (
    (current_setting('request.headers', true)::json->>'x-judge-token')
    = get_judge_token()
  );
```

Секрет хранится в функции:
```sql
CREATE OR REPLACE FUNCTION get_judge_token()
RETURNS text LANGUAGE sql SECURITY DEFINER STABLE AS $$
  SELECT 'ВАШ_ТОКЕН';
$$;
```

---

## Смена токена

```sql
-- Supabase → SQL Editor
CREATE OR REPLACE FUNCTION get_judge_token()
RETURNS text LANGUAGE sql SECURITY DEFINER STABLE AS $$
  SELECT 'НОВЫЙ_ТОКЕН';
$$;
```

Отправить судье новую ссылку. Код репозитория не меняется.
