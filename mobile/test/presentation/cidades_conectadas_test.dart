import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passai/domain/entities/horario.dart';
import 'package:passai/domain/entities/rota.dart';
import 'package:passai/domain/repositories/rotas_repository.dart';
import 'package:passai/presentation/providers/rotas_provider.dart';

class MockRotasRepository implements RotasRepository {
  @override
  Future<List<String>> buscarCidades({String? termo}) async {
    return ['Água Branca', 'Delmiro Gouveia', 'Maceió', 'Piranhas', 'Inhapi'];
  }

  @override
  Future<List<Rota>> buscarTodasAsRotas() async {
    return [
      const Rota(
        id: 1,
        linha: '28',
        origem: 'Água Branca',
        destino: 'Delmiro Gouveia',
        diasOperacao: 'Segunda a Domingo',
      ),
      const Rota(
        id: 2,
        linha: '35',
        origem: 'Delmiro Gouveia',
        destino: 'Piranhas',
        diasOperacao: 'Segunda a Domingo',
      ),
      const Rota(
        id: 3,
        linha: '40',
        origem: 'Delmiro Gouveia',
        destino: 'Inhapi',
        diasOperacao: 'Segunda a Sábado',
      ),
    ];
  }

  @override
  Future<List<Horario>> buscarHorarios({
    required int rotaId,
    required Sentido sentido,
  }) async =>
      [];

  @override
  Future<List<Horario>> buscarHorariosPorData({
    required int rotaId,
    required Sentido sentido,
    required DateTime data,
  }) async =>
      [];
}

void main() {
  group('cidadesConectadasProvider Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          rotasRepositoryProvider.overrideWithValue(MockRotasRepository()),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('Deve retornar todas as cidades quando cidadeBase for nula ou vazia', () async {
      await container.read(cidadesProvider.future);
      await container.read(todasAsRotasProvider.future);

      final conectadasNull = container.read(cidadesConectadasProvider(null));
      expect(conectadasNull, containsAll(['Água Branca', 'Delmiro Gouveia', 'Maceió', 'Piranhas', 'Inhapi']));

      final conectadasEmpty = container.read(cidadesConectadasProvider(''));
      expect(conectadasEmpty, containsAll(['Água Branca', 'Delmiro Gouveia', 'Maceió', 'Piranhas', 'Inhapi']));
    });

    test('Deve retornar apenas cidades com rotas diretas ligadas a Delmiro Gouveia', () async {
      await container.read(cidadesProvider.future);
      await container.read(todasAsRotasProvider.future);

      final conectadas = container.read(cidadesConectadasProvider('Delmiro Gouveia'));
      // Delmiro está ligada a: Água Branca, Piranhas, Inhapi
      expect(conectadas, containsAll(['Inhapi', 'Piranhas', 'Água Branca']));
      expect(conectadas, isNot(contains('Maceió')));
    });

    test('Deve considerar conexão bidirecional (quando cidade é origem ou destino)', () async {
      await container.read(cidadesProvider.future);
      await container.read(todasAsRotasProvider.future);

      final conectadasAguaBranca = container.read(cidadesConectadasProvider('Água Branca'));
      expect(conectadasAguaBranca, contains('Delmiro Gouveia'));
      expect(conectadasAguaBranca, isNot(contains('Maceió')));
    });

    test('Deve retornar todas as cidades como fallback se a cidade não tiver rotas cadastradas', () async {
      await container.read(cidadesProvider.future);
      await container.read(todasAsRotasProvider.future);

      final conectadasMaceio = container.read(cidadesConectadasProvider('Maceió'));
      expect(conectadasMaceio, containsAll(['Água Branca', 'Delmiro Gouveia', 'Maceió', 'Piranhas', 'Inhapi']));
    });
  });
}
