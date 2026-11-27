import 'package:flutter_test/flutter_test.dart';
import 'package:passai/core/utils/dias_funcionamento_parser.dart';

void main() {
  group('DiasFuncionamentoParser', () {
    // 2026-09-28 é Segunda-feira (weekday = 1)
    // 2026-09-29 é Terça-feira (weekday = 2)
    // 2026-09-30 é Quarta-feira (weekday = 3)
    // 2026-10-01 é Quinta-feira (weekday = 4)
    // 2026-10-02 é Sexta-feira (weekday = 5)
    // 2026-10-03 é Sábado (weekday = 6)
    // 2026-10-04 é Domingo (weekday = 7)

    final segunda = DateTime(2026, 9, 28);
    final terca = DateTime(2026, 9, 29);
    final quarta = DateTime(2026, 9, 30);
    final quinta = DateTime(2026, 10, 1);
    final sexta = DateTime(2026, 10, 2);
    final sabado = DateTime(2026, 10, 3);
    final domingo = DateTime(2026, 10, 4);

    test('deve reconhecer Diariamente e Segunda a Domingo em qualquer dia', () {
      for (final dia in [segunda, terca, quarta, quinta, sexta, sabado, domingo]) {
        expect(DiasFuncionamentoParser.opera('Diariamente', dia), isTrue);
        expect(DiasFuncionamentoParser.opera('Segunda a Domingo', dia), isTrue);
      }
    });

    test('deve reconhecer Segunda a Sexta corretamente', () {
      expect(DiasFuncionamentoParser.opera('Segunda a Sexta', segunda), isTrue);
      expect(DiasFuncionamentoParser.opera('Segunda a Sexta', sexta), isTrue);
      expect(DiasFuncionamentoParser.opera('Segunda a Sexta', sabado), isFalse);
      expect(DiasFuncionamentoParser.opera('Segunda a Sexta', domingo), isFalse);
    });

    test('deve reconhecer Segunda a Sábado corretamente', () {
      expect(DiasFuncionamentoParser.opera('Segunda a Sábado', segunda), isTrue);
      expect(DiasFuncionamentoParser.opera('Segunda a Sábado', sabado), isTrue);
      expect(DiasFuncionamentoParser.opera('Segunda a Sábado', domingo), isFalse);
    });

    test('deve reconhecer Sábado e Domingo e Fim de Semana sem ocultar o Domingo', () {
      expect(DiasFuncionamentoParser.opera('Sábado e Domingo', sabado), isTrue);
      expect(DiasFuncionamentoParser.opera('Sábado e Domingo', domingo), isTrue);
      expect(DiasFuncionamentoParser.opera('Sábado e Domingo', segunda), isFalse);
      expect(DiasFuncionamentoParser.opera('Sábado e Domingo', sexta), isFalse);

      expect(DiasFuncionamentoParser.opera('sabado e domingo', sabado), isTrue);
      expect(DiasFuncionamentoParser.opera('sabado e domingo', domingo), isTrue);

      expect(DiasFuncionamentoParser.opera('Fim de semana', sabado), isTrue);
      expect(DiasFuncionamentoParser.opera('Fim de semana', domingo), isTrue);
      expect(DiasFuncionamentoParser.opera('Fim de semana', quarta), isFalse);
    });

    test('deve reconhecer padrões compostos de feira (Quarta, Sexta e Sábado)', () {
      expect(DiasFuncionamentoParser.opera('Quarta, Sexta e Sábado', quarta), isTrue);
      expect(DiasFuncionamentoParser.opera('Quarta, Sexta e Sábado', sexta), isTrue);
      expect(DiasFuncionamentoParser.opera('Quarta, Sexta e Sábado', sabado), isTrue);
      expect(DiasFuncionamentoParser.opera('Quarta, Sexta e Sábado', segunda), isFalse);
      expect(DiasFuncionamentoParser.opera('Quarta, Sexta e Sábado', quinta), isFalse);
    });

    test('deve reconhecer dias isolados', () {
      expect(DiasFuncionamentoParser.opera('Domingo', domingo), isTrue);
      expect(DiasFuncionamentoParser.opera('Domingo', sabado), isFalse);
      expect(DiasFuncionamentoParser.opera('Sábado', sabado), isTrue);
      expect(DiasFuncionamentoParser.opera('Sábado', domingo), isFalse);
    });
  });
}
