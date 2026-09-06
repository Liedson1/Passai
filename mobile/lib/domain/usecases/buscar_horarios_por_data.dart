import 'package:passai/domain/entities/horario.dart';
import 'package:passai/domain/repositories/rotas_repository.dart';

/// Caso de uso: busca os horários de uma rota para uma data específica.
/// Utilizado pela tela de resultados que filtra por dia selecionado.
class BuscarHorariosPorData {
  const BuscarHorariosPorData(this._repository);

  final RotasRepository _repository;

  /// Retorna horários de [rotaId] no [sentido] informado para a [data],
  /// com as alterações do dia aplicadas (RN05).
  Future<List<Horario>> call({
    required int rotaId,
    required Sentido sentido,
    required DateTime data,
  }) {
    return _repository.buscarHorariosPorData(
      rotaId: rotaId,
      sentido: sentido,
      data: data,
    );
  }
}
