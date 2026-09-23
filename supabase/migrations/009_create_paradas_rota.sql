-- ============================================================
-- Passaí — Tabela de Paradas do Itinerário por Rota
-- Migração: 009_create_paradas_rota.sql
-- ============================================================
-- Contexto: O banco não possuía dados estruturados de paradas intermediárias.
-- Os seccionamentos existiam apenas como texto livre no campo rotas.seccionamentos.
-- Esta migration cria a tabela e popula os itinerários conhecidos das rotas
-- com seccionamentos documentados nas migrações anteriores.
--
-- IMPORTANTE: O seed usa subqueries pelo nome da linha (campo `linha` em `rotas`)
-- para evitar dependência de IDs hardcoded, garantindo idempotência em qualquer
-- ambiente (local, staging, produção).
-- ============================================================

BEGIN;

-- -------------------------------------------------------------
-- TABELA: paradas_rota
-- Representa cada parada do itinerário de uma rota/sentido.
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS paradas_rota (
  id        SERIAL PRIMARY KEY,
  rota_id   INTEGER NOT NULL REFERENCES rotas (id) ON DELETE CASCADE,
  sentido   TEXT NOT NULL CHECK (sentido IN ('IDA', 'VOLTA')),
  ordem     INTEGER NOT NULL,       -- posição sequencial na rota (1 = partida)
  cidade    TEXT NOT NULL,          -- nome da cidade/parada
  descricao TEXT                    -- ponto de referência (ex: "Praça Central")
);

CREATE INDEX IF NOT EXISTS idx_paradas_rota_lookup
  ON paradas_rota (rota_id, sentido, ordem);

-- RLS: leitura pública (RN01)
ALTER TABLE paradas_rota ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "leitura_publica_paradas_rota" ON paradas_rota;
CREATE POLICY "leitura_publica_paradas_rota"
  ON paradas_rota FOR SELECT USING (true);

-- -------------------------------------------------------------
-- SEED: Itinerários das rotas com seccionamentos documentados
-- Usa subqueries pelo nome exato da coluna `linha` em `rotas`
-- para funcionar independentemente dos IDs no banco.
-- Linhas que não existirem no banco são ignoradas silenciosamente
-- (INSERT ... WHERE EXISTS).
-- -------------------------------------------------------------

-- Limpa dados anteriores para reinserção idempotente
TRUNCATE TABLE paradas_rota RESTART IDENTITY;

-- --------------------------------------------------------
-- Água Branca - Delmiro Gouveia (via LAGOA DAS PEDRAS)
-- --------------------------------------------------------
INSERT INTO paradas_rota (rota_id, sentido, ordem, cidade, descricao)
SELECT r.id, p.sentido, p.ordem, p.cidade, p.descricao
FROM rotas r
CROSS JOIN (VALUES
  ('IDA',   1, 'Água Branca',     'Terminal / Ponto de partida'),
  ('IDA',   2, 'Lagoa das Pedras','Parada intermediária'),
  ('IDA',   3, 'Delmiro Gouveia', 'Terminal / Chegada'),
  ('VOLTA', 1, 'Delmiro Gouveia', 'Terminal / Ponto de partida'),
  ('VOLTA', 2, 'Lagoa das Pedras','Parada intermediária'),
  ('VOLTA', 3, 'Água Branca',     'Terminal / Chegada')
) AS p(sentido, ordem, cidade, descricao)
WHERE r.linha ILIKE '%Água Branca%Delmiro Gouveia%LAGOA DAS PEDRAS%';

