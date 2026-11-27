import 'package:passai/core/constants/coordenadas_cidades.dart';
import 'package:passai/core/utils/duracao_estimativa.dart';
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

  /// Enriquece a lista de paradas com horários proporcionais estimados,
  /// descrições de pontos e tags de embarque/desembarque.
  static List<ParadaItinerario> enriquecerItinerario({
    required List<ParadaItinerario> paradas,
    required String? horaSaida,
    required String? duracaoStr,
    required String? chegadaPrevista,
    String? origemFallback,
    String? destinoFallback,
  }) {
    if (paradas.isEmpty) return const [];

    final total = paradas.length;
    final saidaStr = horaSaida ?? (paradas.isNotEmpty ? paradas.first.horario : '06:00');

    int saidaMinutos = 360;
    final parts = saidaStr.split(':');
    if (parts.length >= 2) {
      final h = int.tryParse(parts[0]) ?? 6;
      final m = int.tryParse(parts[1]) ?? 0;
      saidaMinutos = h * 60 + m;
    }

    final duracaoMinutos = DuracaoEstimativa.extrairMinutos(duracaoStr, fallback: 60);
    final resultado = <ParadaItinerario>[];

    for (int i = 0; i < total; i++) {
      final item = paradas[i];
      final isFirst = i == 0;
      final isLast = i == total - 1;

      String horaCalculada;
      String tipo;
      String? ponto;
      List<String> tags = [];
      String? observacao;

      if (isFirst) {
        tipo = 'origem';
        horaCalculada = saidaStr;
        ponto = item.descricao != null && item.descricao!.isNotEmpty
            ? item.descricao
            : 'Terminal Rodoviário • Ponto de Partida';
        tags = const ['Ponto de Partida', 'Embarque'];
      } else if (isLast) {
        tipo = 'destino';
        if (chegadaPrevista != null && chegadaPrevista.isNotEmpty) {
          horaCalculada = chegadaPrevista;
        } else {
          final totalChegada = (saidaMinutos + duracaoMinutos) % 1440;
          final h = (totalChegada ~/ 60).toString().padLeft(2, '0');
          final m = (totalChegada % 60).toString().padLeft(2, '0');
          horaCalculada = '$h:$m';
        }
        ponto = item.descricao != null && item.descricao!.isNotEmpty
            ? item.descricao
            : 'Terminal Central • Ponto de Chegada';
        tags = const ['Ponto de Chegada', 'Desembarque final'];
      } else {
        tipo = 'intermediaria';
        final fracao = i / (total - 1);
        final estimativaMin = saidaMinutos + (duracaoMinutos * fracao).round();
        final arredondado = ((estimativaMin + 2) ~/ 5) * 5;
        final h = ((arredondado ~/ 60) % 24).toString().padLeft(2, '0');
        final m = (arredondado % 60).toString().padLeft(2, '0');
        horaCalculada = '$h:$m';

        ponto = item.descricao != null && item.descricao!.isNotEmpty
            ? item.descricao
            : (item.parada.isNotEmpty ? item.parada : 'Parada intermediária');
        observacao = item.observacao ?? 'Embarque e desembarque rápido';
      }

      resultado.add(
        item.copyWith(
          horario: horaCalculada,
          tipo: tipo,
          descricao: ponto,
          tags: tags,
          observacao: observacao,
        ),
      );
    }

    return resultado;
  }
}

