import 'package:passai/domain/entities/horario.dart';
import 'package:passai/domain/repositories/rotas_repository.dart';

/// Caso de uso: busca os horários de uma rota para um sentido específico.
class BuscarHorarios {
  const BuscarHorarios(this._repository);

  final RotasRepository _repository;

  /// Retorna horários de [rotaId] no [sentido] informado,
  /// com as alterações do dia aplicadas (RN05).
  Future<List<Horario>> call({
    required int rotaId,
    required Sentido sentido,
  }) {
    return _repository.buscarHorarios(rotaId: rotaId, sentido: sentido);
  }
}
