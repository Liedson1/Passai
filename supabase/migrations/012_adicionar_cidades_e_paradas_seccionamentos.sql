-- ============================================================
-- Passaí — Adicionar Cidades e Paradas de Seccionamento
-- Migração: 012_adicionar_cidades_e_paradas_seccionamentos.sql
-- ============================================================
-- Contexto:
-- No quadro de horários oficial (quadro_horarios_arapiraca_sertao_estrito.json),
-- os campos de seccionamento contêm os itinerários reais percorridos pelas vans,
-- indicando as cidades e localidades intermediárias onde ocorrem embarques/desembarques.
--
-- Esta migração:
-- 1. Cadastra na tabela `cidades` todos os municípios e localidades
--    intermediárias citadas nos seccionamentos que ainda não existiam no banco.
-- 2. Popula e atualiza na tabela `paradas_rota` os itinerários ordenados
--    (sentidos IDA e VOLTA) para cada uma das rotas seccionadas, garantindo
--    que a tela de detalhes exiba as cidades na sequência geográfica correta.
-- ============================================================

BEGIN;

-- -------------------------------------------------------------
-- 1. Inserir Cidades e Localidades dos Seccionamentos em `cidades`
-- -------------------------------------------------------------
INSERT INTO public.cidades (nome, estado) VALUES
  ('Anadia', 'AL'),
  ('Batalha', 'AL'),
  ('Bom Jardim', 'AL'),
  ('Bonsucesso', 'AL'),
  ('Botafogo', 'AL'),
  ('Cacimbinhas', 'AL'),
  ('Coruripe', 'AL'),
  ('Jacaré dos Homens', 'AL'),
  ('Jaramataia', 'AL'),
  ('Lagoa das Pedras', 'AL'),
  ('Maribondo', 'AL'),
  ('Monteirópolis', 'AL'),
  ('Olho d''Água do Casado', 'AL'),
  ('Papa Farinha', 'AL'),
  ('Pé Leve', 'AL'),
  ('Pindorama', 'AL'),
  ('Piranhas', 'AL'),
  ('Santa Terezinha', 'AL'),
  ('Taquarana', 'AL')
ON CONFLICT (nome) DO UPDATE SET estado = EXCLUDED.estado;

-- Sincronizar sequence de IDs da tabela cidades
SELECT setval('public.cidades_id_seq', (SELECT COALESCE(MAX(id), 1) FROM public.cidades));

-- -------------------------------------------------------------
-- 2. Garantir estrutura da tabela `paradas_rota`
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.paradas_rota (
  id        SERIAL PRIMARY KEY,
  rota_id   INTEGER NOT NULL REFERENCES public.rotas (id) ON DELETE CASCADE,
  sentido   TEXT NOT NULL CHECK (sentido IN ('IDA', 'VOLTA')),
  ordem     INTEGER NOT NULL,
  cidade    TEXT NOT NULL,
  descricao TEXT
);

CREATE INDEX IF NOT EXISTS idx_paradas_rota_lookup
  ON public.paradas_rota (rota_id, sentido, ordem);

ALTER TABLE public.paradas_rota ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "leitura_publica_paradas_rota" ON public.paradas_rota;
CREATE POLICY "leitura_publica_paradas_rota"
  ON public.paradas_rota FOR SELECT USING (true);

-- -------------------------------------------------------------
-- 3. Atualizar Paradas / Itinerários das Rotas Seccionadas
-- -------------------------------------------------------------

-- --------------------------------------------------------
-- [3.1] Olho d'Água das Flores - Arapiraca (Rota 54)
-- Seccionamento: Jacaré dos Homens, Jaramataia (Corredor AL-220)
-- --------------------------------------------------------
DELETE FROM public.paradas_rota
WHERE rota_id IN (SELECT id FROM public.rotas WHERE linha ILIKE '%Olho d''Água das Flores%Arapiraca%');

