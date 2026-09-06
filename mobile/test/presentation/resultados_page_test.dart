import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:passai/core/constants/app_constants.dart';
import 'package:passai/domain/entities/horario.dart';
import 'package:passai/domain/entities/rota.dart';
import 'package:passai/domain/repositories/rotas_repository.dart';
import 'package:passai/presentation/pages/resultados/resultados_page.dart';
import 'package:passai/presentation/providers/rotas_provider.dart';

class FakeRotasRepository implements RotasRepository {
  @override
  Future<List<String>> buscarCidades({String? termo}) async => [
        'Olho d\'Água das Flores',
        'Arapiraca',
      ];

  @override
  Future<List<Rota>> buscarTodasAsRotas() async => [];

  @override
  Future<List<Horario>> buscarHorarios({
    required int rotaId,
    required Sentido sentido,
  }) async =>
      [
        const Horario(
          id: 1,
          hora: '05:30',
          sentido: Sentido.ida,
          nomeRota: 'Olho d\'Água das Flores x Arapiraca',
          preco: 15.0,
        ),
      ];

  @override
  Future<List<Horario>> buscarHorariosPorData({
    required int rotaId,
    required Sentido sentido,
    required DateTime data,
  }) async =>
      buscarHorarios(rotaId: rotaId, sentido: sentido);
}

void main() {
  group('ResultadosPage Widget Tests', () {
    const rotaMock = Rota(
      id: 54,
      linha: 'Olho d\'Água das Flores - Arapiraca',
      origem: 'Olho d\'Água das Flores',
      destino: 'Arapiraca',
      diasOperacao: 'Diariamente',
    );

    testWidgets('Deve exibir botão de voltar com tooltip e rota correta',
        (tester) async {
      final router = GoRouter(
        initialLocation: AppRoutes.resultados,
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const Scaffold(
              body: Text('Home Page Real'),
            ),
          ),
          GoRoute(
            path: AppRoutes.resultados,
            builder: (context, state) => const ResultadosPage(
              args: ResultadosArgs(rota: rotaMock, sentido: Sentido.ida),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            rotasRepositoryProvider.overrideWithValue(FakeRotasRepository()),
          ],
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verifica exibição dos nomes corretos da busca
      expect(find.text('Olho d\'Água das Flores'), findsOneWidget);
      expect(find.text('Arapiraca'), findsOneWidget);

      // Verifica presença do botão voltar
      final backButton = find.byTooltip('Voltar');
      expect(backButton, findsOneWidget);

      // Toca no botão voltar
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      // Deve navegar para o Home Page sem manter telas antigas no stack
      expect(find.text('Home Page Real'), findsOneWidget);
    });
  });
}
