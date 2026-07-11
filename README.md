# Mushketon Live Scoring

Система живых результатов для клубных соревнований по ISSF (10 м, смешанные пары).

---

## Первоначальная настройка (один раз)

### 1. GitHub

1. Зарегистрироваться на [github.com](https://github.com)
2. Создать новый репозиторий: **New repository** → название `mushketon-final` → **Public** → **Create**
3. Загрузить все файлы из папки `project/` в корень репозитория

### 2. GitHub Pages

1. В репозитории → **Settings** → **Pages**
2. Source: **Deploy from a branch**
3. Branch: `main` / `(root)` → **Save**
4. Через минуту сайт будет доступен по адресу:
   - `https://ВАШ_ЛОГИН.github.io/mushketon-final/judge/`
   - `https://ВАШ_ЛОГИН.github.io/mushketon-final/scoreboard/`

### 3. Supabase

1. Зарегистрироваться на [supabase.com](https://supabase.com)
2. **New project** → придумать название и пароль → **Create new project**
3. Подождать ~2 минуты пока проект создаётся

#### 3а. Настройки API

**Project Settings → API → Data API:**
- Enable Data API: ✅ ON
- Automatically expose new tables: ❌ OFF
- Enable automatic RLS: ✅ ON

#### 3б. Создать таблицы и политики

**SQL Editor → New Query** → вставить содержимое файла `supabase_setup.sql`

⚠️ **Перед запуском:** в первой строке заменить `REPLACE_ME` на свой секретный токен (любое слово/фраза, например `mushketon2025`)

Нажать **Run**.

#### 3в. Получить ключи

**Project Settings → API:**
- Скопировать **Project URL**
- Скопировать **anon public** key

### 4. Вставить ключи в HTML-файлы

В файлах `judge/index.html` и `scoreboard/index.html` заменить:

```
REPLACE_WITH_YOUR_SUPABASE_URL      → ваш Project URL
REPLACE_WITH_YOUR_SUPABASE_ANON_KEY → ваш anon public key
```

Сохранить и загрузить обновлённые файлы в GitHub.

---

## Ссылки

| Кому | Ссылка |
|------|--------|
| Судья / Организатор | `https://ВАШ_ЛОГИН.github.io/mushketon-final/judge/?token=ВАШ_ТОКЕН` |
| Зрители | `https://ВАШ_ЛОГИН.github.io/mushketon-final/scoreboard/` |

Ссылку судьи отправить один раз в личные сообщения. Он сохраняет её в закладки.

---

## Перед каждым соревнованием

1. Открыть ссылку судьи
2. Нажать **+ Новое соревнование**
3. Ввести список участников: щит + фамилия (Enter переходит к следующей строке, пары стоят рядом)
4. Нажать **Старт →**
5. Убедиться что на экране зрителей открыт scoreboard

---

## Во время соревнования (судья)

1. Открыть сохранённую ссылку
2. После каждой серии — ввести сумму серии в соответствующую ячейку
3. Enter или Tab — переход к следующей ячейке
4. Всё сохраняется автоматически

---

## Смена токена

Если нужно выдать новый токен (сменился судья):

1. Supabase → SQL Editor:
   ```sql
   CREATE OR REPLACE FUNCTION get_judge_token()
   RETURNS text LANGUAGE sql SECURITY DEFINER STABLE AS $$
     SELECT 'НОВЫЙ_ТОКЕН';
   $$;
   ```
2. Отправить судье новую ссылку с новым токеном

Код репозитория при этом **не меняется**.
