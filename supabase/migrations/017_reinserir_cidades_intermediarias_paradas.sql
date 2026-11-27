-- ============================================================
-- Passaí — Reinserção de Cidades Intermediárias no Mapa
-- Migração: 017_reinserir_cidades_intermediarias_paradas.sql
-- ============================================================
-- Contexto (causa raiz identificada):
-- A migração 013 removeu da tabela `cidades` todos os registros
-- que não são origem ou destino de rotas ativas. Porém, cidades
-- como Jaramataia, Jacaré dos Homens, Taquarana etc. são paradas
-- INTERMEDIÁRIAS reais dos itinerários (paradas_rota), não pontas
-- de linha — e por isso foram deletadas indevidamente para o mapa.
--
-- Esta migração:
--   1. Reinsere as cidades intermediárias ausentes em `cidades`.
--   2. Atribui suas coordenadas geográficas.
--   3. Re-popula paradas_rota.cidade_id para os registros com null.
--
-- Impacto na busca do usuário: NENHUM.
-- As cidades reinseridas não aparecem no campo de busca origem/destino
-- pois a query de busca filtra apenas cidades com rotas ativas vinculadas
-- (fetchCidades → fetchTodasAsRotas). Elas serão usadas exclusivamente
-- pelo mapa do itinerário.
-- ============================================================

BEGIN;

-- ----------------------------------------------------------------
-- 1. Reinserir cidades intermediárias removidas pela migração 013
--    ON CONFLICT DO NOTHING: seguro para reexecução
-- ----------------------------------------------------------------
INSERT INTO public.cidades (nome, estado) VALUES
  ('Jacaré dos Homens',       'AL'),
  ('Jaramataia',              'AL'),
  ('Lagoa das Pedras',        'AL'),
  ('Maribondo',               'AL'),
  ('Olho d''Água do Casado',  'AL'),
  ('Taquarana',               'AL'),
  ('Cacimbinhas',             'AL'),
  ('São José da Tapera',      'AL'),
  ('Monteirópolis',           'AL'),
  ('Pé Leve',                 'AL'),
  ('Bom Jardim',              'AL'),
  ('Bonsucesso',              'AL'),
  ('Santa Terezinha',         'AL'),
  ('Botafogo',                'AL'),
  ('Pindorama',               'AL'),
  ('Santa Cruz do Deserto',   'AL'),
  ('Papa Farinha',            'AL')
ON CONFLICT (nome) DO NOTHING;

-- ----------------------------------------------------------------
-- 2. Atribuir coordenadas às cidades reinseridas
--    (idempotente: só atualiza quando latitude ainda estiver nula)
-- ----------------------------------------------------------------
UPDATE public.cidades SET latitude = -9.6292, longitude = -36.9817
  WHERE nome = 'Jacaré dos Homens'  AND latitude IS NULL;

UPDATE public.cidades SET latitude = -9.7144, longitude = -37.0097
  WHERE nome = 'Jaramataia'         AND latitude IS NULL;

UPDATE public.cidades SET latitude = -9.3200, longitude = -37.9700
  WHERE nome = 'Lagoa das Pedras'   AND latitude IS NULL;

UPDATE public.cidades SET latitude = -9.7508, longitude = -36.3111
  WHERE nome = 'Maribondo'          AND latitude IS NULL;

UPDATE public.cidades SET latitude = -9.5172, longitude = -37.5744
  WHERE nome = 'Olho d''Água do Casado' AND latitude IS NULL;

UPDATE public.cidades SET latitude = -9.7453, longitude = -36.4897
  WHERE nome = 'Taquarana'          AND latitude IS NULL;

UPDATE public.cidades SET latitude = -9.5286, longitude = -37.0136
  WHERE nome = 'Cacimbinhas'        AND latitude IS NULL;

UPDATE public.cidades SET latitude = -9.5139, longitude = -37.2728
  WHERE nome = 'São José da Tapera' AND latitude IS NULL;

UPDATE public.cidades SET latitude = -9.6975, longitude = -37.1583
  WHERE nome = 'Monteirópolis'      AND latitude IS NULL;

UPDATE public.cidades SET latitude = -9.6400, longitude = -36.5900
  WHERE nome = 'Pé Leve'            AND latitude IS NULL;

UPDATE public.cidades SET latitude = -9.6700, longitude = -36.6100
  WHERE nome = 'Bom Jardim'         AND latitude IS NULL;

UPDATE public.cidades SET latitude = -9.7050, longitude = -35.9250
  WHERE nome = 'Bonsucesso'         AND latitude IS NULL;

UPDATE public.cidades SET latitude = -9.7100, longitude = -36.0300
  WHERE nome = 'Santa Terezinha'    AND latitude IS NULL;

UPDATE public.cidades SET latitude = -9.7200, longitude = -36.1100
  WHERE nome = 'Botafogo'           AND latitude IS NULL;

UPDATE public.cidades SET latitude = -9.7300, longitude = -36.2500
  WHERE nome = 'Pindorama'          AND latitude IS NULL;

UPDATE public.cidades SET latitude = -9.7550, longitude = -36.6800
  WHERE nome = 'Santa Cruz do Deserto' AND latitude IS NULL;

UPDATE public.cidades SET latitude = -9.6950, longitude = -36.6200
  WHERE nome = 'Papa Farinha'       AND latitude IS NULL;

-- ----------------------------------------------------------------
-- 3. Re-popular cidade_id em paradas_rota para registros com null
--    (re-executa o mesmo UPDATE da migração 015)
-- ----------------------------------------------------------------
UPDATE public.paradas_rota pr
SET cidade_id = c.id
FROM public.cidades c
WHERE LOWER(TRIM(pr.cidade)) = LOWER(TRIM(c.nome))
  AND pr.cidade_id IS NULL;

COMMIT;

-- ----------------------------------------------------------------
-- Verificação: paradas_rota ainda sem cidade_id após esta migração
-- Resultado esperado: zero linhas (ou apenas localidades rurais
-- sem equivalente na tabela cidades)
-- ----------------------------------------------------------------
SELECT DISTINCT pr.cidade
FROM public.paradas_rota pr
WHERE pr.cidade_id IS NULL
ORDER BY pr.cidade;