-- --------------------------------------------------------
-- Água Branca - Delmiro Gouveia (direto, sem via)
-- --------------------------------------------------------
INSERT INTO paradas_rota (rota_id, sentido, ordem, cidade, descricao)
SELECT r.id, p.sentido, p.ordem, p.cidade, p.descricao
FROM rotas r
CROSS JOIN (VALUES
  ('IDA',   1, 'Água Branca',     'Rodoviária'),
  ('IDA',   2, 'Delmiro Gouveia', 'Rodoviária'),
  ('VOLTA', 1, 'Delmiro Gouveia', 'Rodoviária'),
  ('VOLTA', 2, 'Água Branca',     'Rodoviária')
) AS p(sentido, ordem, cidade, descricao)
WHERE r.linha ILIKE '%Água Branca%Delmiro Gouveia%'
  AND r.linha NOT ILIKE '%LAGOA%';

-- --------------------------------------------------------
-- Água Branca - Maceió
-- via Jacaré dos Homens, São José da Tapera, Olho d'Água do Casado
-- --------------------------------------------------------
INSERT INTO paradas_rota (rota_id, sentido, ordem, cidade, descricao)
SELECT r.id, p.sentido, p.ordem, p.cidade, p.descricao
FROM rotas r
CROSS JOIN (VALUES
  ('IDA',   1, 'Água Branca',            'Rodoviária'),
  ('IDA',   2, 'Olho d''Água do Casado', 'Praça Central'),
  ('IDA',   3, 'São José da Tapera',     'Praça Central'),
  ('IDA',   4, 'Jacaré dos Homens',      'Parada intermediária'),
  ('IDA',   5, 'Maceió',                 'Rodoviária'),
  ('VOLTA', 1, 'Maceió',                 'Rodoviária'),
  ('VOLTA', 2, 'Jacaré dos Homens',      'Parada intermediária'),
  ('VOLTA', 3, 'São José da Tapera',     'Praça Central'),
  ('VOLTA', 4, 'Olho d''Água do Casado', 'Praça Central'),
  ('VOLTA', 5, 'Água Branca',            'Rodoviária')
) AS p(sentido, ordem, cidade, descricao)
WHERE r.linha ILIKE '%Água Branca%Maceió%';

-- --------------------------------------------------------
-- Arapiraca - Maceió (via LITORAL)
-- --------------------------------------------------------
INSERT INTO paradas_rota (rota_id, sentido, ordem, cidade, descricao)
SELECT r.id, p.sentido, p.ordem, p.cidade, p.descricao
FROM rotas r
CROSS JOIN (VALUES
  ('IDA',   1, 'Arapiraca', 'Terminal Rodoviário'),
  ('IDA',   2, 'Maceió',    'Terminal Rodoviário'),
  ('VOLTA', 1, 'Maceió',    'Terminal Rodoviário'),
  ('VOLTA', 2, 'Arapiraca', 'Terminal Rodoviário')
) AS p(sentido, ordem, cidade, descricao)
WHERE r.linha ILIKE '%Arapiraca%Maceió%LITORAL%';

-- --------------------------------------------------------
-- Arapiraca - Maceió (via TAQUARANA)
-- --------------------------------------------------------
INSERT INTO paradas_rota (rota_id, sentido, ordem, cidade, descricao)
SELECT r.id, p.sentido, p.ordem, p.cidade, p.descricao
FROM rotas r
CROSS JOIN (VALUES
  ('IDA',   1, 'Arapiraca', 'Terminal Rodoviário'),
  ('IDA',   2, 'Maceió',    'Terminal Rodoviário'),
  ('VOLTA', 1, 'Maceió',    'Terminal Rodoviário'),
  ('VOLTA', 2, 'Arapiraca', 'Terminal Rodoviário')
) AS p(sentido, ordem, cidade, descricao)
WHERE r.linha ILIKE '%Arapiraca%Maceió%TAQUARANA%';

