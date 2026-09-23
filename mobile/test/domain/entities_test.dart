import 'package:flutter_test/flutter_test.dart';
import 'package:passai/core/utils/dias_funcionamento_parser.dart';
import 'package:passai/domain/entities/alteracao.dart';
import 'package:passai/domain/entities/horario.dart';
import 'package:passai/domain/entities/rota.dart';

void main() {
  group('Entidades de Domínio', () {
    test('Horario.alterado deve ser false quando não há alteração', () {
      const horario = Horario(
        id: 1,
        hora: '07:00',
        sentido: Sentido.ida,
      );

      expect(horario.alterado, isFalse);
    });

    test('Horario.alterado deve ser true quando há alteração', () {
      const horario = Horario(
        id: 1,
        hora: '07:20',
        sentido: Sentido.ida,
        alteracao: Alteracao(
          id: 10,
          horaOriginal: '07:00',
          horaNova: '07:20',
          motivo: 'Problema mecânico',
        ),
      );

      expect(horario.alterado, isTrue);
      expect(horario.alteracao?.motivo, 'Problema mecânico');
    });

    test('Rota deve instanciar com os valores corretos', () {
      const rota = Rota(
        id: 1,
        linha: '28',
        origem: 'Água Branca',
        destino: 'Delmiro Gouveia',
        diasOperacao: 'Segunda a Domingo',
        distanciaKm: 64,
        tarifa: 12.00,
      );

      expect(rota.id, 1);
      expect(rota.linha, '28');
      expect(rota.origem, 'Água Branca');
      expect(rota.destino, 'Delmiro Gouveia');
      expect(rota.distanciaKm, 64);
      expect(rota.tarifa, 12.00);
    });

    test('Horario.operaNoDia deve filtrar corretamente por dia da semana (RN10)', () {
      // 2026-09-07 é uma Segunda-feira (weekday = 1)
      final segunda = DateTime(2026, 9, 7);
      // 2026-09-12 é um Sábado (weekday = 6)
      final sabado = DateTime(2026, 9, 12);
      // 2026-09-13 é um Domingo (weekday = 7)
      final domingo = DateTime(2026, 9, 13);

      const hDiario = Horario(
        id: 1,
        hora: '07:00',
        sentido: Sentido.ida,
        diasFuncionamento: 'Diariamente (Segunda a Domingo)',
      );
      expect(hDiario.operaNoDia(segunda), isTrue);
      expect(hDiario.operaNoDia(sabado), isTrue);
      expect(hDiario.operaNoDia(domingo), isTrue);

      const hSegSex = Horario(
        id: 2,
        hora: '08:00',
        sentido: Sentido.ida,
        diasFuncionamento: 'Segunda a Sexta',
      );
      expect(hSegSex.operaNoDia(segunda), isTrue);
      expect(hSegSex.operaNoDia(sabado), isFalse);
      expect(hSegSex.operaNoDia(domingo), isFalse);

      const hSabado = Horario(
        id: 3,
        hora: '09:00',
        sentido: Sentido.ida,
        diasFuncionamento: 'Sábado',
      );
      expect(hSabado.operaNoDia(segunda), isFalse);
      expect(hSabado.operaNoDia(sabado), isTrue);
      expect(hSabado.operaNoDia(domingo), isFalse);

      const hDomingo = Horario(
        id: 4,
        hora: '10:00',
        sentido: Sentido.ida,
        diasFuncionamento: 'Domingo',
      );
      expect(hDomingo.operaNoDia(segunda), isFalse);
      expect(hDomingo.operaNoDia(sabado), isFalse);
      expect(hDomingo.operaNoDia(domingo), isTrue);
    });

    // ── Testes de igualdade estrutural ──────────────────────────────────────

    test('Horario == deve retornar true para dois objetos com mesmos dados', () {
      const h1 = Horario(id: 1, hora: '06:00', sentido: Sentido.ida);
      const h2 = Horario(id: 1, hora: '06:00', sentido: Sentido.ida);
      expect(h1, equals(h2));
      expect(h1.hashCode, equals(h2.hashCode));
    });

    test('Horario == deve retornar false quando id difere', () {
      const h1 = Horario(id: 1, hora: '06:00', sentido: Sentido.ida);
      const h2 = Horario(id: 2, hora: '06:00', sentido: Sentido.ida);
      expect(h1, isNot(equals(h2)));
    });

    test('Rota == deve retornar true para dois objetos com mesmos dados', () {
      const r1 = Rota(
        id: 1,
        linha: '28',
        origem: 'Água Branca',
        destino: 'Delmiro Gouveia',
        diasOperacao: 'Segunda a Domingo',
      );
      const r2 = Rota(
        id: 1,
        linha: '28',
        origem: 'Água Branca',
        destino: 'Delmiro Gouveia',
        diasOperacao: 'Segunda a Domingo',
      );
      expect(r1, equals(r2));
      expect(r1.hashCode, equals(r2.hashCode));
    });

    test('Alteracao == deve retornar true para dois objetos com mesmos dados', () {
      const a1 = Alteracao(
        id: 10,
        horaOriginal: '06:00',
        horaNova: '06:30',
        motivo: 'Pneu furado',
      );
      const a2 = Alteracao(
        id: 10,
        horaOriginal: '06:00',
        horaNova: '06:30',
        motivo: 'Pneu furado',
      );
      expect(a1, equals(a2));
      expect(a1.hashCode, equals(a2.hashCode));
    });
  });

  // ── Testes do DiasFuncionamentoParser ───────────────────────────────────

  group('DiasFuncionamentoParser', () {
    // Dias de referência
    final segunda = DateTime(2026, 9, 7);  // weekday = 1
    final terca   = DateTime(2026, 9, 8);  // weekday = 2
    final quarta  = DateTime(2026, 9, 9);  // weekday = 3
    final quinta  = DateTime(2026, 9, 10); // weekday = 4
    final sexta   = DateTime(2026, 9, 11); // weekday = 5
    final sabado  = DateTime(2026, 9, 12); // weekday = 6
    final domingo = DateTime(2026, 9, 13); // weekday = 7

    bool opera(String dias, DateTime data) =>
        DiasFuncionamentoParser.opera(dias, data);

    test('Diariamente opera em todos os dias', () {
      for (final d in [segunda, terca, quarta, quinta, sexta, sabado, domingo]) {
        expect(opera('Diariamente (Segunda a Domingo)', d), isTrue, reason: 'Falhou em $d');
      }
    });

    test('Segunda a Sexta opera de Seg a Sex, não opera Sáb e Dom', () {
      expect(opera('Segunda a Sexta', segunda), isTrue);
      expect(opera('Segunda a Sexta', sexta),   isTrue);
      expect(opera('Segunda a Sexta', sabado),  isFalse);
      expect(opera('Segunda a Sexta', domingo), isFalse);
    });

    test('Segunda a Sábado opera de Seg a Sáb, não opera Dom', () {
      expect(opera('Segunda a Sábado', segunda), isTrue);
      expect(opera('Segunda a Sábado', sabado),  isTrue);
      expect(opera('Segunda a Sábado', domingo), isFalse);
    });

    test('Terça a Domingo opera de Ter a Dom, não opera Seg', () {
      expect(opera('Terça a Domingo', terca),   isTrue);
      expect(opera('Terça a Domingo', domingo), isTrue);
      expect(opera('Terça a Domingo', segunda), isFalse);
    });

    test('Quarta, Sexta e Sábado — bug fix: opera apenas em Qua, Sex, Sáb', () {
      expect(opera('Quarta, Sexta e Sábado', quarta), isTrue,  reason: 'Quarta deveria operar');
      expect(opera('Quarta, Sexta e Sábado', sexta),  isTrue,  reason: 'Sexta deveria operar');
      expect(opera('Quarta, Sexta e Sábado', sabado), isTrue,  reason: 'Sábado deveria operar');
      // Dias que NÃO devem operar (bug original incluía Segunda e Terça)
      expect(opera('Quarta, Sexta e Sábado', segunda), isFalse, reason: 'Segunda NÃO deveria operar');
      expect(opera('Quarta, Sexta e Sábado', terca),   isFalse, reason: 'Terça NÃO deveria operar');
      expect(opera('Quarta, Sexta e Sábado', quinta),  isFalse, reason: 'Quinta NÃO deveria operar');
      expect(opera('Quarta, Sexta e Sábado', domingo), isFalse, reason: 'Domingo NÃO deveria operar');
    });

    test('Quarta e Sexta opera apenas em Qua e Sex', () {
      expect(opera('Quarta e Sexta', quarta), isTrue);
      expect(opera('Quarta e Sexta', sexta),  isTrue);
      expect(opera('Quarta e Sexta', terca),  isFalse);
      expect(opera('Quarta e Sexta', sabado), isFalse);
    });

    test('Dias isolados operam somente no dia correto', () {
      expect(opera('Segunda-feira', segunda), isTrue);
      expect(opera('Segunda-feira', terca),   isFalse);
      expect(opera('Quinta-feira',  quinta),  isTrue);
      expect(opera('Quinta-feira',  sexta),   isFalse);
      expect(opera('Sábado',        sabado),  isTrue);
      expect(opera('Sábado',        domingo), isFalse);
      expect(opera('Domingo',       domingo), isTrue);
      expect(opera('Domingo',       sabado),  isFalse);
    });
  });
}
