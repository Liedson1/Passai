import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passai/domain/entities/horario.dart';
import 'package:passai/domain/entities/rota.dart';
import 'package:passai/domain/repositories/rotas_repository.dart';
import 'package:passai/presentation/pages/horarios/horarios_page.dart';
import 'package:passai/presentation/providers/rotas_provider.dart';

class FakeRotasRepository implements RotasRepository {
  @override
  Future<List<String>> buscarCidades({String? termo}) async => ['Água Branca', 'Delmiro Gouveia'];

  @override
  Future<List<Rota>> buscarTodasAsRotas() async => [];

  @override
  Future<List<Horario>> buscarHorarios({
    required int rotaId,
    required Sentido sentido,
  }) async {
    if (sentido == Sentido.ida) {
      return [
        const Horario(id: 1, hora: '06:00', sentido: Sentido.ida),
        const Horario(id: 2, hora: '07:30', sentido: Sentido.ida),
      ];
    } else {
      return [
        const Horario(id: 3, hora: '14:00', sentido: Sentido.volta),
      ];
    }
  }

  @override
  Future<List<Horario>> buscarHorariosPorData({
    required int rotaId,
    required Sentido sentido,
    required DateTime data,
  }) async {
    return buscarHorarios(rotaId: rotaId, sentido: sentido);
  }
}

void main() {
  group('HorariosPage Widget Tests', () {
    const rotaMock = Rota(
      id: 1,
      linha: '28',
      origem: 'Água Branca',
      destino: 'Delmiro Gouveia',
      diasOperacao: 'Segunda a Domingo',
      tarifa: 15.5,
    );

    testWidgets('Deve exibir horários de IDA ao carregar com initialSentido.ida',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            rotasRepositoryProvider.overrideWithValue(FakeRotasRepository()),
          ],
          child: const MaterialApp(
            home: HorariosPage(
              rota: rotaMock,
              initialSentido: Sentido.ida,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Água Branca'), findsAtLeastNWidgets(1));
      expect(find.text('Delmiro Gouveia'), findsAtLeastNWidgets(1));
      expect(find.text('Linha 28'), findsOneWidget);
      expect(find.text('06:00'), findsOneWidget);
      expect(find.text('07:30'), findsOneWidget);
    });

    testWidgets('Deve exibir horários de VOLTA ao carregar com initialSentido.volta',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            rotasRepositoryProvider.overrideWithValue(FakeRotasRepository()),
          ],
          child: const MaterialApp(
            home: HorariosPage(
              rota: rotaMock,
              initialSentido: Sentido.volta,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('14:00'), findsOneWidget);
      expect(find.text('06:00'), findsNothing);
    });
  });
}
