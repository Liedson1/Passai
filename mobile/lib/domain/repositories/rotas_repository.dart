import 'package:passai/domain/entities/horario.dart';
import 'package:passai/domain/entities/rota.dart';

/// Contrato abstrato do repositório de rotas e horários.
/// A implementação concreta vive em [data/repositories/].
abstract class RotasRepository {
  /// Retorna todas as rotas ativas do banco.
  Future<List<Rota>> buscarTodasAsRotas();

  /// Retorna todas as cidades disponíveis (para os dropdowns de busca).
  Future<List<String>> buscarCidades();

  /// Retorna os horários de uma [rotaId] filtrados por [sentido].
  /// Inclui a alteração ativa do dia, se houver (RN05).
  Future<List<Horario>> buscarHorarios({
    required int rotaId,
    required Sentido sentido,
  });
}
