# Архитектура Mushketon Final

## Обзор

```
Судья / Организатор
  │  открывает постоянную секретную ссылку
  │  judge/?token=ВАШ_ТОКЕН
  ▼
judge/index.html  (GitHub Pages)
  │
  │  INSERT / UPDATE  ──────────────────────────────┐
  │  заголовок: x-judge-token: ВАШ_ТОКЕН            │
  ▼                                                  ▼
Supabase DB (PostgreSQL)              Supabase RLS проверяет токен
  │                                    ├─ анонимы → только SELECT
  │  Realtime broadcast (push)         └─ судья   → SELECT + INSERT + UPDATE + DELETE
  ▼
scoreboard/index.html  (GitHub Pages)
  │  чёрный фон, белый текст, жёлтый лидер
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

---

## Авторизация судьи

Используется **секретный токен в URL** — без формы входа, без email.

```
URL судьи:
  https://sst1xx.github.io/mushketon-final/judge/?token=ВАШ_ТОКЕН

Как работает:
  1. JS читает токен из URL-параметра
  2. Передаёт его в заголовке каждого запроса к Supabase:
       x-judge-token: ВАШ_ТОКЕН
  3. RLS-политика Supabase сравнивает заголовок с get_judge_token()
  4. Совпадает → запись разрешена
     Не совпадает / нет токена → запись отклонена
```

Токен хранится **только в двух местах:**
- В функции `get_judge_token()` в Supabase (не публично)
- В URL ссылки у судьи

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
| `target` | integer | номер щита |
| `name` | text | фамилия участника |
| `position` | integer | 1 или 2 (порядок в паре) |
| `s1`..`s6` | decimal | суммы серий (вводит судья) |

**Пара** = две строки с одинаковым `target`.  
**Итого пары** = сумма всех `s1..s6` обоих участников.

---

## Realtime

Scoreboard **не опрашивает** базу по таймеру.  
Supabase сам пушит изменения через WebSocket при каждом UPDATE/INSERT в таблице `shooters`.

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

Секрет хранится в функции базы данных:
```sql
CREATE OR REPLACE FUNCTION get_judge_token()
RETURNS text LANGUAGE sql SECURITY DEFINER STABLE AS $$
  SELECT 'ВАШ_ТОКЕН';
$$;
```

---

## Смена токена

Если нужно сменить судью или отозвать доступ:

```sql
-- Supabase → SQL Editor
CREATE OR REPLACE FUNCTION get_judge_token()
RETURNS text LANGUAGE sql SECURITY DEFINER STABLE AS $$
  SELECT 'НОВЫЙ_ТОКЕН';
$$;
```

Отправить судье новую ссылку с новым токеном. Код репозитория не меняется.
