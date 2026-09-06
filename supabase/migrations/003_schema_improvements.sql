-- ============================================================
-- Passaí — Melhorias de schema (sem breaking changes)
-- Migração: 003_schema_improvements.sql
-- ============================================================

-- -------------------------------------------------------------
-- 1. Garantir unicidade de cidades por (nome, estado)
--    Evita duplicatas silenciosas no seed e na administração.
-- -------------------------------------------------------------
ALTER TABLE cidades
  ADD CONSTRAINT uq_cidades_nome_estado UNIQUE (nome, estado);

-- -------------------------------------------------------------
-- 2. Precisão real em distancia_km
--    INTEGER não representa 64.5 km. NUMERIC(6,1) resolve.
--    USING faz cast seguro dos valores existentes.
-- -------------------------------------------------------------
ALTER TABLE rotas
  ALTER COLUMN distancia_km TYPE NUMERIC(6, 1)
  USING distancia_km::NUMERIC(6, 1);

-- -------------------------------------------------------------
-- 3. Índice trigram em cidades.nome
--    Habilita busca por substring eficiente (ILIKE '%termo%')
--    sem sequential scan — prepara autocomplete server-side.
--    pg_trgm já está disponível por padrão no Supabase.
-- -------------------------------------------------------------
CREATE EXTENSION IF NOT EXISTS pg_trgm;

CREATE INDEX IF NOT EXISTS idx_cidades_nome_trgm
  ON cidades USING gin (nome gin_trgm_ops);

-- -------------------------------------------------------------
-- 4. Garantir ON DELETE CASCADE em alteracoes_horario
--    A 001 criou sem CASCADE. Se a tabela já existe (via 002),
--    este bloco recria a constraint corretamente.
-- -------------------------------------------------------------
ALTER TABLE alteracoes_horario
  DROP CONSTRAINT IF EXISTS alteracoes_horario_horario_id_fkey;

ALTER TABLE alteracoes_horario
  ADD CONSTRAINT alteracoes_horario_horario_id_fkey
  FOREIGN KEY (horario_id) REFERENCES horarios (id) ON DELETE CASCADE;

-- -------------------------------------------------------------
-- NOTA: hora_original em alteracoes_horario é mantida.
--       É necessária para exibir o horário original ao passageiro
--       quando há alteração (RN06 — identificação visual).
--       Remover causaria perda de informação de negócio.
-- -------------------------------------------------------------