INSERT INTO public.paradas_rota (rota_id, sentido, ordem, cidade, descricao)
SELECT r.id, p.sentido, p.ordem, p.cidade, p.descricao
FROM public.rotas r
CROSS JOIN (VALUES
  ('IDA',   1, 'Olho d''Água das Flores', 'Terminal / Ponto de partida'),
  ('IDA',   2, 'Jacaré dos Homens',       'Parada intermediária / Centro'),
  ('IDA',   3, 'Jaramataia',              'Parada intermediária / AL-220'),
  ('IDA',   4, 'Arapiraca',               'Terminal Rodoviário / Chegada'),
  ('VOLTA', 1, 'Arapiraca',               'Terminal Rodoviário / Ponto de partida'),
  ('VOLTA', 2, 'Jaramataia',              'Parada intermediária / AL-220'),
  ('VOLTA', 3, 'Jacaré dos Homens',       'Parada intermediária / Centro'),
  ('VOLTA', 4, 'Olho d''Água das Flores', 'Terminal / Chegada')
) AS p(sentido, ordem, cidade, descricao)
WHERE r.linha ILIKE '%Olho d''Água das Flores%Arapiraca%';

-- --------------------------------------------------------
-- [3.2] Água Branca - Maceió (Rota 4)
-- Seccionamento: Olho d'Água do Casado, São José da Tapera, Monteirópolis, Jacaré dos Homens
-- --------------------------------------------------------
DELETE FROM public.paradas_rota
WHERE rota_id IN (SELECT id FROM public.rotas WHERE linha ILIKE '%Água Branca%Maceió%');

INSERT INTO public.paradas_rota (rota_id, sentido, ordem, cidade, descricao)
SELECT r.id, p.sentido, p.ordem, p.cidade, p.descricao
FROM public.rotas r
CROSS JOIN (VALUES
  ('IDA',   1, 'Água Branca',            'Terminal Rodoviário'),
  ('IDA',   2, 'Olho d''Água do Casado', 'Parada intermediária / Saída às 14:30'),
  ('IDA',   3, 'São José da Tapera',     'Praça Central'),
  ('IDA',   4, 'Monteirópolis',          'Corredor da AL-220'),
  ('IDA',   5, 'Jacaré dos Homens',      'Corredor da AL-220'),
  ('IDA',   6, 'Maceió',                 'Terminal Rodoviário'),
  ('VOLTA', 1, 'Maceió',                 'Terminal Rodoviário'),
  ('VOLTA', 2, 'Jacaré dos Homens',      'Corredor da AL-220'),
  ('VOLTA', 3, 'Monteirópolis',          'Corredor da AL-220'),
  ('VOLTA', 4, 'São José da Tapera',     'Praça Central'),
  ('VOLTA', 5, 'Olho d''Água do Casado', 'Parada intermediária'),
  ('VOLTA', 6, 'Água Branca',            'Terminal Rodoviário')
) AS p(sentido, ordem, cidade, descricao)
WHERE r.linha ILIKE '%Água Branca%Maceió%';

-- --------------------------------------------------------
-- [3.3] Delmiro Gouveia - Maceió (via TAQUARANA) (Rota 27)
-- Seccionamento: Olho d'Água do Casado, São José da Tapera, Olho d'Água das Flores, Jacaré dos Homens, Taquarana, Maribondo
-- --------------------------------------------------------
DELETE FROM public.paradas_rota
WHERE rota_id IN (SELECT id FROM public.rotas WHERE linha ILIKE '%Delmiro Gouveia%Maceió%TAQUARANA%');

