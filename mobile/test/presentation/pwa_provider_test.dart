import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passai/core/services/pwa_service/pwa_service.dart';
import 'package:passai/presentation/providers/pwa_provider.dart';

void main() {
  group('PWA Service & Provider Tests', () {
    test('PwaService no-op default values are safe and return false', () async {
      expect(pwaService.canInstall, isFalse);
      expect(pwaService.isInstalled, isFalse);
      expect(pwaService.isStandalone, isFalse);
      expect(pwaService.isIos, isFalse);

      final result = await pwaService.promptInstall();
      expect(result, isFalse);
    });

    test('PwaState copyWith works correctly', () {
      const state = PwaState();
      expect(state.canInstall, isFalse);
      expect(state.isInstalled, isFalse);
      expect(state.isStandalone, isFalse);
      expect(state.isIos, isFalse);

      final updated = state.copyWith(
        canInstall: true,
        isInstalled: false,
        isStandalone: true,
        isIos: true,
      );

      expect(updated.canInstall, isTrue);
      expect(updated.isInstalled, isFalse);
      expect(updated.isStandalone, isTrue);
      expect(updated.isIos, isTrue);
    });

    test('PwaNotifier initializes with PwaService default state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(pwaProvider);
      expect(state.canInstall, isFalse);
      expect(state.isInstalled, isFalse);
      expect(state.isStandalone, isFalse);
    });

    test('PwaNotifier promptInstall returns false when not installable in tests', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final result = await container.read(pwaProvider.notifier).promptInstall();
      expect(result, isFalse);
    });
  });
}
