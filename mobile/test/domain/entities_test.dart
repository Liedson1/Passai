import 'package:flutter_test/flutter_test.dart';
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
  });
}
