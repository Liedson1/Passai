import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:passai/core/services/pwa_service/pwa_service.dart';

class PwaState {
  const PwaState({
    this.canInstall = false,
    this.isInstalled = false,
    this.isStandalone = false,
    this.isIos = false,
  });

  final bool canInstall;
  final bool isInstalled;
  final bool isStandalone;
  final bool isIos;

  PwaState copyWith({
    bool? canInstall,
    bool? isInstalled,
    bool? isStandalone,
    bool? isIos,
  }) {
    return PwaState(
      canInstall: canInstall ?? this.canInstall,
      isInstalled: isInstalled ?? this.isInstalled,
      isStandalone: isStandalone ?? this.isStandalone,
      isIos: isIos ?? this.isIos,
    );
  }
}

class PwaNotifier extends Notifier<PwaState> {
  @override
  PwaState build() {
    final sub = pwaService.onCanInstallChanged.listen((canInstall) {
      state = state.copyWith(
        canInstall: canInstall,
        isInstalled: pwaService.isInstalled,
        isStandalone: pwaService.isStandalone,
        isIos: pwaService.isIos,
      );
    });

    ref.onDispose(sub.cancel);

    return PwaState(
      canInstall: pwaService.canInstall,
      isInstalled: pwaService.isInstalled,
      isStandalone: pwaService.isStandalone,
      isIos: pwaService.isIos,
    );
  }

  Future<bool> promptInstall() async {
    final success = await pwaService.promptInstall();
    state = state.copyWith(
      canInstall: pwaService.canInstall,
      isInstalled: pwaService.isInstalled || success,
      isStandalone: pwaService.isStandalone,
    );
    return success;
  }
}

final pwaProvider = NotifierProvider<PwaNotifier, PwaState>(PwaNotifier.new);