-- --------------------------------------------------------
-- Delmiro Gouveia - Arapiraca
-- --------------------------------------------------------
INSERT INTO paradas_rota (rota_id, sentido, ordem, cidade, descricao)
SELECT r.id, p.sentido, p.ordem, p.cidade, p.descricao
FROM rotas r
CROSS JOIN (VALUES
  ('IDA',   1, 'Delmiro Gouveia', 'Rodoviária'),
  ('IDA',   2, 'Arapiraca',       'Terminal Rodoviário'),
  ('VOLTA', 1, 'Arapiraca',       'Terminal Rodoviário'),
  ('VOLTA', 2, 'Delmiro Gouveia', 'Rodoviária')
) AS p(sentido, ordem, cidade, descricao)
WHERE r.linha ILIKE '%Delmiro Gouveia%Arapiraca%';

-- --------------------------------------------------------
-- Delmiro Gouveia - Maceió (via TAQUARANA)
-- via São José da Tapera, Olho d'Água das Flores,
--    Jacaré dos Homens, Maribondo, Olho d'Água do Casado
-- --------------------------------------------------------
INSERT INTO paradas_rota (rota_id, sentido, ordem, cidade, descricao)
SELECT r.id, p.sentido, p.ordem, p.cidade, p.descricao
FROM rotas r
CROSS JOIN (VALUES
  ('IDA',   1, 'Delmiro Gouveia',         'Rodoviária'),
  ('IDA',   2, 'Olho d''Água do Casado',  'Saída às 16:00h'),
  ('IDA',   3, 'Jacaré dos Homens',       'Parada intermediária'),
  ('IDA',   4, 'Olho d''Água das Flores', 'Parada intermediária'),
  ('IDA',   5, 'São José da Tapera',      'Praça Central'),
  ('IDA',   6, 'Maribondo',               'Parada intermediária'),
  ('IDA',   7, 'Maceió',                  'Rodoviária'),
  ('VOLTA', 1, 'Maceió',                  'Rodoviária'),
  ('VOLTA', 2, 'Maribondo',               'Parada intermediária'),
  ('VOLTA', 3, 'São José da Tapera',      'Praça Central'),
  ('VOLTA', 4, 'Olho d''Água das Flores', 'Parada intermediária'),
  ('VOLTA', 5, 'Jacaré dos Homens',       'Parada intermediária'),
  ('VOLTA', 6, 'Olho d''Água do Casado',  'Parada intermediária'),
  ('VOLTA', 7, 'Delmiro Gouveia',         'Rodoviária')
) AS p(sentido, ordem, cidade, descricao)
WHERE r.linha ILIKE '%Delmiro Gouveia%Maceió%TAQUARANA%';

-- --------------------------------------------------------
-- Delmiro Gouveia - Maceió (sem via Taquarana)
-- via São José da Tapera
-- --------------------------------------------------------
INSERT INTO paradas_rota (rota_id, sentido, ordem, cidade, descricao)
SELECT r.id, p.sentido, p.ordem, p.cidade, p.descricao
FROM rotas r
CROSS JOIN (VALUES
  ('IDA',   1, 'Delmiro Gouveia',  'Rodoviária'),
  ('IDA',   2, 'São José da Tapera','Praça Central'),
  ('IDA',   3, 'Maceió',            'Rodoviária'),
  ('VOLTA', 1, 'Maceió',            'Rodoviária'),
  ('VOLTA', 2, 'São José da Tapera','Praça Central'),
  ('VOLTA', 3, 'Delmiro Gouveia',  'Rodoviária')
) AS p(sentido, ordem, cidade, descricao)
WHERE r.linha ILIKE '%Delmiro Gouveia%Maceió%'
  AND r.linha NOT ILIKE '%TAQUARANA%';

