import 'package:passai/domain/entities/horario.dart';

/// Períodos do dia disponíveis no filtro da tela de resultados
enum FiltroPeriodo { todos, manha, tarde, noite }

/// Utilitário puro para filtragem de horários por período do dia.
/// Extraído do provider para ser testável isoladamente e respeitar
/// a separação de responsabilidades (lógica de negócio fora da camada de apresentação).
class FiltroPeriodoUtils {
  FiltroPeriodoUtils._();

  /// Filtra [horarios] pelo [filtro] de período selecionado.
  ///
  /// Períodos:
  ///   - Manhã: 00h–11h59
  ///   - Tarde: 12h–17h59
  ///   - Noite: 18h–23h59
  static List<Horario> filtrar(List<Horario> horarios, FiltroPeriodo filtro) {
    if (filtro == FiltroPeriodo.todos) return horarios;

    return horarios.where((h) {
      final partes = h.hora.split(':');
      if (partes.length < 2) return true;
      final horaInt = int.tryParse(partes[0]) ?? 0;

      return switch (filtro) {
        FiltroPeriodo.manha => horaInt < 12,
        FiltroPeriodo.tarde => horaInt >= 12 && horaInt < 18,
        FiltroPeriodo.noite => horaInt >= 18 && horaInt <= 23,
        FiltroPeriodo.todos => true,
      };
    }).toList();
  }
}
