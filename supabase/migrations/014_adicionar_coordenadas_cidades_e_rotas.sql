-- ============================================================
-- Passaí — Coordenadas Geográficas para Mapa Interativo
-- Migração: 014_adicionar_coordenadas_cidades_e_rotas.sql
-- ============================================================
-- Contexto (RN05/RN06):
-- Adiciona suporte ao mapa interativo com flutter_map + OpenStreetMap.
-- A tela de Detalhes da Viagem exibirá o itinerário georreferenciado.
--
-- Cobertura: TODAS as cidades e localidades que aparecem em paradas_rota
-- (migrações 009 e 012), garantindo que o mapa seja renderizado para
-- qualquer rota que tenha itinerário com paradas intermediárias.
--
-- Fonte das coordenadas: OpenStreetMap / IBGE — municípios de Alagoas.
-- Localidades rurais (Pé Leve, Bom Jardim etc.) usam coordenadas
-- aproximadas baseadas na referência geográfica do município-sede.
--
-- Segurança:
--   - IF NOT EXISTS garante idempotência.
--   - UPDATE não afeta linhas inexistentes — sem risco de erro.
--   - Colunas nullable: não quebram queries existentes.
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
-- 3. Coordenadas — Municípios principais (pontos de origem/destino)
-- ----------------------------------------------------------------
UPDATE public.cidades SET latitude = -9.2625,  longitude = -37.9350 WHERE nome = 'Água Branca';
UPDATE public.cidades SET latitude = -9.3878,  longitude = -37.9997 WHERE nome = 'Delmiro Gouveia';
UPDATE public.cidades SET latitude = -9.6658,  longitude = -35.7350 WHERE nome = 'Maceió';
UPDATE public.cidades SET latitude = -9.7547,  longitude = -36.6617 WHERE nome = 'Arapiraca';
UPDATE public.cidades SET latitude = -9.4008,  longitude = -36.6269 WHERE nome = 'Palmeira dos Índios';
UPDATE public.cidades SET latitude = -9.5858,  longitude = -37.4933 WHERE nome = 'Olho d''Água das Flores';
UPDATE public.cidades SET latitude = -9.6256,  longitude = -37.7567 WHERE nome = 'Piranhas';
UPDATE public.cidades SET latitude = -9.8469,  longitude = -36.9536 WHERE nome = 'Batalha';
UPDATE public.cidades SET latitude = -9.5803,  longitude = -37.0939 WHERE nome = 'Santana do Ipanema';
UPDATE public.cidades SET latitude = -9.5475,  longitude = -36.5567 WHERE nome = 'Limoeiro de Anadia';
UPDATE public.cidades SET latitude = -9.6700,  longitude = -36.1561 WHERE nome = 'Anadia';
UPDATE public.cidades SET latitude = -9.8497,  longitude = -37.2261 WHERE nome = 'Ouro Branco';
UPDATE public.cidades SET latitude = -9.7281,  longitude = -36.1356 WHERE nome = 'Campo Alegre';
UPDATE public.cidades SET latitude = -9.6722,  longitude = -35.8606 WHERE nome = 'Rio Largo';
UPDATE public.cidades SET latitude = -9.6067,  longitude = -36.0578 WHERE nome = 'São Miguel dos Campos';
UPDATE public.cidades SET latitude = -9.7114,  longitude = -36.8242 WHERE nome = 'Major Isidoro';
UPDATE public.cidades SET latitude = -9.7000,  longitude = -35.7800 WHERE nome = 'Coruripe';

-- ----------------------------------------------------------------
-- 4. Coordenadas — Cidades intermediárias nos itinerários (paradas_rota)
--    Essas são as cidades que PRECISAM de coordenadas para o mapa funcionar.
-- ----------------------------------------------------------------

-- Corredor AL-220 / Sertão → Litoral
UPDATE public.cidades SET latitude = -9.5172,  longitude = -37.5744 WHERE nome = 'Olho d''Água do Casado';
UPDATE public.cidades SET latitude = -9.5139,  longitude = -37.2728 WHERE nome = 'São José da Tapera';
UPDATE public.cidades SET latitude = -9.6292,  longitude = -36.9817 WHERE nome = 'Jacaré dos Homens';
UPDATE public.cidades SET latitude = -9.7144,  longitude = -37.0097 WHERE nome = 'Jaramataia';
UPDATE public.cidades SET latitude = -9.6975,  longitude = -37.1583 WHERE nome = 'Monteirópolis';
UPDATE public.cidades SET latitude = -9.7453,  longitude = -36.4897 WHERE nome = 'Taquarana';
UPDATE public.cidades SET latitude = -9.7508,  longitude = -36.3111 WHERE nome = 'Maribondo';
UPDATE public.cidades SET latitude = -9.5286,  longitude = -37.0136 WHERE nome = 'Cacimbinhas';

-- Corredor norte (Batalha → Arapiraca)
UPDATE public.cidades SET latitude = -9.7719,  longitude = -36.4678 WHERE nome = 'São Sebastião';

-- Lagoa das Pedras — comunidade rural entre Água Branca e Delmiro Gouveia
-- (coordenada aproximada ao longo da AL-165)
UPDATE public.cidades SET latitude = -9.3200,  longitude = -37.9700 WHERE nome = 'Lagoa das Pedras';

-- ----------------------------------------------------------------
-- 5. Coordenadas — Localidades rurais (pontos de parada menores)
--    Coordenadas aproximadas baseadas na posição geográfica conhecida.
-- ----------------------------------------------------------------

-- Limoeiro de Anadia → Arapiraca (corredor da AL-220)
UPDATE public.cidades SET latitude = -9.6400,  longitude = -36.5900 WHERE nome = 'Pé Leve';
UPDATE public.cidades SET latitude = -9.6700,  longitude = -36.6100 WHERE nome = 'Bom Jardim';

-- Coruripe → Arapiraca (via Bonsucesso)
UPDATE public.cidades SET latitude = -9.7050,  longitude = -35.9250 WHERE nome = 'Bonsucesso';
UPDATE public.cidades SET latitude = -9.7100,  longitude = -36.0300 WHERE nome = 'Santa Terezinha';
UPDATE public.cidades SET latitude = -9.7200,  longitude = -36.1100 WHERE nome = 'Botafogo';
UPDATE public.cidades SET latitude = -9.7300,  longitude = -36.2500 WHERE nome = 'Pindorama';

-- Santa Cruz do Deserto → Maceió (via Arapiraca)
UPDATE public.cidades SET latitude = -9.7550,  longitude = -36.6800 WHERE nome = 'Santa Cruz do Deserto';

-- Papa Farinha — localidade entre Limoeiro de Anadia e Arapiraca
UPDATE public.cidades SET latitude = -9.6950,  longitude = -36.6200 WHERE nome = 'Papa Farinha';

COMMIT;

-- ----------------------------------------------------------------
-- Verificação: cidades dos itinerários ainda sem coordenadas
-- Resultado esperado após execução: lista vazia ou apenas cidades
-- que foram removidas pela migração 013 (sem rotas ativas).
-- ----------------------------------------------------------------
SELECT nome, estado
FROM public.cidades
WHERE latitude IS NULL
ORDER BY nome;
