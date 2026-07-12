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

### 3б. Создать таблицы, политики, права и Realtime

**SQL Editor → New Query** → вставить всё содержимое `supabase_setup.sql`

⚠️ В первой строке заменить `REPLACE_ME` на свой секретный токен → **Run**

> Этот один SQL делает всё сразу: таблицы, RLS-политики, `GRANT`-права и включение
> Realtime. Ручные шаги в консоли не нужны.

### 3в. Вписать ключи в `config.js`

В корневом файле `config.js` заменить значения:

```js
window.MUSHKETON_CONFIG = {
  SUPABASE_URL: '...',       // Project URL (Settings → API)
  SUPABASE_ANON_KEY: '...'   // anon public key
};
```

> Ключи теперь в одном месте — обе страницы (`judge/`, `scoreboard/`) читают
> его через `../config.js`. anon key публичен по дизайну — защита через RLS.
