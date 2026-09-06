import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passai/presentation/widgets/common/passai_logo.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PassaiLogo Widget Tests', () {
    testWidgets('Deve renderizar variante horizontal com PassaiVanIcon nativo e Text PASSAÍ', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PassaiLogo.horizontal(height: 30),
          ),
        ),
      );

      final vanFinder = find.byType(PassaiVanIcon);
      expect(vanFinder, findsOneWidget);

      expect(find.text('PASSAÍ'), findsOneWidget);

      final passaiLogo = tester.widget<PassaiLogo>(find.byType(PassaiLogo));
      expect(passaiLogo.variant, PassaiLogoVariant.horizontal);
      expect(passaiLogo.size, 30);
    });

    testWidgets('Deve renderizar variante horizontalTerracota com cápsula terracota e PassaiVanIcon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PassaiLogo.horizontalTerracota(height: 36),
          ),
        ),
      );

      final vanFinder = find.byType(PassaiVanIcon);
      expect(vanFinder, findsOneWidget);

      expect(find.text('PASSAÍ'), findsOneWidget);

      final passaiLogo = tester.widget<PassaiLogo>(find.byType(PassaiLogo));
      expect(passaiLogo.variant, PassaiLogoVariant.horizontalTerracota);
      expect(passaiLogo.size, 36);
    });

    testWidgets('Deve renderizar variante circular com badge terracota e PassaiVanIcon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PassaiLogo(size: 48),
          ),
        ),
      );

      final passaiLogo = tester.widget<PassaiLogo>(find.byType(PassaiLogo));
      expect(passaiLogo.variant, PassaiLogoVariant.circular);
      expect(passaiLogo.size, 48);

      final vanFinder = find.byType(PassaiVanIcon);
      expect(vanFinder, findsOneWidget);
    });

    testWidgets('Deve renderizar variante van isolada com PassaiVanIcon nativo', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PassaiLogo.van(size: 30),
          ),
        ),
      );

      final passaiLogo = tester.widget<PassaiLogo>(find.byType(PassaiLogo));
      expect(passaiLogo.variant, PassaiLogoVariant.van);
      expect(passaiLogo.size, 30);

      final vanFinder = find.byType(PassaiVanIcon);
      expect(vanFinder, findsOneWidget);
    });

    testWidgets('Deve renderizar variante text (wordmark) isolada com Text nativo', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PassaiLogo.text(height: 26),
          ),
        ),
      );

      final passaiLogo = tester.widget<PassaiLogo>(find.byType(PassaiLogo));
      expect(passaiLogo.variant, PassaiLogoVariant.text);
      expect(passaiLogo.size, 26);

      expect(find.text('PASSAÍ'), findsOneWidget);
    });

    testWidgets('Deve repassar cor personalizada para o PassaiVanIcon e Text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PassaiLogo.horizontal(
              height: 30,
              color: Colors.amber,
            ),
          ),
        ),
      );

      final passaiLogo = tester.widget<PassaiLogo>(find.byType(PassaiLogo));
      expect(passaiLogo.color, Colors.amber);

      final vanIcon = tester.widget<PassaiVanIcon>(find.byType(PassaiVanIcon));
      expect(vanIcon.color, Colors.amber);

      final textWidget = tester.widget<Text>(find.text('PASSAÍ'));
      expect(textWidget.style?.color, Colors.amber);
    });
  });
}
