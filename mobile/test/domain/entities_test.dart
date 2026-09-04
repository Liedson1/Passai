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
  });
}
