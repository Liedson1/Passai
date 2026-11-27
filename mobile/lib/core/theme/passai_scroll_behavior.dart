import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Comportamento de rolagem fluido e adaptativo para todas as plataformas.
/// Utiliza [BouncingScrollPhysics] para desaceleração suave e contínua,
/// eliminando as paradas bruscas e sensação travada do ClampingScrollPhysics no PC e Mobile.
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
    switch (getPlatform(context)) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        );
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return const ClampingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        );
    }
  }
}
