import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passai/core/theme/app_colors.dart';
import 'package:passai/domain/entities/detalhes_viagem.dart';
import 'package:passai/domain/entities/parada_itinerario.dart';
import 'package:passai/presentation/pages/detalhes_viagem/detalhes_viagem_page.dart';

import '../helpers/mock_http_client.dart';

void main() {
  setUpAll(() {
    HttpOverrides.global = MockTestHttpOverrides();
  });

  tearDownAll(() {
    HttpOverrides.global = null;
  });

  group('DetalhesViagemPage Widget Tests', () {
    testWidgets('Deve exibir nó de chegada com a cor azul (AppColors.secondary)', (tester) async {
      const detalhes = DetalhesViagem(
        codigo: 'V-101',
        preco: r'R$ 36,00',
        rota: 'Arapiraca x Maceió',
        origem: 'Arapiraca',
        destino: 'Maceió',
        horaSaida: '06:00',
        chegadaPrevista: '08:24',
        duracao: '2h 24m',
        itinerario: [
          ParadaItinerario(
            parada: 'Arapiraca',
            horario: '06:00',
            descricao: 'Terminal Rodoviário',
            tipo: 'origem',
            tags: ['Ponto de Partida', 'Embarque'],
          ),
          ParadaItinerario(
            parada: 'Maceió',
            horario: '08:24',
            descricao: 'Terminal Rodoviário',
            tipo: 'destino',
            tags: ['Ponto de Chegada', 'Desembarque final'],
          ),
        ],
      );

      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: DetalhesViagemPage(
              args: DetalhesViagemArgs(detalhes: detalhes),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Confirma que os textos das paradas estão visíveis
      expect(find.text('Arapiraca'), findsWidgets);
      expect(find.text('Maceió'), findsWidgets);
      expect(find.text('Itinerário & Paradas'), findsOneWidget);

      // Localiza todos os Containers circulares dos nós
      final containers = tester.widgetList<Container>(find.byType(Container));
      final circularNodes = containers.where((c) {
        final dec = c.decoration;
        return dec is BoxDecoration && dec.shape == BoxShape.circle && dec.color != null;
      }).toList();

      // Deve haver nó com AppColors.primary (partida) e nó com AppColors.secondary (chegada)
      final hasPrimaryNode = circularNodes.any(
        (c) => (c.decoration as BoxDecoration).color == AppColors.primary,
      );
      final hasSecondaryNode = circularNodes.any(
        (c) => (c.decoration as BoxDecoration).color == AppColors.secondary,
      );

      expect(hasPrimaryNode, isTrue, reason: 'Nó de partida deve ter cor primária (terracota)');
      expect(hasSecondaryNode, isTrue, reason: 'Nó de chegada deve ter cor azul (AppColors.secondary)');
    });
  });
}