INSERT INTO public.paradas_rota (rota_id, sentido, ordem, cidade, descricao)
SELECT r.id, p.sentido, p.ordem, p.cidade, p.descricao
FROM public.rotas r
CROSS JOIN (VALUES
  ('IDA',   1, 'Delmiro Gouveia',         'Terminal Rodoviário'),
  ('IDA',   2, 'Olho d''Água do Casado',  'Parada intermediária / Saída às 16:00'),
  ('IDA',   3, 'São José da Tapera',      'Praça Central'),
  ('IDA',   4, 'Olho d''Água das Flores', 'Corredor da AL-220'),
  ('IDA',   5, 'Jacaré dos Homens',       'Corredor da AL-220'),
  ('IDA',   6, 'Taquarana',               'Centro / Parada intermediária'),
  ('IDA',   7, 'Maribondo',               'Corredor da BR-316'),
  ('IDA',   8, 'Maceió',                  'Terminal Rodoviário'),
  ('VOLTA', 1, 'Maceió',                  'Terminal Rodoviário'),
  ('VOLTA', 2, 'Maribondo',               'Corredor da BR-316'),
  ('VOLTA', 3, 'Taquarana',               'Centro / Parada intermediária'),
  ('VOLTA', 4, 'Jacaré dos Homens',       'Corredor da AL-220'),
  ('VOLTA', 5, 'Olho d''Água das Flores', 'Corredor da AL-220'),
  ('VOLTA', 6, 'São José da Tapera',      'Praça Central'),
  ('VOLTA', 7, 'Olho d''Água do Casado',  'Parada intermediária'),
  ('VOLTA', 8, 'Delmiro Gouveia',         'Terminal Rodoviário')
) AS p(sentido, ordem, cidade, descricao)
WHERE r.linha ILIKE '%Delmiro Gouveia%Maceió%TAQUARANA%';

-- --------------------------------------------------------
-- [3.4] Delmiro Gouveia - Maceió (direto) (Rota 28)
-- Seccionamento: São José da Tapera (Praça Central)
-- --------------------------------------------------------
DELETE FROM public.paradas_rota
WHERE rota_id IN (
  SELECT id FROM public.rotas
  WHERE linha ILIKE '%Delmiro Gouveia%Maceió%'
    AND linha NOT ILIKE '%TAQUARANA%'
);

INSERT INTO public.paradas_rota (rota_id, sentido, ordem, cidade, descricao)
SELECT r.id, p.sentido, p.ordem, p.cidade, p.descricao
FROM public.rotas r
CROSS JOIN (VALUES
  ('IDA',   1, 'Delmiro Gouveia',   'Terminal Rodoviário'),
  ('IDA',   2, 'São José da Tapera','Praça Central'),
  ('IDA',   3, 'Maceió',            'Terminal Rodoviário'),
  ('VOLTA', 1, 'Maceió',            'Terminal Rodoviário'),
  ('VOLTA', 2, 'São José da Tapera','Praça Central'),
  ('VOLTA', 3, 'Delmiro Gouveia',   'Terminal Rodoviário')
) AS p(sentido, ordem, cidade, descricao)
WHERE r.linha ILIKE '%Delmiro Gouveia%Maceió%'
  AND r.linha NOT ILIKE '%TAQUARANA%';

-- --------------------------------------------------------
-- [3.5] Limoeiro de Anadia - Arapiraca (Rota 43)
-- Seccionamento: Centro de Anadia, Pé Leve, Bom Jardim, Papa Farinha
-- --------------------------------------------------------
DELETE FROM public.paradas_rota
WHERE rota_id IN (SELECT id FROM public.rotas WHERE linha ILIKE '%Limoeiro de Anadia%Arapiraca%');

INSERT INTO public.paradas_rota (rota_id, sentido, ordem, cidade, descricao)
SELECT r.id, p.sentido, p.ordem, p.cidade, p.descricao
FROM public.rotas r
CROSS JOIN (VALUES
  ('IDA',   1, 'Limoeiro de Anadia', 'Ponto de partida / Centro'),
  ('IDA',   2, 'Anadia',             'Centro de Anadia'),
  ('IDA',   3, 'Pé Leve',            'Parada intermediária'),
  ('IDA',   4, 'Bom Jardim',         'Parada intermediária'),
  ('IDA',   5, 'Arapiraca',          'Terminal Rodoviário'),
  ('VOLTA', 1, 'Arapiraca',          'Terminal Rodoviário'),
  ('VOLTA', 2, 'Bom Jardim',         'Parada intermediária'),
  ('VOLTA', 3, 'Pé Leve',            'Parada intermediária'),
  ('VOLTA', 4, 'Anadia',             'Centro de Anadia'),
  ('VOLTA', 5, 'Limoeiro de Anadia', 'Ponto de chegada / Centro')
) AS p(sentido, ordem, cidade, descricao)
WHERE r.linha ILIKE '%Limoeiro de Anadia%Arapiraca%';

