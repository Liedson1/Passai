-- ============================================================
-- Passaí — Otimização de Performance de Consulta de Horários
-- Migração: 011_add_composite_index_horarios.sql
-- ============================================================
-- Cria índice composto em (rota_id, sentido, hora) na tabela horarios.
-- Permite que o PostgreSQL resolva a busca e a ordenação cronológica
-- em um único Index Scan direto sem necessidade de bitmap heap scan e sort em memória.
-- ============================================================

CREATE INDEX IF NOT EXISTS idx_horarios_busca_composta
  ON public.horarios (rota_id, sentido, hora ASC);
