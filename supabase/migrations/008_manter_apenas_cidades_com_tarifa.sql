-- ============================================================
-- Passaí — Manter Apenas Cidades e Rotas com Preço de Passagem
-- Migração: 008_manter_apenas_cidades_com_tarifa.sql
-- ============================================================
-- Este script realiza a limpeza no banco de dados de produção para
-- que permaneçam estritamente as cidades e rotas que possuem tarifa
-- cadastrada (tarifa IS NOT NULL).
--
-- Resultado esperado:
-- - Cidades mantidas: 37 (17 cidades sem tarifa removidas)
-- - Rotas mantidas: 50 (49 rotas sem tarifa removidas)
-- - Horários mantidos: 1.790 (843 horários de rotas sem tarifa removidos)
-- ============================================================

BEGIN;

-- 1. Identificar as 37 cidades que participam de rotas com tarifa
CREATE TEMP TABLE cidades_com_tarifa AS
SELECT DISTINCT c.id
FROM public.cidades c
JOIN public.rotas r ON (r.origem_id = c.id OR r.destino_id = c.id)
WHERE r.tarifa IS NOT NULL;

-- 2. Remover alterações de horário vinculadas aos horários que serão excluídos (se houver)
DELETE FROM public.alteracoes_horario
WHERE horario_id IN (
    SELECT id FROM public.horarios
    WHERE rota_id IN (
        SELECT id FROM public.rotas
        WHERE tarifa IS NULL
           OR origem_id NOT IN (SELECT id FROM cidades_com_tarifa)
           OR destino_id NOT IN (SELECT id FROM cidades_com_tarifa)
    )
);

-- 3. Remover os horários de todas as rotas que não possuem tarifa ou envolvem cidades sem tarifa
DELETE FROM public.horarios
WHERE rota_id IN (
    SELECT id FROM public.rotas
    WHERE tarifa IS NULL
       OR origem_id NOT IN (SELECT id FROM cidades_com_tarifa)
       OR destino_id NOT IN (SELECT id FROM cidades_com_tarifa)
);

-- 4. Remover todas as rotas sem tarifa ou que envolvam cidades sem tarifa
DELETE FROM public.rotas
WHERE tarifa IS NULL
   OR origem_id NOT IN (SELECT id FROM cidades_com_tarifa)
   OR destino_id NOT IN (SELECT id FROM cidades_com_tarifa);

-- 5. Remover as 17 cidades que não possuem mais nenhuma rota associada
DELETE FROM public.cidades
WHERE id NOT IN (SELECT id FROM cidades_com_tarifa);

-- 6. Limpeza da tabela temporária
DROP TABLE cidades_com_tarifa;

COMMIT;

-- Verificação final de integridade (deve retornar 37 cidades, 50 rotas, 1790 horários)
SELECT 
    (SELECT count(*) FROM public.cidades) AS total_cidades,
    (SELECT count(*) FROM public.rotas) AS total_rotas,
    (SELECT count(*) FROM public.horarios) AS total_horarios,
    (SELECT count(*) FROM public.rotas WHERE tarifa IS NULL) AS rotas_sem_tarifa;