-- --------------------------------------------------------
-- [3.6] Santana do Ipanema - Maceió (Rota 87)
-- Seccionamento: Cacimbinhas
-- --------------------------------------------------------
DELETE FROM public.paradas_rota
WHERE rota_id IN (SELECT id FROM public.rotas WHERE linha ILIKE '%Santana do Ipanema%Maceió%');

INSERT INTO public.paradas_rota (rota_id, sentido, ordem, cidade, descricao)
SELECT r.id, p.sentido, p.ordem, p.cidade, p.descricao
FROM public.rotas r
CROSS JOIN (VALUES
  ('IDA',   1, 'Santana do Ipanema', 'Terminal Rodoviário'),
  ('IDA',   2, 'Cacimbinhas',        'Parada intermediária / Centro'),
  ('IDA',   3, 'Maceió',             'Terminal Rodoviário'),
  ('VOLTA', 1, 'Maceió',             'Terminal Rodoviário'),
  ('VOLTA', 2, 'Cacimbinhas',        'Parada intermediária / Centro'),
  ('VOLTA', 3, 'Santana do Ipanema', 'Terminal Rodoviário')
) AS p(sentido, ordem, cidade, descricao)
WHERE r.linha ILIKE '%Santana do Ipanema%Maceió%';

-- --------------------------------------------------------
-- [3.7] Arapiraca - Maceió (via TAQUARANA) (Rota 7)
-- Itinerário: via Taquarana
-- --------------------------------------------------------
DELETE FROM public.paradas_rota
WHERE rota_id IN (SELECT id FROM public.rotas WHERE linha ILIKE '%Arapiraca%Maceió%TAQUARANA%');

INSERT INTO public.paradas_rota (rota_id, sentido, ordem, cidade, descricao)
SELECT r.id, p.sentido, p.ordem, p.cidade, p.descricao
FROM public.rotas r
CROSS JOIN (VALUES
  ('IDA',   1, 'Arapiraca', 'Terminal Rodoviário'),
  ('IDA',   2, 'Taquarana', 'Centro / Parada intermediária'),
  ('IDA',   3, 'Maceió',    'Terminal Rodoviário'),
  ('VOLTA', 1, 'Maceió',    'Terminal Rodoviário'),
  ('VOLTA', 2, 'Taquarana', 'Centro / Parada intermediária'),
  ('VOLTA', 3, 'Arapiraca', 'Terminal Rodoviário')
) AS p(sentido, ordem, cidade, descricao)
WHERE r.linha ILIKE '%Arapiraca%Maceió%TAQUARANA%';

-- --------------------------------------------------------
-- [3.8] Santa Cruz do Deserto - Maceió (via ARAPIRACA) (Rota 85)
-- Itinerário: via Arapiraca
-- --------------------------------------------------------
DELETE FROM public.paradas_rota
WHERE rota_id IN (SELECT id FROM public.rotas WHERE linha ILIKE '%Santa Cruz do Deserto%Maceió%ARAPIRACA%');

