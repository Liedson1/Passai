-- ============================================================
-- Passaí — Corrigir tarifas que estavam hardcoded no código Dart
-- Migração: 019_corrigir_tarifas_hardcoded.sql
-- ============================================================
-- CONTEXTO: As tarifas das rotas ID 6 e 54 estavam sendo sobrescritas
-- no código do modelo Dart (rota_model.dart). Isso violava a separação
-- de responsabilidades — a tarifa deve vir corretamente do banco.
-- Esta migração atualiza os valores corretos diretamente na base.
-- ============================================================

UPDATE rotas SET tarifa = 36.00 WHERE id = 6 AND (tarifa IS NULL OR tarifa != 36.00);
UPDATE rotas SET tarifa = 28.00 WHERE id = 54 AND (tarifa IS NULL OR tarifa != 28.00);
