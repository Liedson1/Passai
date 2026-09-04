-- ============================================================
-- Passaí — Criação da tabela alteracoes_horario (RN03 - RN06)
-- Migração: 002_create_alteracoes_horario.sql
--
-- Execute este script no SQL Editor do seu dashboard Supabase
-- para habilitar o registro e exibição de alterações de horário.
-- ============================================================

CREATE TABLE IF NOT EXISTS alteracoes_horario (
  id              SERIAL PRIMARY KEY,
  horario_id      INTEGER NOT NULL REFERENCES horarios (id) ON DELETE CASCADE,
  hora_original   TIME NOT NULL,
  hora_nova       TIME NOT NULL,
  van_original    TEXT,
  van_substituta  TEXT,
  motivo          TEXT,
  data_alteracao  DATE NOT NULL DEFAULT CURRENT_DATE,
  ativa           BOOLEAN NOT NULL DEFAULT TRUE
);

-- Índices de performance
CREATE INDEX IF NOT EXISTS idx_alteracoes_horario_id   ON alteracoes_horario (horario_id);
CREATE INDEX IF NOT EXISTS idx_alteracoes_data_ativa   ON alteracoes_horario (data_alteracao, ativa);

-- Habilita Row Level Security (RLS)
ALTER TABLE alteracoes_horario ENABLE ROW LEVEL SECURITY;

-- Política de leitura pública (RN01 — sem autenticação)
DROP POLICY IF EXISTS "leitura_publica_alteracoes" ON alteracoes_horario;
CREATE POLICY "leitura_publica_alteracoes"
  ON alteracoes_horario FOR SELECT
  USING (ativa = true AND data_alteracao = CURRENT_DATE);

-- Exemplo de alteração para teste (opcional):
-- INSERT INTO alteracoes_horario (horario_id, hora_original, hora_nova, van_original, van_substituta, motivo)
-- VALUES (1, '06:00', '06:20', 'Van 02', 'Van 05', 'Troca de pneu');
