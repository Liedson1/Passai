import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Comportamento de rolagem adaptativo por plataforma:
/// - iOS e macOS: BouncingScrollPhysics nativo com suporte a toque
/// - Android, Web e Desktop: ClampingScrollPhysics consistente
class PassaiScrollBehavior extends MaterialScrollBehavior {
  const PassaiScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    final platform = Theme.of(context).platform;
    if (platform == TargetPlatform.iOS || platform == TargetPlatform.macOS) {
      return const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      );
    }
    return const ClampingScrollPhysics(
      parent: AlwaysScrollableScrollPhysics(),
    );
  }
}
