-- ============================================================
-- Mushketon Live Scoring — добавить поля таймера в competitions
-- Запустить ОДИН РАЗ на живой базе:
-- Supabase → SQL Editor → New Query → вставить → Run
-- ============================================================

ALTER TABLE competitions
  ADD COLUMN IF NOT EXISTS timer_started_at  timestamptz,
  ADD COLUMN IF NOT EXISTS timer_duration    integer,
  ADD COLUMN IF NOT EXISTS timer_active      boolean NOT NULL DEFAULT false;

-- RLS: политики для судьи уже покрывают UPDATE competitions —
-- новые поля автоматически попадают под существующие политики
-- judge_update_competition (проверяет x-judge-token).
-- Отдельных политик добавлять не нужно.
