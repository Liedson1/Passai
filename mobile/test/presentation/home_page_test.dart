import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passai/core/errors/exceptions.dart';
import 'package:passai/domain/entities/horario.dart';
import 'package:passai/domain/entities/rota.dart';
import 'package:passai/domain/repositories/rotas_repository.dart';
import 'package:passai/presentation/pages/home/home_page.dart';
import 'package:passai/presentation/providers/rotas_provider.dart';

class FakeHomeRotasRepository implements RotasRepository {
  @override
  Future<List<String>> buscarCidades({String? termo}) async {
    final cidades = ['Água Branca', 'Delmiro Gouveia', 'Maceió', 'Anadia'];
    if (termo == null || termo.isEmpty) return cidades;
    final t = termo.toLowerCase();
    return cidades.where((c) => c.toLowerCase().contains(t)).toList();
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
  group('HomePage Widget Tests', () {
    testWidgets('Deve exibir campos de busca e atalhos de cidades',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            rotasRepositoryProvider
                .overrideWithValue(FakeHomeRotasRepository()),
          ],
          child: const MaterialApp(
            home: HomePage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('ORIGEM'), findsOneWidget);
      expect(find.text('DESTINO'), findsOneWidget);
      expect(find.text('Buscar Vans'), findsOneWidget);
    });

    testWidgets('Deve habilitar botão Buscar Vans ao preencher origem e destino por digitação',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            rotasRepositoryProvider
                .overrideWithValue(FakeHomeRotasRepository()),
          ],
          child: const MaterialApp(
            home: HomePage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Inicialmente o botão Buscar Vans está desabilitado
      final buttonFinder = find.widgetWithText(ElevatedButton, 'Buscar Vans');
      expect(tester.widget<ElevatedButton>(buttonFinder).onPressed, isNull);

      // Digita no primeiro TextField (Origem)
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'Água Branca');
      await tester.pumpAndSettle();

      // Botão ainda desabilitado (falta destino)
      expect(tester.widget<ElevatedButton>(buttonFinder).onPressed, isNull);

      // Digita no segundo TextField (Destino)
      await tester.enterText(textFields.at(1), 'Delmiro Gouveia');
      await tester.pumpAndSettle();

      // Agora o botão DEVE estar habilitado
      expect(tester.widget<ElevatedButton>(buttonFinder).onPressed, isNotNull);
    });

    testWidgets('Deve trocar origem e destino ao tocar no botão swap',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            rotasRepositoryProvider
                .overrideWithValue(FakeHomeRotasRepository()),
          ],
          child: const MaterialApp(
            home: HomePage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'Água Branca');
      await tester.enterText(textFields.at(1), 'Maceió');
      await tester.pumpAndSettle();

      // Toca no botão swap
      await tester.tap(find.byIcon(Icons.swap_vert));
      await tester.pumpAndSettle();

      expect(tester.widget<TextField>(textFields.at(0)).controller?.text, 'Maceió');
      expect(tester.widget<TextField>(textFields.at(1)).controller?.text, 'Água Branca');
    });

    testWidgets('Deve exibir as 5 rotas populares em destaque e suas descrições',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            rotasRepositoryProvider
                .overrideWithValue(FakeHomeRotasRepository()),
          ],
          child: const MaterialApp(
            home: HomePage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verifica título da seção
      expect(find.text('Rotas Populares'), findsOneWidget);
      expect(find.text('5 principais'), findsOneWidget);

      // Verifica presença das rotas em destaque
      expect(find.textContaining('Arapiraca'), findsAtLeastNWidgets(2));
      expect(find.textContaining('Olho d\'Água das Flores'), findsOneWidget);
      expect(find.textContaining('Palmeira dos Índios'), findsOneWidget);
      expect(find.textContaining('Delmiro Gouveia'), findsAtLeastNWidgets(2));
      expect(find.textContaining('Água Branca'), findsAtLeastNWidgets(1));
      expect(find.text('Maceió (via Litoral)'), findsOneWidget);
      expect(find.text('Delmiro Gouveia (via Lagoa das Pedras)'), findsOneWidget);

      // Verifica descrições solicitadas
      expect(
        find.text('Dois maiores polos do estado • via Litoral'),
        findsOneWidget,
      );
      expect(
        find.text('Importante ligação do Sertão'),
        findsOneWidget,
      );
      expect(
        find.text('Cidades próximas, fluxo constante'),
        findsOneWidget,
      );
      expect(
        find.text('Linha tradicional do Alto Sertão'),
        findsOneWidget,
      );
      expect(
        find.text('Ligação Alto Sertão ao Agreste'),
        findsOneWidget,
      );
    });

    testWidgets(
        'Deve exibir erro inline e não SnackBar quando origem e destino forem iguais',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            rotasRepositoryProvider
                .overrideWithValue(FakeHomeRotasRepository()),
          ],
          child: const MaterialApp(
            home: HomePage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'Maceió');
      await tester.enterText(textFields.at(1), 'Maceió');
      await tester.pumpAndSettle();

      final buttonFinder = find.widgetWithText(ElevatedButton, 'Buscar Vans');
      await tester.tap(buttonFinder);
      await tester.pumpAndSettle();

      // Confirma que não há SnackBar
      expect(find.byType(SnackBar), findsNothing);

      // Confirma que a mensagem aparece inline na tela
      expect(
        find.text('A origem e o destino devem ser cidades diferentes.'),
        findsOneWidget,
      );
    });

    testWidgets(
        'Deve exibir erro inline quando nenhuma van direta for encontrada',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            rotasRepositoryProvider
                .overrideWithValue(FakeHomeRotasRepository()),
          ],
          child: const MaterialApp(
            home: HomePage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'Anadia');
      await tester.enterText(textFields.at(1), 'Delmiro Gouveia');
      await tester.pumpAndSettle();

      final buttonFinder = find.widgetWithText(ElevatedButton, 'Buscar Vans');
      await tester.tap(buttonFinder);
      await tester.pumpAndSettle();

      // Confirma que não há SnackBar
      expect(find.byType(SnackBar), findsNothing);

      // Confirma mensagem inline
      expect(
        find.text(
            'Nenhuma van direta cadastrada entre Anadia e Delmiro Gouveia.'),
        findsOneWidget,
      );
    });

    testWidgets('Deve exibir banner offline quando ocorrer erro de conexão',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            todasAsRotasProvider
                .overrideWith((ref) => throw const NetworkException()),
            cidadesProvider
                .overrideWith((ref) => throw const NetworkException()),
          ],
          child: const MaterialApp(
            home: HomePage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Sem conexão com a internet'), findsOneWidget);
      expect(
        find.text(
            'O Passaí precisa de conexão ativa para consultar horários atualizados.'),
        findsOneWidget,
      );
    });
  });
}
