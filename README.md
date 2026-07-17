# Mushketon Live Scoring

Система живых результатов для клубных соревнований по правилам ISSF (10 м, смешанные пары).

- Судья вводит суммы серий на странице `/judge/`
- Зрители видят актуальный рейтинг на странице `/scoreboard/` — обновление мгновенное, без перезагрузки

## Документация

| | |
|--|--|
| 📐 [Архитектура](docs/architecture.md) | Схема данных, БД, авторизация, Realtime |
| ⚙️ [Настройка](docs/setup.md) | GitHub, GitHub Pages, Supabase — первый запуск |
| 📖 [Руководство](docs/usage.md) | Как работать перед и во время соревнования |
| 📋 [История изменений](docs/changelog.md) | Что сделано, идеи для следующей версии |

---

## Репозиторий и хостинг

| Что | Где |
|-----|-----|
| Репозиторий | https://github.com/sst1xx/mushketon-final |
| Страница судьи | `https://sst1xx.github.io/mushketon-final/judge/?token=ВАШ_ТОКЕН` |
| Страница зрителей | https://sst1xx.github.io/mushketon-final/scoreboard/ |
| Хостинг | GitHub Pages (ветка main, публичный репозиторий) |

| Сервис | Назначение | Аккаунт |
|--------|-----------|---------|
| GitHub | хранение кода | sst1xx |
| GitHub Pages | хостинг HTML | — |
| Supabase | БД + Realtime + RLS | проект dqtwattqjzeukyxpnicj |

> ⚠️ Ключи Supabase (URL, anon key, токен судьи) хранятся отдельно и не вносятся в этот файл.

---

## Структура файлов

```
mushketon-final/
├── judge/
│   └── index.html          — страница судьи
├── scoreboard/
│   └── index.html          — экран зрителей
├── docs/
│   ├── architecture.md     — архитектура приложения
│   ├── setup.md            — первоначальная настройка
│   ├── usage.md            — руководство пользователя
│   └── changelog.md        — история изменений
├── sql/
│   ├── supabase_setup.sql     — SQL для первоначальной настройки (с нуля)
│   ├── add-timer-fields.sql   — миграция: добавить поля таймера на живую базу
│   └── rotate-token.sql       — смена токена судьи
└── README.md                — этот файл
```
