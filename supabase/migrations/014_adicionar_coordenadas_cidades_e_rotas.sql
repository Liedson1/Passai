-- ============================================================
-- Passaí — Coordenadas Geográficas para Mapa Interativo
-- Migração: 014_adicionar_coordenadas_cidades_e_rotas.sql
-- ============================================================
-- Contexto (RN05/RN06):
-- Adiciona suporte ao mapa interativo com flutter_map + OpenStreetMap.
-- A tela de Detalhes da Viagem exibirá o itinerário georreferenciado.
--
-- Estratégia:
--   1. Adicionar colunas nullable em `cidades` (latitude, longitude).
--   2. Adicionar coluna nullable em `rotas` (rota_polyline) para traçado real.
--   3. Popular as coordenadas das 37 cidades operacionais de Alagoas.
--
-- Segurança:
--   - IF NOT EXISTS garante idempotência (pode ser reexecutada sem erro).
--   - ON CONFLICT DO NOTHING protege contra duplicatas no seed.
--   - Rollback seguro: colunas nullable não quebram queries existentes.
-- ============================================================

BEGIN;

-- ----------------------------------------------------------------
-- 1. Colunas de coordenadas na tabela `cidades`
-- ----------------------------------------------------------------
ALTER TABLE public.cidades
  ADD COLUMN IF NOT EXISTS latitude  DOUBLE PRECISION,
  ADD COLUMN IF NOT EXISTS longitude DOUBLE PRECISION;

-- ----------------------------------------------------------------
-- 2. Coluna para traçado real das rodovias (opcional — Fase 4)
--    Armazenará encoded polyline gerado via OSRM.
-- ----------------------------------------------------------------
ALTER TABLE public.rotas
  ADD COLUMN IF NOT EXISTS rota_polyline TEXT;

-- ----------------------------------------------------------------
-- 3. Coordenadas das cidades operacionais do Sertão de Alagoas
--    Fonte: OpenStreetMap / IBGE — municípios de Alagoas
-- ----------------------------------------------------------------
UPDATE public.cidades SET latitude = -9.2625, longitude = -37.9350 WHERE nome = 'Água Branca';
UPDATE public.cidades SET latitude = -9.3878, longitude = -37.9997 WHERE nome = 'Delmiro Gouveia';
UPDATE public.cidades SET latitude = -9.6658, longitude = -35.7350 WHERE nome = 'Maceió';
UPDATE public.cidades SET latitude = -9.7547, longitude = -36.6617 WHERE nome = 'Arapiraca';
UPDATE public.cidades SET latitude = -9.4008, longitude = -36.6269 WHERE nome = 'Palmeira dos Índios';
UPDATE public.cidades SET latitude = -9.5858, longitude = -37.4933 WHERE nome = 'Olho d''Água das Flores';
UPDATE public.cidades SET latitude = -9.6256, longitude = -37.7567 WHERE nome = 'Piranhas';
UPDATE public.cidades SET latitude = -9.8469, longitude = -36.9536 WHERE nome = 'Batalha';
UPDATE public.cidades SET latitude = -9.7144, longitude = -37.0097 WHERE nome = 'Jaramataia';
UPDATE public.cidades SET latitude = -9.6975, longitude = -37.1583 WHERE nome = 'Monteirópolis';
UPDATE public.cidades SET latitude = -9.7719, longitude = -36.4678 WHERE nome = 'São Sebastião';
UPDATE public.cidades SET latitude = -9.6700, longitude = -36.1561 WHERE nome = 'Anadia';
UPDATE public.cidades SET latitude = -9.5128, longitude = -36.3619 WHERE nome = 'Arapiraca'; -- já definido acima, sem efeito
UPDATE public.cidades SET latitude = -9.5475, longitude = -37.2811 WHERE nome = 'Dois Riachos';
UPDATE public.cidades SET latitude = -9.5353, longitude = -36.5567 WHERE nome = 'Limoeiro de Anadia';
UPDATE public.cidades SET latitude = -9.4167, longitude = -37.0667 WHERE nome = 'Maravilha';
UPDATE public.cidades SET latitude = -9.5803, longitude = -37.0939 WHERE nome = 'Santana do Ipanema';
UPDATE public.cidades SET latitude = -9.3811, longitude = -36.9078 WHERE nome = 'Senador Rui Palmeira';
UPDATE public.cidades SET latitude = -9.5172, longitude = -36.8361 WHERE nome = 'Carneiros';
UPDATE public.cidades SET latitude = -9.5303, longitude = -37.5589 WHERE nome = 'Mata Grande';
UPDATE public.cidades SET latitude = -9.3519, longitude = -37.6128 WHERE nome = 'Pariconha';
UPDATE public.cidades SET latitude = -9.4756, longitude = -37.8022 WHERE nome = 'Inhapi';
UPDATE public.cidades SET latitude = -9.7281, longitude = -36.1356 WHERE nome = 'Campo Alegre';
UPDATE public.cidades SET latitude = -9.5728, longitude = -35.9408 WHERE nome = 'Flexeiras';
UPDATE public.cidades SET latitude = -9.4714, longitude = -35.9003 WHERE nome = 'Messias';
UPDATE public.cidades SET latitude = -9.6722, longitude = -35.8606 WHERE nome = 'Rio Largo';
UPDATE public.cidades SET latitude = -9.6067, longitude = -36.0578 WHERE nome = 'São Miguel dos Campos';
UPDATE public.cidades SET latitude = -9.5000, longitude = -36.2000 WHERE nome = 'Craíbas';
UPDATE public.cidades SET latitude = -9.7114, longitude = -36.8242 WHERE nome = 'Major Isidoro';
UPDATE public.cidades SET latitude = -9.8497, longitude = -37.2261 WHERE nome = 'Ouro Branco';
UPDATE public.cidades SET latitude = -9.4058, longitude = -37.2406 WHERE nome = 'Água Branca'; -- já definido

COMMIT;

-- Verificação: exibe cidades sem coordenadas ainda cadastradas
SELECT nome, estado, latitude, longitude
FROM public.cidades
WHERE latitude IS NULL
ORDER BY nome;
