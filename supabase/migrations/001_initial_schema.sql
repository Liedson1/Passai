-- ============================================================
-- Passaí — Schema inicial do banco de dados no Supabase
-- Migração: 001_initial_schema.sql
-- ============================================================

-- -------------------------------------------------------------
-- ENUM: Sentido da viagem
-- -------------------------------------------------------------
CREATE TYPE sentido_viagem AS ENUM ('IDA', 'VOLTA');

-- -------------------------------------------------------------
-- TABELA: cidades
-- -------------------------------------------------------------
CREATE TABLE cidades (
  id      SERIAL PRIMARY KEY,
  nome    TEXT NOT NULL,
  estado  TEXT NOT NULL DEFAULT 'AL'
);

CREATE INDEX idx_cidades_nome ON cidades (nome);

-- -------------------------------------------------------------
-- TABELA: rotas
-- -------------------------------------------------------------
CREATE TABLE rotas (
  id             SERIAL PRIMARY KEY,
  linha          TEXT NOT NULL,
  origem_id      INTEGER NOT NULL REFERENCES cidades (id),
  destino_id     INTEGER NOT NULL REFERENCES cidades (id),
  distancia_km   INTEGER,
  tarifa         NUMERIC(8, 2),
  dias_operacao  TEXT NOT NULL DEFAULT 'Segunda a Domingo',
  ativa          BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE INDEX idx_rotas_origem  ON rotas (origem_id);
CREATE INDEX idx_rotas_destino ON rotas (destino_id);

-- -------------------------------------------------------------
-- TABELA: horarios
-- -------------------------------------------------------------
CREATE TABLE horarios (
  id       SERIAL PRIMARY KEY,
  rota_id  INTEGER NOT NULL REFERENCES rotas (id),
  sentido  sentido_viagem NOT NULL,
  hora     TIME NOT NULL
);

CREATE INDEX idx_horarios_rota    ON horarios (rota_id);
CREATE INDEX idx_horarios_sentido ON horarios (sentido);

-- -------------------------------------------------------------
-- TABELA: alteracoes_horario
-- RN03, RN04, RN05, RN06
-- -------------------------------------------------------------
CREATE TABLE alteracoes_horario (
  id              SERIAL PRIMARY KEY,
  horario_id      INTEGER NOT NULL REFERENCES horarios (id),
  hora_original   TIME NOT NULL,
  hora_nova       TIME NOT NULL,
  van_original    TEXT,
  van_substituta  TEXT,
  motivo          TEXT,
  data_alteracao  DATE NOT NULL DEFAULT CURRENT_DATE,
  ativa           BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE INDEX idx_alteracoes_horario_id   ON alteracoes_horario (horario_id);
CREATE INDEX idx_alteracoes_data_ativa   ON alteracoes_horario (data_alteracao, ativa);

-- ============================================================
-- ROW LEVEL SECURITY (RLS)
-- Leitura pública para todas as tabelas (RN01 — sem auth)
-- Escrita apenas via Dashboard do Supabase (não exposta pela API)
-- ============================================================
ALTER TABLE cidades            ENABLE ROW LEVEL SECURITY;
ALTER TABLE rotas               ENABLE ROW LEVEL SECURITY;
ALTER TABLE horarios            ENABLE ROW LEVEL SECURITY;
ALTER TABLE alteracoes_horario  ENABLE ROW LEVEL SECURITY;

-- Políticas de leitura pública (anon e authenticated)
CREATE POLICY "leitura_publica_cidades"
  ON cidades FOR SELECT USING (true);

CREATE POLICY "leitura_publica_rotas"
  ON rotas FOR SELECT USING (ativa = true);

CREATE POLICY "leitura_publica_horarios"
  ON horarios FOR SELECT USING (true);

CREATE POLICY "leitura_publica_alteracoes"
  ON alteracoes_horario FOR SELECT
  USING (ativa = true AND data_alteracao = CURRENT_DATE);

-- ============================================================
-- SEED: Dados reais das linhas de Alagoas
-- ============================================================

-- Cidades
INSERT INTO cidades (nome, estado) VALUES
  ('Água Branca',    'AL'),  -- id 1
  ('Delmiro Gouveia','AL'),  -- id 2
  ('Maceió',         'AL'),  -- id 3
  ('Anadia',         'AL');  -- id 4

-- Rotas
INSERT INTO rotas (linha, origem_id, destino_id, distancia_km, tarifa, dias_operacao) VALUES
  ('28',  1, 2,  64,  NULL,  'Segunda a Domingo'),  -- id 1
  ('29',  1, 3, 306,  NULL,  'Segunda a Sábado'),   -- id 2
  ('118', 4, 3,  99, 17.50, 'Segunda a Sábado');   -- id 3

-- Horários — Linha 28 (Água Branca → Delmiro) — IDA
INSERT INTO horarios (rota_id, sentido, hora) VALUES
  (1, 'IDA', '06:00'), (1, 'IDA', '06:30'), (1, 'IDA', '07:00'),
  (1, 'IDA', '07:30'), (1, 'IDA', '08:00'), (1, 'IDA', '08:30'),
  (1, 'IDA', '09:00'), (1, 'IDA', '09:30'), (1, 'IDA', '10:00'),
  (1, 'IDA', '10:30'), (1, 'IDA', '11:00'), (1, 'IDA', '11:30'),
  (1, 'IDA', '12:00'), (1, 'IDA', '12:30'), (1, 'IDA', '13:10'),
  (1, 'IDA', '13:50'), (1, 'IDA', '14:30'), (1, 'IDA', '15:00'),
  (1, 'IDA', '15:30'), (1, 'IDA', '16:00'), (1, 'IDA', '16:30'),
  (1, 'IDA', '17:00');

-- Horários — Linha 28 (Delmiro → Água Branca) — VOLTA
INSERT INTO horarios (rota_id, sentido, hora) VALUES
  (1, 'VOLTA', '07:00'), (1, 'VOLTA', '07:30'), (1, 'VOLTA', '08:00'),
  (1, 'VOLTA', '08:30'), (1, 'VOLTA', '09:00'), (1, 'VOLTA', '09:30'),
  (1, 'VOLTA', '10:00'), (1, 'VOLTA', '10:30'), (1, 'VOLTA', '11:00'),
  (1, 'VOLTA', '11:30'), (1, 'VOLTA', '12:00'), (1, 'VOLTA', '12:30'),
  (1, 'VOLTA', '13:00'), (1, 'VOLTA', '13:30'), (1, 'VOLTA', '14:10'),
  (1, 'VOLTA', '14:50'), (1, 'VOLTA', '15:30'), (1, 'VOLTA', '16:00'),
  (1, 'VOLTA', '16:30'), (1, 'VOLTA', '17:00'), (1, 'VOLTA', '17:30'),
  (1, 'VOLTA', '18:00'), (1, 'VOLTA', '18:30'), (1, 'VOLTA', '19:00'),
  (1, 'VOLTA', '19:30');

-- Horários — Linha 29 (Água Branca → Maceió) — IDA
INSERT INTO horarios (rota_id, sentido, hora) VALUES
  (2, 'IDA', '04:00'), (2, 'IDA', '13:00');

-- Horários — Linha 29 (Maceió → Água Branca) — VOLTA
INSERT INTO horarios (rota_id, sentido, hora) VALUES
  (2, 'VOLTA', '04:00'), (2, 'VOLTA', '13:30');

-- Horários — Linha 118 (Anadia → Maceió) — IDA
INSERT INTO horarios (rota_id, sentido, hora) VALUES
  (3, 'IDA', '05:00'), (3, 'IDA', '06:00'), (3, 'IDA', '07:00'),
  (3, 'IDA', '08:00'), (3, 'IDA', '13:30');

-- Horários — Linha 118 (Maceió → Anadia) — VOLTA
INSERT INTO horarios (rota_id, sentido, hora) VALUES
  (3, 'VOLTA', '09:00'), (3, 'VOLTA', '10:30'), (3, 'VOLTA', '12:00'),
  (3, 'VOLTA', '13:30'), (3, 'VOLTA', '16:00');
