import 'dart:async';

class PwaService {
  bool get canInstall => false;
  bool get isInstalled => false;
  bool get isStandalone => false;
  bool get isIos => false;

  Future<bool> promptInstall() async => false;
  Stream<bool> get onCanInstallChanged => const Stream.empty();
}

final pwaService = PwaService();
