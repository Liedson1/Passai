-- ============================================================
-- Passaí — Manter Apenas Cidades e Rotas com Preço de Passagem
-- Migração: 008_manter_apenas_cidades_com_tarifa.sql
-- ============================================================
-- Utiliza estritamente a coluna existente 'rotas.tarifa',
-- sem criar tabelas temporárias nem colunas adicionais.
--
-- Resultado:
-- - Cidades mantidas: 37 (17 cidades sem preço removidas)
-- - Rotas mantidas: 50 (todas com tarifa preenchida)
-- - Horários mantidos: 1.790 (horários de rotas sem preço removidos)
-- ============================================================

BEGIN;

-- 1. Remove os horários vinculados a rotas que não têm preço cadastrado
DELETE FROM public.horarios
WHERE rota_id IN (
    SELECT id FROM public.rotas WHERE tarifa IS NULL
);

-- 2. Remove as rotas sem preço (usa a coluna tarifa já existente na tabela rotas)
DELETE FROM public.rotas
WHERE tarifa IS NULL;

-- 3. Remove as cidades que não participam de nenhuma rota com preço
DELETE FROM public.cidades
WHERE id NOT IN (
    SELECT origem_id FROM public.rotas
    UNION
    SELECT destino_id FROM public.rotas
);

COMMIT;

-- Verificação final de conferência:
SELECT 
    (SELECT count(*) FROM public.cidades) AS cidades_mantidas,
    (SELECT count(*) FROM public.rotas) AS rotas_mantidas,
    (SELECT count(*) FROM public.horarios) AS horarios_mantidos,
    (SELECT count(*) FROM public.rotas WHERE tarifa IS NULL) AS rotas_sem_tarifa;
