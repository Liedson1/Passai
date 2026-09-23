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

    final origemNorm = normalizar(origem);
    final destinoNorm = normalizar(destino);

    for (final rota in todasAsRotas) {
      final rotaOrigemNorm = normalizar(rota.origem);
      final rotaDestinoNorm = normalizar(rota.destino);

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

  /// Normaliza texto removendo acentos, espaços extras e convertendo para minúsculas.
  /// Público para permitir testes unitários diretos.
  static String normalizar(String str) {
    return str
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[àáâãäå]'), 'a')
        .replaceAll(RegExp(r'[èéêë]'), 'e')
        .replaceAll(RegExp(r'[ìíîï]'), 'i')
        .replaceAll(RegExp(r'[òóôõö]'), 'o')
        .replaceAll(RegExp(r'[ùúûü]'), 'u')
        .replaceAll(RegExp(r'[ç]'), 'c');
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
