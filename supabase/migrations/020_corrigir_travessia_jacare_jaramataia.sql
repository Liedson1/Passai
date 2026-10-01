-- ============================================================
-- Passaí — Correção de Coordenadas de Travessia Contínua
-- Cidades: Jacaré dos Homens e Jaramataia (Corredor AL-220)
-- Migração: 020_corrigir_travessia_jacare_jaramataia.sql
-- ============================================================
-- CONTEXTO:
-- Anteriormente, as coordenadas dessas duas cidades estavam no centroide
-- geográfico (Praça José Teófilo da Silva em Jacaré e Av. Divaldo Suruagy
-- em Jaramataia). Como o motor de roteamento (OSRM) busca o menor tempo
-- e a AL-220 tem limite de 80 km/h, o mapa desenhava a van entrando pelo
-- acesso, fazendo um retorno em "U" e saindo pela mesma entrada de onde veio.
--
-- SOLUÇÃO:
-- Atualizar as coordenadas para as vias de travessia urbana contínua:
-- 1. Jacaré dos Homens: Rua Monsenhor Freitas Machado (liga o acesso Oeste
--    à saída Leste via Av. Prefeito Antônio Madeiro Filho).
-- 2. Jaramataia: Rua do Comércio (liga a entrada Oeste à saída Leste de volta à AL-220).
-- Com isso, o traçado acompanha perfeitamente o percurso real da van:
-- entra na cidade, percorre a via principal e sai pelo outro lado sem meia-volta.
-- ============================================================

BEGIN;

-- 1. Atualiza coordenadas na tabela cidades para as vias de travessia
UPDATE public.cidades
SET latitude = -9.63548, longitude = -37.20475
WHERE nome ILIKE '%Jacar%dos Homens%';

UPDATE public.cidades
SET latitude = -9.65800, longitude = -37.00400
WHERE nome ILIKE '%Jaramataia%';

-- 2. Atualiza descrições das paradas na rota 54 (Olho d'Água das Flores - Arapiraca)
UPDATE public.paradas_rota
SET descricao = 'Travessia urbana / Rua Monsenhor Freitas Machado'
WHERE cidade ILIKE '%Jacar%dos Homens%'
  AND rota_id IN (SELECT id FROM public.rotas WHERE linha ILIKE '%Olho d''Água das Flores%Arapiraca%');

UPDATE public.paradas_rota
SET descricao = 'Travessia urbana / Rua do Comércio'
WHERE cidade ILIKE '%Jaramataia%'
  AND rota_id IN (SELECT id FROM public.rotas WHERE linha ILIKE '%Olho d''Água das Flores%Arapiraca%');

COMMIT;
