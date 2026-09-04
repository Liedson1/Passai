import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passai/domain/entities/alteracao.dart';
import 'package:passai/domain/entities/horario.dart';
import 'package:passai/presentation/widgets/horario_tile.dart';

void main() {
  group('HorarioTile Widget Tests', () {
    testWidgets('Deve exibir horário normal sem badge de alteração', (tester) async {
      const horario = Horario(
        id: 1,
        hora: '08:00',
        sentido: Sentido.ida,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HorarioTile(horario: horario),
          ),
        ),
      );

      expect(find.text('08:00'), findsOneWidget);
      expect(find.text('ALTERADO'), findsNothing);
    });

    testWidgets('Deve exibir horário alterado com badge, hora nova e detalhes', (tester) async {
      const horario = Horario(
        id: 2,
        hora: '08:30',
        sentido: Sentido.ida,
        alteracao: Alteracao(
          id: 1,
          horaOriginal: '08:00',
          horaNova: '08:30',
          vanOriginal: 'Van 01',
          vanSubstituta: 'Van 04',
          motivo: 'Pneu furado',
        ),
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HorarioTile(horario: horario),
          ),
        ),
      );

      expect(find.text('ALTERADO'), findsOneWidget);
      expect(find.text('08:30'), findsOneWidget);
      expect(find.text('08:00'), findsOneWidget);
      expect(find.text('Van substituta: Van 04'), findsOneWidget);
      expect(find.text('Pneu furado'), findsOneWidget);
    });
  });
}
