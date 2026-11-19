import 'package:passai/core/utils/text_normalizer.dart';
import 'package:passai/data/datasources/rotas_remote_datasource.dart';
import 'package:passai/domain/entities/horario.dart';
import 'package:passai/domain/entities/rota.dart';
import 'package:passai/domain/repositories/rotas_repository.dart';

/// Implementação concreta do [RotasRepository].
/// Delega o acesso a dados para [RotasRemoteDatasource] e
/// converte os models para entidades de domínio.
class RotasRepositoryImpl implements RotasRepository {
  RotasRepositoryImpl(this._datasource);

  final RotasRemoteDatasource _datasource;

  // Cache em memória para evitar queries repetidas ao Supabase na mesma sessão.
  // Elimina o double-fetch: buscarCidades deriva do cache de rotas já carregado.
  List<Rota>? _rotasCache;
  List<String>? _cidadesCache;

  /// Limpa o cache em memória, forçando nova consulta ao banco na próxima chamada.
  /// Chamado quando o usuário faz pull-to-refresh.
  void limparCache() {
    _rotasCache = null;
    _cidadesCache = null;
  }

  @override
  Future<List<Rota>> buscarTodasAsRotas() async {
    if (_rotasCache != null) return _rotasCache!;
    final models = await _datasource.fetchTodasAsRotas();
    _rotasCache = models.map((m) => m.toEntity()).toList();
    return _rotasCache!;
  }

  @override
  Future<List<String>> buscarCidades({String? termo}) async {
    // Aproveita o cache de rotas se já estiver disponível — zero query extra ao banco.
    if (_cidadesCache == null) {
      final rotas = await buscarTodasAsRotas();
      final cidadesSet = <String>{};
      for (final r in rotas) {
        final origem = r.origem.trim();
        final destino = r.destino.trim();
        if (origem.isNotEmpty) cidadesSet.add(origem);
        if (destino.isNotEmpty) cidadesSet.add(destino);
      }
      _cidadesCache = cidadesSet.toList()..sort((a, b) => a.compareTo(b));
    }

    if (termo == null || termo.trim().isEmpty) {
      return _cidadesCache!;
    }
    final termoNorm = TextNormalizer.normalizar(termo.trim());
    return _cidadesCache!
        .where((c) => TextNormalizer.normalizar(c).contains(termoNorm))
        .toList();
  }

  @override
  Future<List<Horario>> buscarHorarios({
    required int rotaId,
    required Sentido sentido,
  }) async {
    final sentidoStr = sentido == Sentido.ida ? 'IDA' : 'VOLTA';
    final models = await _datasource.fetchHorarios(
      rotaId: rotaId,
      sentido: sentidoStr,
    );
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<Horario>> buscarHorariosPorData({
    required int rotaId,
    required Sentido sentido,
    required DateTime data,
  }) async {
    final sentidoStr = sentido == Sentido.ida ? 'IDA' : 'VOLTA';
    final models = await _datasource.fetchHorariosPorData(
      rotaId: rotaId,
      sentido: sentidoStr,
      data: data,
    );
    return models.map((m) => m.toEntity()).toList();
  }
}

