import 'dart:async';
import 'dart:js_interop';

@JS('window')
external WindowJs get _window;

@JS()
@staticInterop
class WindowJs {}

extension WindowJsExtension on WindowJs {
  external void addEventListener(JSString type, JSFunction callback);
}

@JS('passaiPwa')
external PassaiPwaJs? get _passaiPwa;

@JS()
@staticInterop
class PassaiPwaJs {}

extension PassaiPwaJsExtension on PassaiPwaJs {
  external bool get canInstall;
  external bool get isInstalled;
  external JSPromise<JSBoolean> promptInstall();
  external bool checkIsStandalone();
  external bool checkIsIos();
}

class PwaService {
  final _controller = StreamController<bool>.broadcast();

  PwaService() {
    try {
      _window.addEventListener(
        'passai-pwa-update'.toJS,
        (() {
          _controller.add(canInstall);
        }).toJS,
      );
    } catch (_) {}
  }

  bool get canInstall {
    try {
      return _passaiPwa?.canInstall ?? false;
    } catch (_) {
      return false;
    }
  }

  bool get isInstalled {
    try {
      return _passaiPwa?.isInstalled ?? false;
    } catch (_) {
      return false;
    }
  }

  bool get isStandalone {
    try {
      return _passaiPwa?.checkIsStandalone() ?? false;
    } catch (_) {
      return false;
    }
  }

  bool get isIos {
    try {
      return _passaiPwa?.checkIsIos() ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> promptInstall() async {
    try {
      final pwa = _passaiPwa;
      if (pwa != null) {
        final jsPromise = pwa.promptInstall();
        final jsResult = await jsPromise.toDart;
        return jsResult.toDart;
      }
    } catch (_) {}
    return false;
  }

  Stream<bool> get onCanInstallChanged => _controller.stream;
}

final pwaService = PwaService();
