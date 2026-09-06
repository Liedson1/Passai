-- ============================================================
-- Passaí — Atualização de Tarifas e Desativação de Rotas sem Horários
-- Migração: 007_update_tarifas_e_desativar_rota100.sql
-- ============================================================

-- 1. Atualiza tarifa da rota Arapiraca -> Maceió (via Litoral) para R$ 36,00
UPDATE public.rotas
SET tarifa = 36.00
WHERE id = 6;

-- 2. Atualiza tarifa da rota Olho d'Água das Flores -> Arapiraca para R$ 28,00
UPDATE public.rotas
SET tarifa = 28.00
WHERE id = 54;

-- 3. Desativa rota Palmeira dos Índios -> Maceió (ID 100) pois não possui horários cadastrados
UPDATE public.rotas
SET ativa = false
WHERE id = 100;
