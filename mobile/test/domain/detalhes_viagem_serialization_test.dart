import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:passai/domain/entities/detalhes_viagem.dart';

void main() {
  group('DetalhesViagem Serialization Tests (Schema do Banco de Dados)', () {
    test('Deve desserializar com sucesso os dados reais do banco (rotas, horarios, paradas)', () {
      final file = File('../docs/exemplo_detalhes_viagem.json');
      expect(file.existsSync(), isTrue, reason: 'Arquivo exemplo_detalhes_viagem.json deve existir');

      final content = file.readAsStringSync();
      final jsonMap = jsonDecode(content) as Map<String, dynamic>;

      final detalhes = DetalhesViagem.fromJson(jsonMap);

      expect(detalhes.codigo, equals("Olho d'Água das Flores - Arapiraca"));
      expect(detalhes.origem, equals('Arapiraca'));
      expect(detalhes.destino, equals("Olho d'Água das Flores"));
      expect(detalhes.preco, equals(r'R$ 28,00'));
      expect(detalhes.horaSaida, equals('05:15'));
      expect(detalhes.distancia, equals('85.0 km'));
      expect(detalhes.diasOperacao, equals('Segunda a Domingo'));
      expect(detalhes.seccionamentos, equals('Jacaré dos Homens, Jaramataia'));
      expect(detalhes.veiculoNumero, equals('Van 12'));
      expect(detalhes.status, equals('No Horário'));
      expect(detalhes.alterado, isFalse);

      // Validação do itinerário vindo de paradas_rota
      expect(detalhes.itinerario.length, equals(4));
      expect(detalhes.itinerario[0].parada, equals('Arapiraca'));
      expect(detalhes.itinerario[1].parada, equals('Jaramataia'));
      expect(detalhes.itinerario[2].parada, equals('Jacaré dos Homens'));
      expect(detalhes.itinerario[3].parada, equals("Olho d'Água das Flores"));

      // Teste de conversão para JSON (toJson)
      final serialized = detalhes.toJson();
      expect(serialized['rota']['linha'], equals("Olho d'Água das Flores - Arapiraca"));
      expect(serialized['rota']['tarifa'], equals(r'R$ 28,00'));
      expect((serialized['paradas'] as List).length, equals(4));
    });

    test('Deve desserializar alteração operacional ativa no dia (RN03/RN04/RN06)', () {
      final jsonComAlteracao = {
        'viagem': {
          'rota': {
            'id': 54,
            'linha': "Olho d'Água das Flores - Arapiraca",
            'origem': 'Arapiraca',
            'destino': "Olho d'Água das Flores",
            'tarifa': 28.00,
          },
          'horario': {
            'hora': '05:15',
            'sentido': 'IDA',
          },
          'alteracao': {
            'ativa': true,
            'hora_original': '05:15',
            'hora_nova': '05:35',
            'van_original': 'Van 12',
            'van_substituta': 'Van 18',
            'motivo': 'Problema mecânico no veículo',
            'data_alteracao': '2026-09-24',
          },
          'paradas': [
            {'ordem': 1, 'cidade': 'Arapiraca', 'descricao': 'Terminal'},
            {'ordem': 2, 'cidade': "Olho d'Água das Flores", 'descricao': 'Chegada'},
          ],
        },
      };

      final detalhes = DetalhesViagem.fromJson(jsonComAlteracao);
      expect(detalhes.alterado, isTrue);
      expect(detalhes.horaSaida, equals('05:35'));
      expect(detalhes.horaOriginal, equals('05:15'));
      expect(detalhes.horaNova, equals('05:35'));
      expect(detalhes.status, equals('Horário Alterado'));
      expect(detalhes.vanOriginal, equals('Van 12'));
      expect(detalhes.vanSubstituta, equals('Van 18'));
      expect(detalhes.veiculoNumero, equals('Van 18'));
      expect(detalhes.alteracaoMotivo, equals('Problema mecânico no veículo'));
    });
  });
}
