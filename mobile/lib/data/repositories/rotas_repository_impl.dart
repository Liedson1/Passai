import 'package:passai/data/datasources/rotas_remote_datasource.dart';
import 'package:passai/domain/entities/horario.dart';
import 'package:passai/domain/entities/rota.dart';
import 'package:passai/domain/repositories/rotas_repository.dart';

/// Implementação concreta do [RotasRepository].
/// Delega o acesso a dados para [RotasRemoteDatasource] e
/// converte os models para entidades de domínio.
class RotasRepositoryImpl implements RotasRepository {
  const RotasRepositoryImpl(this._datasource);

  final RotasRemoteDatasource _datasource;

  @override
  Future<List<Rota>> buscarTodasAsRotas() async {
    final models = await _datasource.fetchTodasAsRotas();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<String>> buscarCidades() {
    return _datasource.fetchCidades();
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
}
