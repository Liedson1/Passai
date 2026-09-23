import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:passai/domain/entities/parada_itinerario.dart';
import 'package:passai/presentation/providers/rotas_provider.dart';

/// Parâmetros para identificar as paradas de uma rota/sentido
class ParadasParams {
  const ParadasParams({required this.rotaId, required this.sentido});

  final int rotaId;
  final String sentido; // 'IDA' ou 'VOLTA'

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParadasParams &&
          rotaId == other.rotaId &&
          sentido == other.sentido;

  @override
  int get hashCode => Object.hash(rotaId, sentido);
}

/// Busca as paradas do itinerário de uma rota/sentido no Supabase.
/// Retorna lista vazia (não erro) quando não há paradas cadastradas —
/// a tela de detalhes faz fallback para exibir apenas origem e destino.
final paradasRotaProvider =
    FutureProvider.family<List<ParadaItinerario>, ParadasParams>(
        (ref, params) async {
  final datasource = ref.watch(rotasRemoteDatasourceProvider);
  final modelos = await datasource.fetchParadasRota(
    rotaId: params.rotaId,
    sentido: params.sentido,
  );
  return modelos.map((m) => m.toEntity()).toList();
});