INSERT INTO public.paradas_rota (rota_id, sentido, ordem, cidade, descricao)
SELECT r.id, p.sentido, p.ordem, p.cidade, p.descricao
FROM public.rotas r
CROSS JOIN (VALUES
  ('IDA',   1, 'Santa Cruz do Deserto', 'Ponto de partida'),
  ('IDA',   2, 'Arapiraca',             'Terminal Rodoviário'),
  ('IDA',   3, 'Maceió',                'Terminal Rodoviário'),
  ('VOLTA', 1, 'Maceió',                'Terminal Rodoviário'),
  ('VOLTA', 2, 'Arapiraca',             'Terminal Rodoviário'),
  ('VOLTA', 3, 'Santa Cruz do Deserto', 'Ponto de chegada')
) AS p(sentido, ordem, cidade, descricao)
WHERE r.linha ILIKE '%Santa Cruz do Deserto%Maceió%ARAPIRACA%';

-- --------------------------------------------------------
-- [3.9] Batalha - Arapiraca (caso exista na tabela rotas)
-- Seccionamento: Jaramataia
-- --------------------------------------------------------
DELETE FROM public.paradas_rota
WHERE rota_id IN (SELECT id FROM public.rotas WHERE linha ILIKE '%Batalha%Arapiraca%');

INSERT INTO public.paradas_rota (rota_id, sentido, ordem, cidade, descricao)
SELECT r.id, p.sentido, p.ordem, p.cidade, p.descricao
FROM public.rotas r
CROSS JOIN (VALUES
  ('IDA',   1, 'Batalha',    'Terminal Rodoviário'),
  ('IDA',   2, 'Jaramataia', 'Parada intermediária / Centro'),
  ('IDA',   3, 'Arapiraca',  'Terminal Rodoviário'),
  ('VOLTA', 1, 'Arapiraca',  'Terminal Rodoviário'),
  ('VOLTA', 2, 'Jaramataia', 'Parada intermediária / Centro'),
  ('VOLTA', 3, 'Batalha',    'Terminal Rodoviário')
) AS p(sentido, ordem, cidade, descricao)
WHERE r.linha ILIKE '%Batalha%Arapiraca%';

-- --------------------------------------------------------
-- [3.10] Coruripe - Arapiraca (via BONSUCESSO) (caso exista na tabela rotas)
-- Seccionamento: Bonsucesso, Santa Terezinha, Botafogo, Pindorama
-- --------------------------------------------------------
DELETE FROM public.paradas_rota
WHERE rota_id IN (SELECT id FROM public.rotas WHERE linha ILIKE '%Coruripe%Arapiraca%BONSUCESSO%');

INSERT INTO public.paradas_rota (rota_id, sentido, ordem, cidade, descricao)
SELECT r.id, p.sentido, p.ordem, p.cidade, p.descricao
FROM public.rotas r
CROSS JOIN (VALUES
  ('IDA',   1, 'Coruripe',        'Terminal / Ponto de partida'),
  ('IDA',   2, 'Bonsucesso',      'Parada intermediária'),
  ('IDA',   3, 'Santa Terezinha', 'Parada intermediária'),
  ('IDA',   4, 'Botafogo',        'Parada intermediária'),
  ('IDA',   5, 'Pindorama',       'Parada intermediária'),
  ('IDA',   6, 'Arapiraca',       'Terminal Rodoviário'),
  ('VOLTA', 1, 'Arapiraca',       'Terminal Rodoviário'),
  ('VOLTA', 2, 'Pindorama',       'Parada intermediária'),
  ('VOLTA', 3, 'Botafogo',        'Parada intermediária'),
  ('VOLTA', 4, 'Santa Terezinha', 'Parada intermediária'),
  ('VOLTA', 5, 'Bonsucesso',      'Parada intermediária'),
  ('VOLTA', 6, 'Coruripe',        'Terminal / Chegada')
) AS p(sentido, ordem, cidade, descricao)
WHERE r.linha ILIKE '%Coruripe%Arapiraca%BONSUCESSO%';

-- --------------------------------------------------------
-- [3.11] Piranhas - Delmiro Gouveia (caso exista na tabela rotas)
-- Seccionamento: Olho d'Água do Casado
-- --------------------------------------------------------
DELETE FROM public.paradas_rota
WHERE rota_id IN (SELECT id FROM public.rotas WHERE linha ILIKE '%Piranhas%Delmiro Gouveia%');

