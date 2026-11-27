import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passai/domain/entities/horario.dart';
import 'package:passai/presentation/widgets/resultado_card.dart';

void main() {
  group('ResultadoCard Widget Tests', () {
    testWidgets('Deve exibir os dados no formato exato do JSON de especificação',
        (tester) async {
      // Mock exatamente no formato do JSON fornecido pelo usuário:
      // {
      //   "horario": "13:00",
      //   "preco": 15.00,
      //   "rota": "Delmiro Gouveia x Piranhas",
      //   "duracao": "45 min",
      //   "paradas": "Direto"
      // }
      const horarioJsonMock = Horario(
        id: 1,
        hora: '13:00',
        sentido: Sentido.ida,
        preco: 15.00,
        duracao: '45 min',
        paradas: 'Direto',
        nomeRota: 'Delmiro Gouveia x Piranhas',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResultadoCard(horario: horarioJsonMock),
          ),
        ),
      );

      // Verifica horário
      expect(find.text('13:00'), findsOneWidget);

      // Verifica preço formatado
      expect(find.text('R\$ 15,00'), findsOneWidget);

      // Verifica nome da rota
      expect(find.text('Delmiro Gouveia x Piranhas'), findsOneWidget);

      // Verifica duração
      expect(find.text('45 min'), findsOneWidget);

      // Verifica paradas
      expect(find.text('Direto'), findsOneWidget);
    });

    testWidgets('Deve exibir variante de rota com paradas conforme JSON',
        (tester) async {
      // Mock do segundo item do JSON:
      // {
      //   "horario": "13:30",
      //   "preco": 18.00,
      //   "rota": "Delmiro Gouveia x Piranhas (via Olho d'Água)",
      //   "duracao": "1h 10m",
      //   "paradas": "4 paradas"
      // }
      const horarioVarianteMock = Horario(
        id: 2,
        hora: '13:30',
        sentido: Sentido.ida,
        preco: 18.00,
        duracao: '1h 10m',
        paradas: '4 paradas',
        nomeRota: "Delmiro Gouveia x Piranhas (via Olho d'Água)",
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResultadoCard(horario: horarioVarianteMock),
          ),
        ),
      );

      expect(find.text('13:30'), findsOneWidget);
      expect(find.text('R\$ 18,00'), findsOneWidget);
      expect(
        find.text("Delmiro Gouveia x Piranhas (via Olho d'Água)"),
        findsOneWidget,
      );
      expect(find.text('1h 10min'), findsOneWidget);
      expect(find.text('4 paradas'), findsOneWidget);
    });

    testWidgets('Deve exibir botão Ver Itinerário e chamar callback ao tocar',
        (tester) async {
      bool clicouDetalhes = false;
      const horarioMock = Horario(
        id: 3,
        hora: '14:00',
        sentido: Sentido.ida,
        preco: 20.00,
        duracao: '50 min',
        paradas: 'Direto',
        nomeRota: 'Arapiraca x Maceió',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResultadoCard(
              horario: horarioMock,
              onVerDetalhes: () => clicouDetalhes = true,
            ),
          ),
        ),
      );

      expect(find.text('Ver Itinerário'), findsOneWidget);
      await tester.tap(find.text('Ver Itinerário'));
      await tester.pump();

      expect(clicouDetalhes, isTrue);
    });
  });
}
