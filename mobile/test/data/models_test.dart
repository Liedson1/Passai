import 'package:flutter_test/flutter_test.dart';
import 'package:passai/data/models/alteracao_model.dart';
import 'package:passai/data/models/horario_model.dart';
import 'package:passai/data/models/rota_model.dart';
import 'package:passai/domain/entities/horario.dart';

void main() {
  group('Models Layer', () {
    test('RotaModel.fromJson com resposta do Supabase', () {
      final json = {
        'id': 1,
        'distancia_km': 64,
        'tarifa': 15.5,
        'origem': {'nome': 'Água Branca'},
        'destino': {'nome': 'Delmiro Gouveia'},
      };

      final model = RotaModel.fromJson(json);
      expect(model.id, 1);
      expect(model.origem, 'Água Branca');
      expect(model.destino, 'Delmiro Gouveia');
      expect(model.distanciaKm, 64);
      expect(model.tarifa, 15.5);

      final entity = model.toEntity();
      expect(entity.origem, 'Água Branca');
      expect(entity.destino, 'Delmiro Gouveia');
    });

    test('HorarioModel.fromJson sem alteração', () {
      final json = {
        'id': 10,
        'hora': '06:30:00',
        'sentido': 'IDA',
        'alteracoes_horario': [],
      };

      final model = HorarioModel.fromJson(json);
      expect(model.id, 10);
      expect(model.hora, '06:30');
      expect(model.alteracao, isNull);

      final entity = model.toEntity();
      expect(entity.hora, '06:30');
      expect(entity.sentido, Sentido.ida);
      expect(entity.alterado, isFalse);
    });

    test('HorarioModel.fromJson com alteração ativa', () {
      final json = {
        'id': 10,
        'hora': '06:00:00',
        'sentido': 'VOLTA',
        'alteracoes_horario': [
          {
            'id': 1,
            'hora_original': '06:00:00',
            'hora_nova': '06:25:00',
            'van_original': 'Van 02',
            'van_substituta': 'Van 05',
            'motivo': 'Pneu furado',
          }
        ],
      };

      final model = HorarioModel.fromJson(json);
      expect(model.hora, '06:25');
      expect(model.alteracao, isNotNull);
      expect(model.alteracao?.horaOriginal, '06:00');

      final entity = model.toEntity();
      expect(entity.hora, '06:25');
      expect(entity.sentido, Sentido.volta);
      expect(entity.alterado, isTrue);
      expect(entity.alteracao?.vanSubstituta, 'Van 05');
    });

    test('AlteracaoModel.fromJson e toEntity', () {
      final json = {
        'id': 5,
        'hora_original': '08:00:00',
        'hora_nova': '08:15:00',
        'van_original': 'Van 1',
        'van_substituta': 'Van 3',
        'motivo': 'Atraso na ida',
      };

      final model = AlteracaoModel.fromJson(json);
      expect(model.horaOriginal, '08:00');
      expect(model.horaNova, '08:15');

      final entity = model.toEntity();
      expect(entity.horaOriginal, '08:00');
      expect(entity.horaNova, '08:15');
      expect(entity.vanOriginal, 'Van 1');
      expect(entity.vanSubstituta, 'Van 3');
      expect(entity.motivo, 'Atraso na ida');
    });

    test('HorarioModel.fromJson ignora alteracao com ativa=false', () {
      final json = {
        'id': 20,
        'hora': '10:00:00',
        'sentido': 'IDA',
        'alteracoes_horario': [
          {
            'id': 2,
            'hora_original': '10:00:00',
            'hora_nova': '10:30:00',
            'ativa': false,
          }
        ],
      };

      final model = HorarioModel.fromJson(json);
      expect(model.hora, '10:00');
      expect(model.alteracao, isNull);

      final entity = model.toEntity();
      expect(entity.alterado, isFalse);
    });

    test('RotaModel.fromJson mapeia seccionamentos e trata distancia_km decimal', () {
      final json = {
        'id': 3,
        'linha': 'Água Branca - Maceió',
        'distancia_km': 306.0,
        'tarifa': 54.50,
        'seccionamentos': 'Passando por São José da Tapera',
        'origem': {'nome': 'Água Branca'},
        'destino': {'nome': 'Maceió'},
      };

      final model = RotaModel.fromJson(json);
      expect(model.linha, 'Água Branca - Maceió');
      expect(model.distanciaKm, 306);
      expect(model.tarifa, 54.50);
      expect(model.seccionamentos, 'Passando por São José da Tapera');

      final entity = model.toEntity();
      expect(entity.seccionamentos, 'Passando por São José da Tapera');
    });

    test('HorarioModel.fromJson mapeia dias_funcionamento corretamente', () {
      final json = {
        'id': 15,
        'hora': '14:30:00',
        'sentido': 'IDA',
        'dias_funcionamento': 'Segunda a Sexta',
      };

      final model = HorarioModel.fromJson(json);
      expect(model.diasFuncionamento, 'Segunda a Sexta');

      final entity = model.toEntity();
      expect(entity.diasFuncionamento, 'Segunda a Sexta');
    });
  });
}
