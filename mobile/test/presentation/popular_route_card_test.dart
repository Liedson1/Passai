import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passai/presentation/widgets/popular_route_card.dart';

void main() {
  group('PopularRouteCard Widget Tests', () {
    testWidgets('Deve renderizar dados da rota popular e acionar onVerDetalhes ao clicar em Ver Mapa',
        (tester) async {
      bool clicouDetalhes = false;
      bool clicouCard = false;

      const route = PopularRoute(
        from: 'Arapiraca',
        to: 'Maceió',
        via: 'via Litoral',
        price: 'R\$ 36,00',
        subtitle: 'Dois maiores polos do estado',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PopularRouteCard(
              route: route,
              onTap: () => clicouCard = true,
              onVerDetalhes: () => clicouDetalhes = true,
            ),
          ),
        ),
      );

      expect(find.text('Arapiraca'), findsOneWidget);
      expect(find.text('Maceió (via Litoral)'), findsOneWidget);
      expect(find.text('R\$ 36,00'), findsOneWidget);
      expect(find.text('Dois maiores polos do estado'), findsOneWidget);
      expect(find.text('Ver no Mapa'), findsOneWidget);
      expect(find.text('Ver Horários'), findsOneWidget);

      await tester.tap(find.text('Ver no Mapa'));
      await tester.pump();

      expect(clicouDetalhes, isTrue);
      expect(clicouCard, isFalse);

      await tester.tap(find.text('Ver Horários'));
      await tester.pump();

      expect(clicouCard, isTrue);
    });
  });
}
