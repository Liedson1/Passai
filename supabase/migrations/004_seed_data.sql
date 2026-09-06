-- ============================================================
-- Passaí — Carga inicial de dados reais (Seed) e Permissões RLS
-- Migração: 004_seed_data.sql
-- ============================================================

-- 1. Garantir que as políticas de leitura pública existam
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'cidades' AND policyname = 'leitura_publica_cidades'
  ) THEN
    CREATE POLICY "leitura_publica_cidades" ON cidades FOR SELECT USING (true);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'rotas' AND policyname = 'leitura_publica_rotas'
  ) THEN
    CREATE POLICY "leitura_publica_rotas" ON rotas FOR SELECT USING (ativa = true);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'horarios' AND policyname = 'leitura_publica_horarios'
  ) THEN
    CREATE POLICY "leitura_publica_horarios" ON horarios FOR SELECT USING (true);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'alteracoes_horario' AND policyname = 'leitura_publica_alteracoes'
  ) THEN
    CREATE POLICY "leitura_publica_alteracoes" ON alteracoes_horario FOR SELECT USING (ativa = true);
  END IF;
END $$;

-- 2. Inserir Cidades (se ainda não existirem)
INSERT INTO cidades (id, nome, estado) VALUES
  (1, 'Água Branca',     'AL'),
  (2, 'Delmiro Gouveia', 'AL'),
  (3, 'Maceió',          'AL'),
  (4, 'Anadia',          'AL')
ON CONFLICT (id) DO UPDATE SET nome = EXCLUDED.nome, estado = EXCLUDED.estado;

-- Ajustar a sequence de cidades
SELECT setval('cidades_id_seq', (SELECT COALESCE(MAX(id), 1) FROM cidades));

-- 3. Inserir Rotas
INSERT INTO rotas (id, linha, origem_id, destino_id, distancia_km, tarifa, dias_operacao, ativa) VALUES
  (1, '28',  1, 2,  64,  NULL,  'Segunda a Domingo', true),
  (2, '29',  1, 3, 306,  NULL,  'Segunda a Sábado',  true),
  (3, '118', 4, 3,  99, 17.50, 'Segunda a Sábado',  true)
ON CONFLICT (id) DO UPDATE SET
  linha = EXCLUDED.linha,
  origem_id = EXCLUDED.origem_id,
  destino_id = EXCLUDED.destino_id,
  distancia_km = EXCLUDED.distancia_km,
  tarifa = EXCLUDED.tarifa,
  dias_operacao = EXCLUDED.dias_operacao,
  ativa = EXCLUDED.ativa;

SELECT setval('rotas_id_seq', (SELECT COALESCE(MAX(id), 1) FROM rotas));

-- 4. Inserir Horários — Linha 28 (Água Branca → Delmiro Gouveia) — IDA
INSERT INTO horarios (rota_id, sentido, hora) VALUES
  (1, 'IDA', '06:00'), (1, 'IDA', '06:30'), (1, 'IDA', '07:00'),
  (1, 'IDA', '07:30'), (1, 'IDA', '08:00'), (1, 'IDA', '08:30'),
  (1, 'IDA', '09:00'), (1, 'IDA', '09:30'), (1, 'IDA', '10:00'),
  (1, 'IDA', '10:30'), (1, 'IDA', '11:00'), (1, 'IDA', '11:30'),
  (1, 'IDA', '12:00'), (1, 'IDA', '12:30'), (1, 'IDA', '13:10'),
  (1, 'IDA', '13:50'), (1, 'IDA', '14:30'), (1, 'IDA', '15:00'),
  (1, 'IDA', '15:30'), (1, 'IDA', '16:00'), (1, 'IDA', '16:30'),
  (1, 'IDA', '17:00')
ON CONFLICT DO NOTHING;

-- Horários — Linha 28 (Delmiro Gouveia → Água Branca) — VOLTA
INSERT INTO horarios (rota_id, sentido, hora) VALUES
  (1, 'VOLTA', '07:00'), (1, 'VOLTA', '07:30'), (1, 'VOLTA', '08:00'),
  (1, 'VOLTA', '08:30'), (1, 'VOLTA', '09:00'), (1, 'VOLTA', '09:30'),
  (1, 'VOLTA', '10:00'), (1, 'VOLTA', '10:30'), (1, 'VOLTA', '11:00'),
  (1, 'VOLTA', '11:30'), (1, 'VOLTA', '12:00'), (1, 'VOLTA', '12:30'),
  (1, 'VOLTA', '13:00'), (1, 'VOLTA', '13:30'), (1, 'VOLTA', '14:10'),
  (1, 'VOLTA', '14:50'), (1, 'VOLTA', '15:30'), (1, 'VOLTA', '16:00'),
  (1, 'VOLTA', '16:30'), (1, 'VOLTA', '17:00'), (1, 'VOLTA', '17:30'),
  (1, 'VOLTA', '18:00'), (1, 'VOLTA', '18:30'), (1, 'VOLTA', '19:00'),
  (1, 'VOLTA', '19:30')
ON CONFLICT DO NOTHING;

-- Horários — Linha 29 (Água Branca → Maceió) — IDA
INSERT INTO horarios (rota_id, sentido, hora) VALUES
  (2, 'IDA', '04:00'), (2, 'IDA', '13:00')
ON CONFLICT DO NOTHING;

-- Horários — Linha 29 (Maceió → Água Branca) — VOLTA
INSERT INTO horarios (rota_id, sentido, hora) VALUES
  (2, 'VOLTA', '04:00'), (2, 'VOLTA', '13:30')
ON CONFLICT DO NOTHING;

-- Horários — Linha 118 (Anadia → Maceió) — IDA
INSERT INTO horarios (rota_id, sentido, hora) VALUES
  (3, 'IDA', '05:00'), (3, 'IDA', '06:00'), (3, 'IDA', '07:00'),
  (3, 'IDA', '08:00'), (3, 'IDA', '13:30')
ON CONFLICT DO NOTHING;

-- Horários — Linha 118 (Maceió → Anadia) — VOLTA
INSERT INTO horarios (rota_id, sentido, hora) VALUES
  (3, 'VOLTA', '09:00'), (3, 'VOLTA', '10:30'), (3, 'VOLTA', '12:00'),
  (3, 'VOLTA', '13:30'), (3, 'VOLTA', '16:00')
ON CONFLICT DO NOTHING;
