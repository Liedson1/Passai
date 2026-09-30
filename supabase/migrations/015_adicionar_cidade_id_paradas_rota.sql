-- ============================================================
-- Passaí — Adicionar FK cidade_id em paradas_rota
-- Migração: 015_adicionar_cidade_id_paradas_rota.sql
-- ============================================================
-- Contexto:
-- A tabela paradas_rota armazena o nome da cidade como texto livre
-- (campo `cidade TEXT`). Para que o Supabase possa fazer o JOIN
-- automático com a tabela `cidades` e retornar latitude/longitude
-- junto com as paradas (necessário para o mapa interativo), é preciso
-- adicionar a coluna cidade_id com FK para `cidades`.
--
-- Estratégia zero-downtime:
--   1. Adicionar cidade_id nullable (sem quebrar o código existente).
--   2. Popular com JOIN por nome (normalizado) — match case-insensitive.
--   3. Criar FK e índice.
--   4. O campo `cidade` (texto) permanece intacto — backward compatible.
--
-- Rollback: basta remover a coluna cidade_id (ALTER TABLE DROP COLUMN).
-- ============================================================

BEGIN;

-- ----------------------------------------------------------------
-- 1. Adicionar coluna nullable (não quebra queries nem código existente)
-- ----------------------------------------------------------------
ALTER TABLE public.paradas_rota
  ADD COLUMN IF NOT EXISTS cidade_id INTEGER REFERENCES public.cidades(id);

-- ----------------------------------------------------------------
-- 2. Popular cidade_id via JOIN por nome (case-insensitive, trim)
--    Cidades que não existirem em `cidades` ficam com cidade_id NULL —
--    o mapa simplesmente ignora essas paradas (fallback gracioso).
-- ----------------------------------------------------------------
UPDATE public.paradas_rota pr
SET cidade_id = c.id
FROM public.cidades c
WHERE LOWER(TRIM(pr.cidade)) = LOWER(TRIM(c.nome))
  AND pr.cidade_id IS NULL;

-- ----------------------------------------------------------------
-- 3. Índice para performance nas queries do flutter_map join
-- ----------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_paradas_rota_cidade_id
  ON public.paradas_rota (cidade_id);

-- ----------------------------------------------------------------
-- 4. RLS: manter leitura pública (não altera política existente)
-- ----------------------------------------------------------------
-- A política "leitura_publica_paradas_rota" já existe — sem ação.

COMMIT;

-- ----------------------------------------------------------------
-- Verificação: mostra paradas com e sem cidade_id populado
-- ----------------------------------------------------------------
SELECT
  pr.cidade,
  pr.cidade_id,
  c.latitude,
  c.longitude
FROM public.paradas_rota pr
LEFT JOIN public.cidades c ON c.id = pr.cidade_id
ORDER BY pr.cidade
LIMIT 50;
