-- ============================================================
-- Passaí — Limpeza de Cidades sem Rotas Associadas
-- Migração: 013_remover_cidades_sem_rotas.sql
-- ============================================================
-- Contexto:
-- A migração 012 cadastrou localidades e cidades intermediárias
-- dos seccionamentos diretamente na tabela `cidades`.
-- Como essas cidades não são pontas de linha (origem/destino de rotas),
-- elas não possuem rotas associadas, gerando pesquisas sem resultado.
--
-- Esta migração remove da tabela `cidades` todos os registros que
-- não possuem rotas ativas vinculadas como origem ou destino (RN02),
-- mantendo a integridade com as 37 cidades operacionais oficiais.
-- ============================================================

BEGIN;

-- Remove cidades que não participam de nenhuma rota ativa (origem ou destino)
DELETE FROM public.cidades
WHERE id NOT IN (
    SELECT origem_id FROM public.rotas WHERE ativa = true
    UNION
    SELECT destino_id FROM public.rotas WHERE ativa = true
);

COMMIT;

-- Verificação das 37 cidades operacionais mantidas:
SELECT count(*) AS total_cidades_operacionais FROM public.cidades;
