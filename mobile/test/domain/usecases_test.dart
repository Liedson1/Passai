import 'package:flutter_test/flutter_test.dart';
import 'package:passai/domain/entities/horario.dart';
import 'package:passai/domain/entities/rota.dart';
import 'package:passai/domain/repositories/rotas_repository.dart';
import 'package:passai/domain/usecases/buscar_horarios.dart';
import 'package:passai/domain/usecases/buscar_horarios_por_data.dart';
import 'package:passai/domain/usecases/buscar_rotas.dart';

class MockRotasRepository implements RotasRepository {
  final List<Rota> rotasFixture = [
    const Rota(
      id: 1,
      linha: '28',
      origem: 'Água Branca',
      destino: 'Delmiro Gouveia',
      diasOperacao: 'Segunda a Domingo',
    ),
    const Rota(
      id: 2,
      linha: '29',
      origem: 'Água Branca',
      destino: 'Maceió',
      diasOperacao: 'Segunda a Sábado',
    ),
  ];

  final List<Horario> horariosFixture = [
    const Horario(id: 1, hora: '06:00', sentido: Sentido.ida),
    const Horario(id: 2, hora: '06:30', sentido: Sentido.ida),
  ];

  @override
  Future<List<Rota>> buscarTodasAsRotas() async => rotasFixture;

  @override
  Future<List<String>> buscarCidades({String? termo}) async => ['Água Branca', 'Delmiro Gouveia', 'Maceió'];

  @override
  Future<List<Horario>> buscarHorarios({
    required int rotaId,
    required Sentido sentido,
  }) async => horariosFixture;

  @override
  Future<List<Horario>> buscarHorariosPorData({
    required int rotaId,
    required Sentido sentido,
    required DateTime data,
  }) async => horariosFixture;
}

void main() {
  group('Casos de Uso', () {
    late MockRotasRepository repository;

    setUp(() {
      repository = MockRotasRepository();
    });

    test('BuscarRotas deve filtrar por origem e destino case-insensitively', () async {
      final useCase = BuscarRotas(repository);

      final resultado = await useCase(
        origem: 'água branca',
        destino: 'DELMIRO GOUVEIA',
      );

      expect(resultado.length, 1);
      expect(resultado.first.id, 1);
    });

    test('BuscarRotas deve encontrar rotas mesmo sem acentos digitados pelo usuário', () async {
      final useCase = BuscarRotas(repository);

      final resultado = await useCase(
        origem: 'agua branca',
        destino: 'maceio',
      );

      expect(resultado.length, 1);
      expect(resultado.first.id, 2);
    });

    test('BuscarRotas deve retornar lista vazia se não houver rota correspondente', () async {
      final useCase = BuscarRotas(repository);

      final resultado = await useCase(
        origem: 'Maceió',
        destino: 'Delmiro Gouveia',
      );

      expect(resultado, isEmpty);
    });

    test('buscarComSentido deve identificar Sentido.ida na busca direta', () async {
      final useCase = BuscarRotas(repository);

      final resultados = await useCase.buscarComSentido(
        origem: 'Água Branca',
        destino: 'Delmiro Gouveia',
      );

      expect(resultados.length, 1);
      expect(resultados.first.rota.id, 1);
      expect(resultados.first.sentido, Sentido.ida);
    });

    test('buscarComSentido deve identificar Sentido.volta na busca invertida', () async {
      final useCase = BuscarRotas(repository);

      final resultados = await useCase.buscarComSentido(
        origem: 'Delmiro Gouveia',
        destino: 'Água Branca',
      );

      expect(resultados.length, 1);
      expect(resultados.first.rota.id, 1);
      expect(resultados.first.sentido, Sentido.volta);
    });

    test('call deve retornar rota tanto na ida quanto na volta', () async {
      final useCase = BuscarRotas(repository);

      final resultadoVolta = await useCase(
        origem: 'Delmiro Gouveia',
        destino: 'Água Branca',
      );

      expect(resultadoVolta.length, 1);
      expect(resultadoVolta.first.id, 1);
    });

    test('BuscarHorarios deve delegar corretamente para o repositório', () async {
      final useCase = BuscarHorarios(repository);

      final resultado = await useCase(
        rotaId: 1,
        sentido: Sentido.ida,
      );

      expect(resultado.length, 2);
      expect(resultado.first.hora, '06:00');
    });

    test('BuscarHorariosPorData deve delegar corretamente para o repositório com data', () async {
      final useCase = BuscarHorariosPorData(repository);
      final data = DateTime(2026, 9, 7);

      final resultado = await useCase(
        rotaId: 1,
        sentido: Sentido.ida,
        data: data,
      );

      expect(resultado.length, 2);
      expect(resultado.first.hora, '06:00');
    });

    // ── Testes de BuscarRotas.normalizar ───────────────────────────────────

    group('BuscarRotas.normalizar', () {
      test('remove acentos de todas as vogais', () {
        expect(BuscarRotas.normalizar('ÁáÀàÃãÂâÄä'), equals('aaaaaaaaaa'));
        expect(BuscarRotas.normalizar('ÉéÈèÊêËë'),   equals('eeeeeeee'));
        expect(BuscarRotas.normalizar('ÍíÌìÎîÏï'),   equals('iiiiiiii'));
        expect(BuscarRotas.normalizar('ÓóÒòÕõÔôÖö'), equals('oooooooooo'));
        expect(BuscarRotas.normalizar('ÚúÙùÛûÜü'),   equals('uuuuuuuu'));
        expect(BuscarRotas.normalizar('Çç'),          equals('cc'));
      });

      test('converte para minúsculas e remove espaços extras', () {
        expect(BuscarRotas.normalizar('  ÁGUA BRANCA  '), equals('agua branca'));
      });

      test('permite busca sem acento encontrar cidade com acento', () {
        final maceio = BuscarRotas.normalizar('Maceió');
        final input  = BuscarRotas.normalizar('maceio');
        expect(maceio, equals(input));
      });
    });
  });
}
