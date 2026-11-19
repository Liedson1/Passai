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
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics(
      parent: AlwaysScrollableScrollPhysics(),
    );
  }
}
