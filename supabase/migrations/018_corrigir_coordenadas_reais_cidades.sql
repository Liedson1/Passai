-- ====================================================================
-- Migration: 018_corrigir_coordenadas_reais_cidades.sql
-- Descrição: Corrige as coordenadas geográficas (latitude/longitude) das
--            cidades e paradas para alinhamento oficial com IBGE e OSM.
-- ====================================================================

BEGIN;

-- 1. Garante que Batalha existe na tabela cidades com dados precisos
INSERT INTO public.cidades (nome, estado, latitude, longitude)
VALUES ('Batalha', 'AL', -9.6734, -37.1265)
ON CONFLICT (nome) DO UPDATE SET latitude = -9.6734, longitude = -37.1265;

-- 2. Atualiza coordenadas oficiais de todos os municípios operacionais
UPDATE public.cidades SET latitude = -9.68302, longitude = -36.30527 WHERE nome ILIKE 'Anadia';
UPDATE public.cidades SET latitude = -9.75487, longitude = -36.66147 WHERE nome ILIKE 'Arapiraca';
UPDATE public.cidades SET latitude = -9.6734, longitude = -37.1265 WHERE nome ILIKE 'Batalha';
UPDATE public.cidades SET latitude = -9.64521, longitude = -36.21167 WHERE nome ILIKE 'Boca da Mata';
UPDATE public.cidades SET latitude = -9.765, longitude = -36.5821 WHERE nome ILIKE 'Bom Jardim';
UPDATE public.cidades SET latitude = -9.5683, longitude = -37.1215 WHERE nome ILIKE 'Bonsucesso';
UPDATE public.cidades SET latitude = -10.1687, longitude = -36.314 WHERE nome ILIKE 'Botafogo';
UPDATE public.cidades SET latitude = -9.40121, longitude = -36.99108 WHERE nome ILIKE 'Cacimbinhas';
UPDATE public.cidades SET latitude = -9.11736, longitude = -37.60117 WHERE nome ILIKE 'Canapi';
UPDATE public.cidades SET latitude = -10.1256, longitude = -36.1756 WHERE nome ILIKE 'Coruripe';
UPDATE public.cidades SET latitude = -9.6168, longitude = -36.76846 WHERE nome ILIKE 'Craíbas';
UPDATE public.cidades SET latitude = -9.38412, longitude = -37.99776 WHERE nome ILIKE 'Delmiro Gouveia';
UPDATE public.cidades SET latitude = -9.38465, longitude = -37.0965 WHERE nome ILIKE 'Dois Riachos';
UPDATE public.cidades SET latitude = -9.8956, longitude = -36.6787 WHERE nome ILIKE 'Feira Grande';
UPDATE public.cidades SET latitude = -9.7033, longitude = -36.7952 WHERE nome ILIKE 'Folha Miúda';
UPDATE public.cidades SET latitude = -9.88404, longitude = -36.83159 WHERE nome ILIKE 'Girau do Ponciano';
UPDATE public.cidades SET latitude = -9.5379, longitude = -36.6318 WHERE nome ILIKE 'Igaci';
UPDATE public.cidades SET latitude = -10.1267, longitude = -36.6582 WHERE nome ILIKE 'Igreja Nova';
UPDATE public.cidades SET latitude = -9.22209, longitude = -37.74807 WHERE nome ILIKE 'Inhapi';
UPDATE public.cidades SET latitude = -9.63487, longitude = -37.20558 WHERE nome ILIKE 'Jacaré dos Homens';
UPDATE public.cidades SET latitude = -9.65973, longitude = -37.00155 WHERE nome ILIKE 'Jaramataia';
UPDATE public.cidades SET latitude = -9.9298, longitude = -36.2023 WHERE nome ILIKE 'Junqueiro';
UPDATE public.cidades SET latitude = -9.8294, longitude = -36.73956 WHERE nome ILIKE 'Lagoa da Canoa';
UPDATE public.cidades SET latitude = -9.32, longitude = -37.97 WHERE nome ILIKE 'Lagoa das Pedras';
UPDATE public.cidades SET latitude = -9.74539, longitude = -36.45951 WHERE nome ILIKE 'Limoeiro de Anadia';
UPDATE public.cidades SET latitude = -9.64768, longitude = -35.73393 WHERE nome ILIKE 'Maceió';
UPDATE public.cidades SET latitude = -9.53266, longitude = -36.9862 WHERE nome ILIKE 'Major Izidoro';
UPDATE public.cidades SET latitude = -9.23045, longitude = -37.35242 WHERE nome ILIKE 'Maravilha';
UPDATE public.cidades SET latitude = -9.5798, longitude = -36.3065 WHERE nome ILIKE 'Maribondo';
UPDATE public.cidades SET latitude = -9.11824, longitude = -37.7323 WHERE nome ILIKE 'Mata Grande';
UPDATE public.cidades SET latitude = -9.3124, longitude = -36.8696 WHERE nome ILIKE 'Minador do Negrão';
UPDATE public.cidades SET latitude = -9.60257, longitude = -37.24617 WHERE nome ILIKE 'Monteirópolis';
UPDATE public.cidades SET latitude = -10.0561, longitude = -36.8135 WHERE nome ILIKE 'Olho d''Água Grande';
UPDATE public.cidades SET latitude = -9.53184, longitude = -37.29391 WHERE nome ILIKE 'Olho d''Água das Flores';
UPDATE public.cidades SET latitude = -9.50208, longitude = -37.83245 WHERE nome ILIKE 'Olho d''Água do Casado';
UPDATE public.cidades SET latitude = -9.51906, longitude = -37.18933 WHERE nome ILIKE 'Olivença';
UPDATE public.cidades SET latitude = -9.16227, longitude = -37.35829 WHERE nome ILIKE 'Ouro Branco';
UPDATE public.cidades SET latitude = -9.6721, longitude = -37.3293 WHERE nome ILIKE 'Palestina';
UPDATE public.cidades SET latitude = -9.4076, longitude = -36.6324 WHERE nome ILIKE 'Palmeira dos Índios';
UPDATE public.cidades SET latitude = -9.72, longitude = -36.55 WHERE nome ILIKE 'Papa Farinha';
UPDATE public.cidades SET latitude = -9.25401, longitude = -38.00392 WHERE nome ILIKE 'Pariconha';
UPDATE public.cidades SET latitude = -9.36792, longitude = -36.36724 WHERE nome ILIKE 'Paulo Jacinto';
UPDATE public.cidades SET latitude = -10.2872, longitude = -36.5819 WHERE nome ILIKE 'Penedo';
UPDATE public.cidades SET latitude = -10.40669, longitude = -36.43365 WHERE nome ILIKE 'Piaçabuçu';
UPDATE public.cidades SET latitude = -10.1504, longitude = -36.3317 WHERE nome ILIKE 'Pindorama';
UPDATE public.cidades SET latitude = -9.6256, longitude = -37.7567 WHERE nome ILIKE 'Piranhas';
UPDATE public.cidades SET latitude = -10.1868, longitude = -36.8357 WHERE nome ILIKE 'Porto Real do Colégio';
UPDATE public.cidades SET latitude = -9.3063, longitude = -37.2855 WHERE nome ILIKE 'Poço das Trincheiras';
UPDATE public.cidades SET latitude = -9.7497, longitude = -37.433 WHERE nome ILIKE 'Pão de Açúcar';
UPDATE public.cidades SET latitude = -9.7597, longitude = -36.5566 WHERE nome ILIKE 'Pé Leve';
UPDATE public.cidades SET latitude = -9.32176, longitude = -36.47358 WHERE nome ILIKE 'Quebrangulo';
UPDATE public.cidades SET latitude = -9.4797, longitude = -35.845 WHERE nome ILIKE 'Rio Largo';
UPDATE public.cidades SET latitude = -9.1443, longitude = -37.8357 WHERE nome ILIKE 'Santa Cruz do Deserto';
UPDATE public.cidades SET latitude = -9.6784, longitude = -37.321 WHERE nome ILIKE 'Santa Terezinha';
UPDATE public.cidades SET latitude = -9.36999, longitude = -37.24802 WHERE nome ILIKE 'Santana do Ipanema';
UPDATE public.cidades SET latitude = -9.46987, longitude = -37.45761 WHERE nome ILIKE 'Senador Rui Palmeira';
UPDATE public.cidades SET latitude = -10.12585, longitude = -36.89815 WHERE nome ILIKE 'São Brás';
UPDATE public.cidades SET latitude = -9.55843, longitude = -37.38189 WHERE nome ILIKE 'São José da Tapera';
UPDATE public.cidades SET latitude = -9.7811, longitude = -36.0911 WHERE nome ILIKE 'São Miguel dos Campos';
UPDATE public.cidades SET latitude = -9.93151, longitude = -36.54392 WHERE nome ILIKE 'São Sebastião';
UPDATE public.cidades SET latitude = -9.53482, longitude = -36.43146 WHERE nome ILIKE 'Tanque d''Arca';
UPDATE public.cidades SET latitude = -9.61259, longitude = -36.51019 WHERE nome ILIKE 'Taquarana';
UPDATE public.cidades SET latitude = -9.90627, longitude = -36.35713 WHERE nome ILIKE 'Teotônio Vilela';
UPDATE public.cidades SET latitude = -9.96758, longitude = -37.00154 WHERE nome ILIKE 'Traipu';
UPDATE public.cidades SET latitude = -9.3728, longitude = -36.24326 WHERE nome ILIKE 'Viçosa';
UPDATE public.cidades SET latitude = -9.26136, longitude = -37.93611 WHERE nome ILIKE 'Água Branca';

-- 3. Vincula cidade_id de Anadia em paradas_rota caso esteja nulo
UPDATE public.paradas_rota
SET cidade_id = (SELECT id FROM public.cidades WHERE nome ILIKE 'Anadia' LIMIT 1)
WHERE cidade ILIKE 'Anadia' AND cidade_id IS NULL;

COMMIT;
