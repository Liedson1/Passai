import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passai/main.dart';

void main() {
  group('Mobile UX & Platform Adaptation Tests', () {
    const scrollBehavior = PassaiScrollBehavior();

    test('Deve suportar todos os dispositivos de ponteiro (touch, mouse, trackpad, stylus)', () {
      final devices = scrollBehavior.dragDevices;
      expect(devices, contains(PointerDeviceKind.touch));
      expect(devices, contains(PointerDeviceKind.mouse));
      expect(devices, contains(PointerDeviceKind.trackpad));
      expect(devices, contains(PointerDeviceKind.stylus));
    });

    testWidgets('Deve fornecer BouncingScrollPhysics no iOS', (tester) async {
      late ScrollPhysics physics;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          home: Builder(
            builder: (context) {
              physics = scrollBehavior.getScrollPhysics(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(physics, isA<BouncingScrollPhysics>());
    });

    testWidgets('Deve fornecer ClampingScrollPhysics no Android', (tester) async {
      late ScrollPhysics physics;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.android),
          home: Builder(
            builder: (context) {
              physics = scrollBehavior.getScrollPhysics(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(physics, isA<ClampingScrollPhysics>());
    });
  });
}
