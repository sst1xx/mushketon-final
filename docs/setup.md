# Настройка (один раз)

## 1. GitHub

1. Зарегистрироваться на [github.com](https://github.com)
2. Создать репозиторий `mushketon-final` → **Public** → **Create**
3. Загрузить все файлы в корень репозитория

## 2. GitHub Pages

1. Репозиторий → **Settings** → **Pages**
2. Source: **Deploy from a branch** → `main` / `(root)` → **Save**
3. Через ~1 минуту страницы доступны:
   - `https://ВАШ_ЛОГИН.github.io/mushketon-final/judge/`
   - `https://ВАШ_ЛОГИН.github.io/mushketon-final/scoreboard/`

## 3. Supabase

1. Зарегистрироваться на [supabase.com](https://supabase.com)
2. **New project** → название → **Create** → подождать ~2 минуты

### 3а. Настройки API

**Project Settings → API → Data API:**
- Enable Data API: ✅ ON
- Automatically expose new tables: ❌ OFF
- Enable automatic RLS: ✅ ON

### 3б. Создать таблицы и политики

**SQL Editor → New Query** → вставить содержимое `supabase_setup.sql`

⚠️ В первой строке заменить `REPLACE_ME` на свой секретный токен → **Run**

### 3в. Выдать права

```sql
GRANT SELECT ON competitions TO anon;
GRANT SELECT ON shooters     TO anon;
GRANT INSERT, UPDATE         ON competitions TO anon;
GRANT INSERT, UPDATE, DELETE ON shooters     TO anon;
```

### 3г. Включить Realtime

Table Editor → таблица `shooters` → **Edit table** → **Enable Realtime** → Save.
Повторить для `competitions`.

### 3д. Вставить ключи в HTML-файлы

В `judge/index.html` и `scoreboard/index.html` заменить:

```
REPLACE_WITH_YOUR_SUPABASE_URL      → Project URL (Settings → API)
REPLACE_WITH_YOUR_SUPABASE_ANON_KEY → anon public key
```

> ⚠️ Ключи не вносить в этот файл — репозиторий публичный.
