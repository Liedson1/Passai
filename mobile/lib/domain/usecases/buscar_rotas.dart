import 'package:passai/domain/entities/horario.dart';
import 'package:passai/domain/entities/rota.dart';
import 'package:passai/domain/repositories/rotas_repository.dart';

/// Resultado de uma busca de rota com indicação do sentido correspondente.
class RotaSearchResult {
  const RotaSearchResult({
    required this.rota,
    required this.sentido,
  });

  final Rota rota;
  final Sentido sentido;
}

/// Caso de uso: busca todas as rotas e filtra por origem e destino.
class BuscarRotas {
  const BuscarRotas(this._repository);

  final RotasRepository _repository;

  /// Retorna rotas que combinam com a [origem] e o [destino] informados,
  /// considerando tanto o sentido direto (IDA) quanto o sentido reverso (VOLTA).
  Future<List<RotaSearchResult>> buscarComSentido({
    required String origem,
    required String destino,
  }) async {
    final todasAsRotas = await _repository.buscarTodasAsRotas();
    final resultados = <RotaSearchResult>[];

    final origemNorm = origem.trim().toLowerCase();
    final destinoNorm = destino.trim().toLowerCase();

    for (final rota in todasAsRotas) {
      final rotaOrigemNorm = rota.origem.trim().toLowerCase();
      final rotaDestinoNorm = rota.destino.trim().toLowerCase();

      // Sentido direto (origem -> destino = IDA)
      if (rotaOrigemNorm == origemNorm && rotaDestinoNorm == destinoNorm) {
        resultados.add(RotaSearchResult(rota: rota, sentido: Sentido.ida));
      }
      // Sentido reverso (destino -> origem = VOLTA)
      else if (rotaOrigemNorm == destinoNorm && rotaDestinoNorm == origemNorm) {
        resultados.add(RotaSearchResult(rota: rota, sentido: Sentido.volta));
      }
    }

    return resultados;
  }

  /// Retorna rotas que combinam com a [origem] e o [destino] informados.
  /// Suporta tanto o sentido direto quanto o reverso.
  Future<List<Rota>> call({
    required String origem,
    required String destino,
  }) async {
    final resultados = await buscarComSentido(
      origem: origem,
      destino: destino,
    );
    return resultados.map((r) => r.rota).toList();
  }
}
