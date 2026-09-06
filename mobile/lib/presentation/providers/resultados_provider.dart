import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:passai/domain/entities/horario.dart';
import 'package:passai/domain/usecases/buscar_horarios_por_data.dart';
import 'package:passai/presentation/providers/rotas_provider.dart';

// ---------------------------------------------------------------------------
// Use case
// ---------------------------------------------------------------------------

/// Use case de horários por data
final buscarHorariosPorDataUsecaseProvider = Provider<BuscarHorariosPorData>(
  (ref) => BuscarHorariosPorData(ref.watch(rotasRepositoryProvider)),
);

// ---------------------------------------------------------------------------
// Estado da tela de resultados
// ---------------------------------------------------------------------------

/// Data selecionada no seletor de datas
final dataSelecionadaProvider = StateProvider<DateTime>(
  (_) => DateTime.now(),
);

/// Filtro de período ativo
enum FiltroPeriodo { todos, manha, tarde, noite }

final filtroPeriodoProvider = StateProvider<FiltroPeriodo>(
  (_) => FiltroPeriodo.todos,
);

// ---------------------------------------------------------------------------
// Parâmetros de busca da tela de resultados
// ---------------------------------------------------------------------------

/// Parâmetros para o provider de resultados
class ResultadosParams {
  const ResultadosParams({
    required this.rotaId,
    required this.sentido,
    required this.data,
  });

  final int rotaId;
  final Sentido sentido;
  final DateTime data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResultadosParams &&
          runtimeType == other.runtimeType &&
          rotaId == other.rotaId &&
          sentido == other.sentido &&
          data.year == other.data.year &&
          data.month == other.data.month &&
          data.day == other.data.day;

  @override
  int get hashCode =>
      rotaId.hashCode ^
      sentido.hashCode ^
      data.year.hashCode ^
      data.month.hashCode ^
      data.day.hashCode;
}

// ---------------------------------------------------------------------------
// Provider principal — busca horários por rota + sentido + data
// ---------------------------------------------------------------------------

final resultadosHorariosProvider =
    FutureProvider.family<List<Horario>, ResultadosParams>((ref, params) {
  return ref.watch(buscarHorariosPorDataUsecaseProvider).call(
        rotaId: params.rotaId,
        sentido: params.sentido,
        data: params.data,
      );
});

// ---------------------------------------------------------------------------
// Filtragem por período do dia
// ---------------------------------------------------------------------------

/// Filtra horários por período (manhã, tarde, noite)
List<Horario> filtrarPorPeriodo(List<Horario> horarios, FiltroPeriodo filtro) {
  if (filtro == FiltroPeriodo.todos) return horarios;

  return horarios.where((h) {
    final partes = h.hora.split(':');
    if (partes.length < 2) return true;
    final horaInt = int.tryParse(partes[0]) ?? 0;

    switch (filtro) {
      case FiltroPeriodo.manha:
        return horaInt < 12;
      case FiltroPeriodo.tarde:
        return horaInt >= 12 && horaInt < 18;
      case FiltroPeriodo.noite:
        return horaInt >= 18 && horaInt <= 23;
      case FiltroPeriodo.todos:
        return true;
    }
  }).toList();
}

// ---------------------------------------------------------------------------
// Modelo do seletor de datas
// ---------------------------------------------------------------------------

/// Item do seletor de datas (representa 1 dia na faixa de 7)
class DiaItem {
  const DiaItem({
    required this.diaSemana,
    required this.dia,
    required this.data,
    this.selecionado = false,
  });

  final String diaSemana;
  final String dia;
  final DateTime data;
  final bool selecionado;
}

/// Gera os 7 dias para o seletor, centralizado na data selecionada
List<DiaItem> gerarDiasSeletor(DateTime dataSelecionada) {
  const diasSemanaAbrev = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

  // 3 dias antes, dia selecionado, 3 dias depois
  final inicio = dataSelecionada.subtract(const Duration(days: 3));

  return List.generate(7, (index) {
    final dia = inicio.add(Duration(days: index));
    final isSelecionado = dia.year == dataSelecionada.year &&
        dia.month == dataSelecionada.month &&
        dia.day == dataSelecionada.day;

    return DiaItem(
      diaSemana: diasSemanaAbrev[dia.weekday - 1],
      dia: dia.day.toString().padLeft(2, '0'),
      data: dia,
      selecionado: isSelecionado,
    );
  });
}
