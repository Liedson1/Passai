import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:passai/domain/entities/horario.dart';
import 'package:passai/domain/usecases/buscar_horarios.dart';
import 'package:passai/presentation/providers/rotas_provider.dart';

/// Use case de horários
final buscarHorariosUsecaseProvider = Provider<BuscarHorarios>(
  (ref) => BuscarHorarios(ref.watch(rotasRepositoryProvider)),
);

/// Parâmetro de consulta: rota + sentido escolhido pelo usuário
class HorariosParams {
  const HorariosParams({required this.rotaId, required this.sentido});
  final int rotaId;
  final Sentido sentido;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HorariosParams &&
          runtimeType == other.runtimeType &&
          rotaId == other.rotaId &&
          sentido == other.sentido;

  @override
  int get hashCode => rotaId.hashCode ^ sentido.hashCode;
}

/// Sentido escolhido pelo usuário na tela de horários
final sentidoSelecionadoProvider = StateProvider<Sentido>(
  (_) => Sentido.ida,
);

/// Horários carregados para uma rota e sentido específico.
/// Atualiza automaticamente quando [sentidoSelecionadoProvider] muda.
final horariosProvider =
    FutureProvider.family<List<Horario>, HorariosParams>((ref, params) {
  return ref.watch(buscarHorariosUsecaseProvider).call(
        rotaId: params.rotaId,
        sentido: params.sentido,
      );
});
