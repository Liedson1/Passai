import 'package:passai/domain/entities/horario.dart';
import 'package:passai/domain/entities/rota.dart';

/// Contrato abstrato do repositório de rotas e horários.
/// A implementação concreta vive em [data/repositories/].
abstract class RotasRepository {
  /// Retorna todas as rotas ativas do banco.
  Future<List<Rota>> buscarTodasAsRotas();

  /// Retorna cidades cujo nome contém [termo] (case-insensitive).
  /// Se [termo] for nulo ou vazio, retorna todas as cidades disponíveis.
  Future<List<String>> buscarCidades({String? termo});

  /// Retorna os horários de uma [rotaId] filtrados por [sentido].
  /// Inclui a alteração ativa do dia, se houver (RN05).
  Future<List<Horario>> buscarHorarios({
    required int rotaId,
    required Sentido sentido,
  });

  /// Retorna os horários de uma [rotaId] para uma [data] específica.
  /// Filtra por [sentido] e inclui alterações ativas da data (RN05).
  Future<List<Horario>> buscarHorariosPorData({
    required int rotaId,
    required Sentido sentido,
    required DateTime data,
  });
}

