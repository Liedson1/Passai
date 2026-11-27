-- ============================================================
-- Passaí — Correção de Pontos de Embarque e Travessias
-- Rota: Olho d'Água das Flores x Arapiraca (Corredor AL-220)
-- Migração: 021_corrigir_pontos_embarque_e_travessia_olho_arapiraca.sql
-- ============================================================
-- CONTEXTO:
-- 1. Olho d'Água das Flores:
--    O ponto oficial de embarque e desembarque das vans intermunicipais
--    fica na Rua do Comércio (-9.536204, -37.293985), ponto oficial
--    de partida e chegada das vans.
--
-- 2. Arapiraca:
--    O ponto de embarque/desembarque das vans do Sertão (linhas de Olho d'Água,
--    Batalha, Delmiro) fica na Rua Santos Dumont / Baixão (-9.7495158, -36.6666349).
--    O percurso segue por trás do ponto na Santos Dumont, entra na Rua Marechal
--    Floriano Peixoto passando pelo Quintela e por trás da Drogasil (em vez da Rua
--    Maurício Pereira / Praça Lions), entra na Rua Antônio Rochery de Lima,
--    passa em frente à Alternativa na Horácio Alexandre dos Santos, entra à esquerda
--    na Benjamin Freire, segue até o semáforo da Igrejinha na AL-220, vira à direita e
--    pega o retorno no canteiro central (-9.729528, -36.663551) para a AL-220 pista oeste.
--
-- 3. Jaramataia:
--    A coordenada foi corrigida para estar milimetricamente alinhada à
--    Rua do Comércio (-9.65769, -37.00450), eliminando o desvio que a rota
--    fazia para a Rua José Moura Pereira antes de retornar à via principal.
-- ============================================================

BEGIN;

-- 1. Atualizar coordenadas canônicas na tabela cidades
UPDATE public.cidades
SET latitude = -9.536204, longitude = -37.293985
WHERE nome ILIKE '%Olho d%Água das Flores%';

UPDATE public.cidades
SET latitude = -9.7495158, longitude = -36.6666349
WHERE nome ILIKE 'Arapiraca';

UPDATE public.cidades
SET latitude = -9.65769, longitude = -37.00450
WHERE nome ILIKE '%Jaramataia%';

-- 2. Atualizar descrições nas paradas das rotas Olho d'Água das Flores x Arapiraca
UPDATE public.paradas_rota
SET descricao = 'Ponto das vans / Rua do Comércio'
WHERE cidade ILIKE '%Olho d%Água das Flores%'
  AND rota_id IN (SELECT id FROM public.rotas WHERE linha ILIKE '%Olho d''Água das Flores%Arapiraca%');

UPDATE public.paradas_rota
SET descricao = 'Ponto das vans / Rua Santos Dumont'
WHERE cidade ILIKE '%Arapiraca%'
  AND rota_id IN (SELECT id FROM public.rotas WHERE linha ILIKE '%Olho d''Água das Flores%Arapiraca%');

UPDATE public.paradas_rota
SET descricao = 'Travessia urbana / Rua do Comércio'
WHERE cidade ILIKE '%Jaramataia%'
  AND rota_id IN (SELECT id FROM public.rotas WHERE linha ILIKE '%Olho d''Água das Flores%Arapiraca%');

UPDATE public.paradas_rota
SET descricao = 'Travessia urbana / Rua Monsenhor Freitas Machado'
WHERE cidade ILIKE '%Jacar%dos Homens%'
  AND rota_id IN (SELECT id FROM public.rotas WHERE linha ILIKE '%Olho d''Água das Flores%Arapiraca%');

COMMIT;