-- --------------------------------------------------------
-- Limoeiro de Anadia - Arapiraca
-- via Centro de Anadia, Pé Leve, Bom Jardim
-- --------------------------------------------------------
INSERT INTO paradas_rota (rota_id, sentido, ordem, cidade, descricao)
SELECT r.id, p.sentido, p.ordem, p.cidade, p.descricao
FROM rotas r
CROSS JOIN (VALUES
  ('IDA',   1, 'Limoeiro de Anadia','Ponto de partida'),
  ('IDA',   2, 'Anadia',            'Centro'),
  ('IDA',   3, 'Pé Leve',           'Parada intermediária'),
  ('IDA',   4, 'Bom Jardim',        'Parada intermediária'),
  ('IDA',   5, 'Arapiraca',         'Terminal Rodoviário'),
  ('VOLTA', 1, 'Arapiraca',         'Terminal Rodoviário'),
  ('VOLTA', 2, 'Bom Jardim',        'Parada intermediária'),
  ('VOLTA', 3, 'Pé Leve',           'Parada intermediária'),
  ('VOLTA', 4, 'Anadia',            'Centro'),
  ('VOLTA', 5, 'Limoeiro de Anadia','Ponto de chegada')
) AS p(sentido, ordem, cidade, descricao)
WHERE r.linha ILIKE '%Limoeiro de Anadia%Arapiraca%';

-- --------------------------------------------------------
-- Piranhas - Delmiro Gouveia
-- via Olho d'Água do Casado
-- --------------------------------------------------------
INSERT INTO paradas_rota (rota_id, sentido, ordem, cidade, descricao)
SELECT r.id, p.sentido, p.ordem, p.cidade, p.descricao
FROM rotas r
CROSS JOIN (VALUES
  ('IDA',   1, 'Piranhas',               'Centro Histórico'),
  ('IDA',   2, 'Olho d''Água do Casado', 'Parada intermediária'),
  ('IDA',   3, 'Delmiro Gouveia',        'Rodoviária'),
  ('VOLTA', 1, 'Delmiro Gouveia',        'Rodoviária'),
  ('VOLTA', 2, 'Olho d''Água do Casado', 'Parada intermediária'),
  ('VOLTA', 3, 'Piranhas',               'Centro Histórico')
) AS p(sentido, ordem, cidade, descricao)
WHERE r.linha ILIKE '%Piranhas%Delmiro Gouveia%';

-- --------------------------------------------------------
-- Piranhas - Maceió
-- via São José da Tapera
-- --------------------------------------------------------
INSERT INTO paradas_rota (rota_id, sentido, ordem, cidade, descricao)
SELECT r.id, p.sentido, p.ordem, p.cidade, p.descricao
FROM rotas r
CROSS JOIN (VALUES
  ('IDA',   1, 'Piranhas',           'Centro Histórico'),
  ('IDA',   2, 'São José da Tapera', 'Praça Central'),
  ('IDA',   3, 'Maceió',             'Rodoviária'),
  ('VOLTA', 1, 'Maceió',             'Rodoviária'),
  ('VOLTA', 2, 'São José da Tapera', 'Praça Central'),
  ('VOLTA', 3, 'Piranhas',           'Centro Histórico')
) AS p(sentido, ordem, cidade, descricao)
WHERE r.linha ILIKE '%Piranhas%Maceió%';

-- --------------------------------------------------------
-- Santana do Ipanema - Maceió
-- via Cacimbinhas
-- --------------------------------------------------------
INSERT INTO paradas_rota (rota_id, sentido, ordem, cidade, descricao)
SELECT r.id, p.sentido, p.ordem, p.cidade, p.descricao
FROM rotas r
CROSS JOIN (VALUES
  ('IDA',   1, 'Santana do Ipanema', 'Rodoviária'),
  ('IDA',   2, 'Cacimbinhas',        'Parada intermediária'),
  ('IDA',   3, 'Maceió',             'Rodoviária'),
  ('VOLTA', 1, 'Maceió',             'Rodoviária'),
  ('VOLTA', 2, 'Cacimbinhas',        'Parada intermediária'),
  ('VOLTA', 3, 'Santana do Ipanema', 'Rodoviária')
) AS p(sentido, ordem, cidade, descricao)
WHERE r.linha ILIKE '%Santana do Ipanema%Maceió%';

COMMIT;
