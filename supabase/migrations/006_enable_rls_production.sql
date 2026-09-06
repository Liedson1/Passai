-- ============================================================
-- Passaí — Ativação de Row Level Security (RLS) para Produção
-- Migração: 006_enable_rls_production.sql
-- ============================================================

-- 1. Habilita RLS em todas as tabelas
ALTER TABLE cidades ENABLE ROW LEVEL SECURITY;
ALTER TABLE rotas ENABLE ROW LEVEL SECURITY;
ALTER TABLE horarios ENABLE ROW LEVEL SECURITY;
ALTER TABLE alteracoes_horario ENABLE ROW LEVEL SECURITY;

-- 2. Remove políticas anteriores para evitar conflitos
DROP POLICY IF EXISTS "leitura_publica_cidades" ON cidades;
DROP POLICY IF EXISTS "leitura_publica_rotas" ON rotas;
DROP POLICY IF EXISTS "leitura_publica_horarios" ON horarios;
DROP POLICY IF EXISTS "leitura_publica_alteracoes" ON alteracoes_horario;
DROP POLICY IF EXISTS "leitura_publica_alteracoes_geral" ON alteracoes_horario;
DROP POLICY IF EXISTS "admin_write_cidades" ON cidades;
DROP POLICY IF EXISTS "admin_write_rotas" ON rotas;
DROP POLICY IF EXISTS "admin_write_horarios" ON horarios;
DROP POLICY IF EXISTS "admin_write_alteracoes" ON alteracoes_horario;

-- 3. Políticas de leitura pública (RN01 — anônimo e autenticado)
CREATE POLICY "leitura_publica_cidades"
  ON cidades FOR SELECT
  USING (true);

CREATE POLICY "leitura_publica_rotas"
  ON rotas FOR SELECT
  USING (ativa = true);

CREATE POLICY "leitura_publica_horarios"
  ON horarios FOR SELECT
  USING (true);

CREATE POLICY "leitura_publica_alteracoes"
  ON alteracoes_horario FOR SELECT
  USING (ativa = true);

-- 4. Políticas de escrita restritas apenas a usuários autenticados (Admin)
CREATE POLICY "admin_write_cidades"
  ON cidades FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "admin_write_rotas"
  ON rotas FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "admin_write_horarios"
  ON horarios FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "admin_write_alteracoes"
  ON alteracoes_horario FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);