INSERT INTO public.paradas_rota (rota_id, sentido, ordem, cidade, descricao)
SELECT r.id, p.sentido, p.ordem, p.cidade, p.descricao
FROM public.rotas r
CROSS JOIN (VALUES
  ('IDA',   1, 'Piranhas',               'Centro Histórico'),
  ('IDA',   2, 'Olho d''Água do Casado', 'Parada intermediária'),
  ('IDA',   3, 'Delmiro Gouveia',        'Terminal Rodoviário'),
  ('VOLTA', 1, 'Delmiro Gouveia',        'Terminal Rodoviário'),
  ('VOLTA', 2, 'Olho d''Água do Casado', 'Parada intermediária'),
  ('VOLTA', 3, 'Piranhas',               'Centro Histórico')
) AS p(sentido, ordem, cidade, descricao)
WHERE r.linha ILIKE '%Piranhas%Delmiro Gouveia%';

-- --------------------------------------------------------
-- [3.12] Piranhas - Maceió (caso exista na tabela rotas)
-- Seccionamento: São José da Tapera (Praça Central)
-- --------------------------------------------------------
DELETE FROM public.paradas_rota
WHERE rota_id IN (SELECT id FROM public.rotas WHERE linha ILIKE '%Piranhas%Maceió%');

INSERT INTO public.paradas_rota (rota_id, sentido, ordem, cidade, descricao)
SELECT r.id, p.sentido, p.ordem, p.cidade, p.descricao
FROM public.rotas r
CROSS JOIN (VALUES
  ('IDA',   1, 'Piranhas',           'Centro Histórico'),
  ('IDA',   2, 'São José da Tapera', 'Praça Central'),
  ('IDA',   3, 'Maceió',             'Terminal Rodoviário'),
  ('VOLTA', 1, 'Maceió',             'Terminal Rodoviário'),
  ('VOLTA', 2, 'São José da Tapera', 'Praça Central'),
  ('VOLTA', 3, 'Piranhas',           'Centro Histórico')
) AS p(sentido, ordem, cidade, descricao)
WHERE r.linha ILIKE '%Piranhas%Maceió%';

-- --------------------------------------------------------
-- [3.13] Água Branca - Delmiro Gouveia (via LAGOA DAS PEDRAS) (caso exista na tabela rotas)
-- Seccionamento: Lagoa das Pedras
-- --------------------------------------------------------
DELETE FROM public.paradas_rota
WHERE rota_id IN (SELECT id FROM public.rotas WHERE linha ILIKE '%Água Branca%Delmiro Gouveia%LAGOA DAS PEDRAS%');

INSERT INTO public.paradas_rota (rota_id, sentido, ordem, cidade, descricao)
SELECT r.id, p.sentido, p.ordem, p.cidade, p.descricao
FROM public.rotas r
CROSS JOIN (VALUES
  ('IDA',   1, 'Água Branca',      'Terminal / Ponto de partida'),
  ('IDA',   2, 'Lagoa das Pedras', 'Parada intermediária'),
  ('IDA',   3, 'Delmiro Gouveia',  'Terminal / Chegada'),
  ('VOLTA', 1, 'Delmiro Gouveia',  'Terminal / Ponto de partida'),
  ('VOLTA', 2, 'Lagoa das Pedras', 'Parada intermediária'),
  ('VOLTA', 3, 'Água Branca',      'Terminal / Chegada')
) AS p(sentido, ordem, cidade, descricao)
WHERE r.linha ILIKE '%Água Branca%Delmiro Gouveia%LAGOA DAS PEDRAS%';

COMMIT;

-- ============================================================
-- Verificação de Conferência:
-- ============================================================
SELECT 
    (SELECT count(*) FROM public.cidades) AS total_cidades,
    (SELECT count(*) FROM public.paradas_rota) AS total_paradas,
    (SELECT count(DISTINCT rota_id) FROM public.paradas_rota) AS rotas_com_paradas;
