-- ============================================================
-- Passaí — Coordenadas das Cidades Restantes (sem coordenadas)
-- Migração: 016_coordenadas_cidades_restantes.sql
-- ============================================================
-- Contexto:
-- A migração 014 populou as cidades principais e intermediárias
-- conhecidas dos itinerários (paradas_rota).
-- A query de verificação retornou 18 cidades da tabela `cidades`
-- (vindas da migração 005) que ainda não tinham latitude/longitude.
--
-- Esta migração completa a cobertura, adicionando as coordenadas
-- de todas as cidades restantes, garantindo que a migração 015
-- (JOIN por nome) consiga popular cidade_id em paradas_rota para
-- qualquer rota futura que use essas cidades.
--
-- Nota: "Major Izidoro" (com Z) é grafia correta do banco —
-- diferente de "Major Isidoro" (com S) que estava na 014.
-- Esta migração cobre a grafia correta do banco.
--
-- Fonte: OpenStreetMap / IBGE — municípios de Alagoas.
-- ============================================================

BEGIN;

-- ----------------------------------------------------------------
-- Cidades sem coordenadas retornadas pela verificação da 014
-- ----------------------------------------------------------------

UPDATE public.cidades SET latitude = -9.8861,  longitude = -36.6575 WHERE nome = 'Feira Grande';
UPDATE public.cidades SET latitude = -9.5564,  longitude = -36.7906 WHERE nome = 'Folha Miúda';
UPDATE public.cidades SET latitude = -9.5753,  longitude = -36.6225 WHERE nome = 'Igaci';
UPDATE public.cidades SET latitude = -10.1272, longitude = -36.6578 WHERE nome = 'Igreja Nova';
UPDATE public.cidades SET latitude = -9.8333,  longitude = -36.4722 WHERE nome = 'Lagoa da Canoa';
-- Grafia correta no banco: Major Izidoro (com Z)
UPDATE public.cidades SET latitude = -9.7114,  longitude = -36.8242 WHERE nome = 'Major Izidoro';
UPDATE public.cidades SET latitude = -9.6353,  longitude = -37.2281 WHERE nome = 'Minador do Negrão';
UPDATE public.cidades SET latitude = -9.6367,  longitude = -37.2656 WHERE nome = 'Olho d''Água Grande';
UPDATE public.cidades SET latitude = -9.5239,  longitude = -35.9789 WHERE nome = 'Olivença';
UPDATE public.cidades SET latitude = -9.3994,  longitude = -37.3842 WHERE nome = 'Palestina';
UPDATE public.cidades SET latitude = -9.7489,  longitude = -37.4400 WHERE nome = 'Pão de Açúcar';
UPDATE public.cidades SET latitude = -10.2892, longitude = -36.5906 WHERE nome = 'Penedo';
UPDATE public.cidades SET latitude = -9.5256,  longitude = -37.3467 WHERE nome = 'Poço das Trincheiras';
UPDATE public.cidades SET latitude = -10.1775, longitude = -36.8328 WHERE nome = 'Porto Real do Colégio';
UPDATE public.cidades SET latitude = -9.3250,  longitude = -36.4736 WHERE nome = 'Quebrangulo';
UPDATE public.cidades SET latitude = -9.6728,  longitude = -36.3831 WHERE nome = 'São Brás';
UPDATE public.cidades SET latitude = -9.7708,  longitude = -36.3558 WHERE nome = 'Tanque d''Arca';
UPDATE public.cidades SET latitude = -9.9700,  longitude = -36.9844 WHERE nome = 'Traipu';

-- ----------------------------------------------------------------
-- Cidades adicionais da 005 que podem ter ficado sem coordenada
-- ----------------------------------------------------------------
UPDATE public.cidades SET latitude = -9.5444,  longitude = -36.1019 WHERE nome = 'Boca da Mata';
UPDATE public.cidades SET latitude = -9.1339,  longitude = -37.6481 WHERE nome = 'Canapi';
UPDATE public.cidades SET latitude = -9.5172,  longitude = -36.8361 WHERE nome = 'Carneiros';
UPDATE public.cidades SET latitude = -9.5000,  longitude = -36.2000 WHERE nome = 'Craíbas';
UPDATE public.cidades SET latitude = -9.5475,  longitude = -37.2811 WHERE nome = 'Dois Riachos';
UPDATE public.cidades SET latitude = -9.5153,  longitude = -36.0919 WHERE nome = 'Girau do Ponciano';
UPDATE public.cidades SET latitude = -9.8833,  longitude = -36.5028 WHERE nome = 'Junqueiro';
UPDATE public.cidades SET latitude = -9.5303,  longitude = -37.5589 WHERE nome = 'Mata Grande';
UPDATE public.cidades SET latitude = -9.4167,  longitude = -37.0667 WHERE nome = 'Maravilha';
UPDATE public.cidades SET latitude = -9.3519,  longitude = -37.6128 WHERE nome = 'Pariconha';
UPDATE public.cidades SET latitude = -9.6578,  longitude = -36.4431 WHERE nome = 'Paulo Jacinto';
UPDATE public.cidades SET latitude = -10.0992, longitude = -36.3386 WHERE nome = 'Piaçabuçu';
UPDATE public.cidades SET latitude = -9.3811,  longitude = -36.9078 WHERE nome = 'Senador Rui Palmeira';
UPDATE public.cidades SET latitude = -9.9153,  longitude = -36.3806 WHERE nome = 'Teotônio Vilela';
UPDATE public.cidades SET latitude = -9.3636,  longitude = -36.2503 WHERE nome = 'Viçosa';
UPDATE public.cidades SET latitude = -9.4756,  longitude = -37.8022 WHERE nome = 'Inhapi';

COMMIT;

-- ----------------------------------------------------------------
-- Verificação final: não deve retornar nenhuma linha após esta migração
-- ----------------------------------------------------------------
SELECT nome, estado
FROM public.cidades
WHERE latitude IS NULL
ORDER BY nome;
