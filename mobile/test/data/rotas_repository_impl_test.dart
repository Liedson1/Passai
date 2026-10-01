import 'package:flutter_test/flutter_test.dart';
import 'package:passai/data/datasources/rotas_remote_datasource.dart';
import 'package:passai/data/models/horario_model.dart';
import 'package:passai/data/models/rota_model.dart';
import 'package:passai/data/repositories/rotas_repository_impl.dart';
import 'package:passai/domain/entities/horario.dart';

class FakeRotasRemoteDatasource extends RotasRemoteDatasource {
  int fetchCidadesCalls = 0;
  int fetchTodasAsRotasCalls = 0;
  int fetchHorariosCalls = 0;
  int fetchHorariosPorDataCalls = 0;

  @override
  Future<List<RotaModel>> fetchTodasAsRotas() async {
    fetchTodasAsRotasCalls++;
    return [
      const RotaModel(
        id: 1,
        linha: 'Linha 1',
        origem: 'Delmiro Gouveia',
        destino: 'Maceió',
        distanciaKm: 300,
        tarifa: 50.0,
        diasOperacao: 'Segunda a Domingo',
      ),
    ];
  }

  @override
  Future<List<String>> fetchCidades({String? termo}) async {
    fetchCidadesCalls++;
    return ['Água Branca', 'Delmiro Gouveia', 'Maceió', 'Piranhas'];
  }

  @override
  Future<List<HorarioModel>> fetchHorarios({
    required int rotaId,
    required String sentido,
    DateTime? dataReferencia,
  }) async {
    fetchHorariosCalls++;
    return [
      const HorarioModel(
        id: 1,
        hora: '07:00',
        sentido: 'IDA',
      ),
    ];
  }

  @override
  Future<List<HorarioModel>> fetchHorariosPorData({
    required int rotaId,
    required String sentido,
    required DateTime data,
  }) async {
    fetchHorariosPorDataCalls++;
    return [
      const HorarioModel(
        id: 2,
        hora: '14:00',
        sentido: 'IDA',
      ),
    ];
  }
}

void main() {
  group('RotasRepositoryImpl Tests (TST-01)', () {
    late FakeRotasRemoteDatasource datasource;
    late RotasRepositoryImpl repository;

    setUp(() {
      datasource = FakeRotasRemoteDatasource();
      repository = RotasRepositoryImpl(datasource);
    });

    test('buscarTodasAsRotas converte models para entidades de dominio', () async {
      final rotas = await repository.buscarTodasAsRotas();
      expect(rotas.length, 1);
      expect(rotas.first.origem, 'Delmiro Gouveia');
      expect(rotas.first.destino, 'Maceió');
      expect(datasource.fetchTodasAsRotasCalls, 1);
    });

    test('buscarCidades usa cache local para chamadas subsequentes e filtra por termo', () async {
      // Primeira chamada: busca do datasource
      final todas = await repository.buscarCidades();
      expect(todas.length, 4);
      expect(datasource.fetchCidadesCalls, 1);

      // Segunda chamada com termo: deve usar o cache e filtrar com TextNormalizer
      final filtradas = await repository.buscarCidades(termo: 'delmiro');
      expect(filtradas, ['Delmiro Gouveia']);
      // Não deve ter chamado o datasource novamente
      expect(datasource.fetchCidadesCalls, 1);

      // Terceira chamada com acento normalizado:
      final comAcento = await repository.buscarCidades(termo: 'agua');
      expect(comAcento, ['Água Branca']);
      expect(datasource.fetchCidadesCalls, 1);
    });

    test('buscarHorarios mapeia Sentido enum para string do banco e retorna entidades', () async {
      final horarios = await repository.buscarHorarios(
        rotaId: 1,
        sentido: Sentido.ida,
      );
      expect(horarios.length, 1);
      expect(horarios.first.hora, '07:00');
      expect(horarios.first.sentido, Sentido.ida);
      expect(datasource.fetchHorariosCalls, 1);
    });

    test('buscarHorariosPorData delega para fetchHorariosPorData com data', () async {
      final horarios = await repository.buscarHorariosPorData(
        rotaId: 1,
        sentido: Sentido.ida,
        data: DateTime(2026, 10, 1),
      );
      expect(horarios.length, 1);
      expect(horarios.first.hora, '14:00');
      expect(datasource.fetchHorariosPorDataCalls, 1);
    });
  });
}
