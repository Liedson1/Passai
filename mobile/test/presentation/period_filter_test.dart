import 'package:flutter_test/flutter_test.dart';
import 'package:passai/domain/entities/horario.dart';
import 'package:passai/presentation/providers/resultados_provider.dart';

void main() {
  group('filtrarPorPeriodo Tests', () {
    final horarios = [
      const Horario(id: 1, hora: '04:30', sentido: Sentido.ida),
      const Horario(id: 2, hora: '05:00', sentido: Sentido.ida),
      const Horario(id: 3, hora: '05:30', sentido: Sentido.ida),
      const Horario(id: 4, hora: '06:00', sentido: Sentido.ida),
      const Horario(id: 5, hora: '11:45', sentido: Sentido.ida),
      const Horario(id: 6, hora: '12:00', sentido: Sentido.ida),
      const Horario(id: 7, hora: '14:30', sentido: Sentido.ida),
      const Horario(id: 8, hora: '17:50', sentido: Sentido.ida),
      const Horario(id: 9, hora: '18:00', sentido: Sentido.ida),
      const Horario(id: 10, hora: '20:15', sentido: Sentido.ida),
      const Horario(id: 11, hora: '22:40', sentido: Sentido.ida),
    ];

    test('FiltroPeriodo.todos deve retornar todos os horários', () {
      final resultado = filtrarPorPeriodo(horarios, FiltroPeriodo.todos);
      expect(resultado.length, 11);
    });

    test('FiltroPeriodo.manha deve incluir 04h, 05h, 06h e horários antes das 12h', () {
      final resultado = filtrarPorPeriodo(horarios, FiltroPeriodo.manha);
      final horas = resultado.map((h) => h.hora).toList();

      expect(horas, containsAll(['04:30', '05:00', '05:30', '06:00', '11:45']));
      expect(horas, isNot(contains('12:00')));
      expect(horas, isNot(contains('18:00')));
      expect(resultado.length, 5);
    });

    test('FiltroPeriodo.tarde deve incluir apenas horários entre 12h e 17h59', () {
      final resultado = filtrarPorPeriodo(horarios, FiltroPeriodo.tarde);
      final horas = resultado.map((h) => h.hora).toList();

      expect(horas, containsAll(['12:00', '14:30', '17:50']));
      expect(horas, isNot(contains('05:00')));
      expect(horas, isNot(contains('18:00')));
      expect(resultado.length, 3);
    });

    test('FiltroPeriodo.noite deve incluir apenas horários entre 18h e 23h59 e NUNCA 05h ou madrugada', () {
      final resultado = filtrarPorPeriodo(horarios, FiltroPeriodo.noite);
      final horas = resultado.map((h) => h.hora).toList();

      expect(horas, containsAll(['18:00', '20:15', '22:40']));
      expect(horas, isNot(contains('04:30')));
      expect(horas, isNot(contains('05:00')));
      expect(horas, isNot(contains('05:30')));
      expect(horas, isNot(contains('12:00')));
      expect(resultado.length, 3);
    });
  });
}
