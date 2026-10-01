import 'package:passai/core/constants/coordenadas_cidades.dart';
import 'package:passai/core/utils/text_normalizer.dart';
import 'package:passai/domain/entities/parada_itinerario.dart';

/// Helper resiliente para construção e enriquecimento do itinerário de viagens.
/// Garante que as paradas intermediárias (ex: Jaramataia e Jacaré dos Homens)
/// sempre sejam exibidas no mapa e na timeline, mesmo em falhas de rede ou offline.
class ItinerarioHelper {
  ItinerarioHelper._();

  /// Constrói o itinerário padrão com origem, paradas intermediárias e destino,
  /// com todas as coordenadas canônicas preenchidas.
  static List<ParadaItinerario> criarItinerarioFallback({
    required String origem,
    required String destino,
    String? horarioSaida,
    int? rotaId,
    String? seccionamentos,
    List<String> paradasIntermediarias = const [],
  }) {
    final intermediarias = <String>[];

    if (paradasIntermediarias.isNotEmpty) {
      intermediarias.addAll(paradasIntermediarias);
    } else {
      final oNorm = TextNormalizer.normalizar(origem);
      final dNorm = TextNormalizer.normalizar(destino);

      // Rota 54: Olho d'Água das Flores x Arapiraca
      if (rotaId == 54 ||
          (oNorm.contains('olho dagua das flores') && dNorm.contains('arapiraca')) ||
          (oNorm.contains('arapiraca') && dNorm.contains('olho dagua das flores'))) {
        if (oNorm.contains('arapiraca')) {
          // Sentido VOLTA: Arapiraca -> Jaramataia -> Jacaré dos Homens -> Olho d'Água das Flores
          intermediarias.addAll(const ['Jaramataia', 'Jacaré dos Homens']);
        } else {
          // Sentido IDA: Olho d'Água das Flores -> Jacaré dos Homens -> Jaramataia -> Arapiraca
          intermediarias.addAll(const ['Jacaré dos Homens', 'Jaramataia']);
        }
      } else if (seccionamentos != null && seccionamentos.trim().isNotEmpty) {
        // Tenta extrair cidades conhecidas mencionadas em seccionamentos
        final seccNorm = TextNormalizer.normalizar(seccionamentos);
        const cidadesConhecidas = [
          'Jaramataia',
          'Jacaré dos Homens',
          'Monteirópolis',
          'São José da Tapera',
          'Olho d\'Água do Casado',
          'Taquarana',
          'Maribondo',
          'Lagoa das Pedras',
          'Folha Miúda',
          'Craíbas',
          'Batalha',
        ];

        for (final cidade in cidadesConhecidas) {
          final cNorm = TextNormalizer.normalizar(cidade);
          if (seccNorm.contains(cNorm) && !oNorm.contains(cNorm) && !dNorm.contains(cNorm)) {
            intermediarias.add(cidade);
          }
        }
      }
    }

    final resultado = <ParadaItinerario>[];

    // 1. Origem
    final coordOrigem = CoordenadasCidades.obter(origem);
    resultado.add(
      ParadaItinerario(
        parada: origem,
        horario: horarioSaida ?? '06:00',
        descricao: 'Ponto de Partida',
        tipo: 'origem',
        latitude: coordOrigem?.latitude,
        longitude: coordOrigem?.longitude,
      ),
    );

    // 2. Paradas intermediárias
    for (final inter in intermediarias) {
      final coord = CoordenadasCidades.obter(inter);
      resultado.add(
        ParadaItinerario(
          parada: inter,
          horario: '',
          descricao: 'Parada intermediária',
          tipo: 'intermediaria',
          latitude: coord?.latitude,
          longitude: coord?.longitude,
        ),
      );
    }

    // 3. Destino
    final coordDestino = CoordenadasCidades.obter(destino);
    resultado.add(
      ParadaItinerario(
        parada: destino,
        horario: '',
        descricao: 'Ponto de Chegada',
        tipo: 'destino',
        latitude: coordDestino?.latitude,
        longitude: coordDestino?.longitude,
      ),
    );

    return resultado;
  }
}
