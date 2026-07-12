-- ============================================================
-- Mushketon Live Scoring — SQL для запуска в Supabase
-- Supabase → SQL Editor → New Query → вставить всё → Run
-- ============================================================

-- ШАГ 1: Создай функцию с твоим секретным токеном
-- Замени 'REPLACE_ME' на любую строку, например 'mushketon2025'
-- Это же значение будет в ссылке судьи: ?token=mushketon2025
CREATE OR REPLACE FUNCTION get_judge_token()
RETURNS text
LANGUAGE sql
SECURITY DEFINER
STABLE
AS $$
  SELECT 'REPLACE_ME';
$$;

-- ============================================================
-- ШАГ 2: Таблица соревнований
-- ============================================================
CREATE TABLE IF NOT EXISTS competitions (
  id         uuid    DEFAULT gen_random_uuid() PRIMARY KEY,
  date       date    NOT NULL DEFAULT CURRENT_DATE,
  is_active  boolean NOT NULL DEFAULT true
);

-- ============================================================
-- ШАГ 3: Таблица участников + результаты серий
-- Каждая строка = один стрелок
-- Пара = две строки с одинаковым target (номером щита)
-- s1..s6 = суммы серий (вводит судья)
-- ============================================================
CREATE TABLE IF NOT EXISTS shooters (
  id             uuid    DEFAULT gen_random_uuid() PRIMARY KEY,
  competition_id uuid    REFERENCES competitions(id) ON DELETE CASCADE,
  target         integer NOT NULL,
  name           text    NOT NULL,
  position       integer NOT NULL CHECK (position IN (1, 2)),
  s1             decimal,
  s2             decimal,
  s3             decimal,
  s4             decimal,
  s5             decimal,
  s6             decimal
);

-- ============================================================
-- ШАГ 4: Row Level Security
-- ============================================================

ALTER TABLE competitions ENABLE ROW LEVEL SECURITY;
ALTER TABLE shooters     ENABLE ROW LEVEL SECURITY;

-- Все могут читать (зрители)
CREATE POLICY "read_competitions" ON competitions
  FOR SELECT TO anon USING (true);

CREATE POLICY "read_shooters" ON shooters
  FOR SELECT TO anon USING (true);

-- Судья может писать (только с правильным токеном в заголовке)
CREATE POLICY "judge_insert_competition" ON competitions
  FOR INSERT TO anon
  WITH CHECK (
    (current_setting('request.headers', true)::json->>'x-judge-token')
    = get_judge_token()
  );

CREATE POLICY "judge_update_competition" ON competitions
  FOR UPDATE TO anon
  USING (
    (current_setting('request.headers', true)::json->>'x-judge-token')
    = get_judge_token()
  );

CREATE POLICY "judge_insert_shooter" ON shooters
  FOR INSERT TO anon
  WITH CHECK (
    (current_setting('request.headers', true)::json->>'x-judge-token')
    = get_judge_token()
  );

CREATE POLICY "judge_update_shooter" ON shooters
  FOR UPDATE TO anon
  USING (
    (current_setting('request.headers', true)::json->>'x-judge-token')
    = get_judge_token()
  );

CREATE POLICY "judge_delete_shooter" ON shooters
  FOR DELETE TO anon
  USING (
    (current_setting('request.headers', true)::json->>'x-judge-token')
    = get_judge_token()
  );

-- ============================================================
-- ШАГ 5: Выдать права анонимной роли (RLS ограничит доступ)
-- Запись разрешена только с правильным токеном (см. ШАГ 4).
-- ============================================================
GRANT SELECT                 ON competitions TO anon;
GRANT INSERT, UPDATE         ON competitions TO anon;
GRANT SELECT                 ON shooters     TO anon;
GRANT INSERT, UPDATE, DELETE ON shooters     TO anon;

-- ============================================================
-- ШАГ 6: Включить Realtime для таблиц
-- ============================================================
ALTER PUBLICATION supabase_realtime ADD TABLE shooters;
ALTER PUBLICATION supabase_realtime ADD TABLE competitions;
