import 'package:flutter/material.dart';
import 'package:passai/core/theme/app_colors.dart';

/// Envelopa telas em um container centralizado com largura máxima controlada
/// em monitores desktop ou tablets (> 640px), prevenindo inputs e cards
/// desconfortavelmente esticados e mantendo foco e ergonomia visual.
class ResponsiveShell extends StatelessWidget {
  const ResponsiveShell({
    super.key,
    required this.child,
    this.maxWidth = 640.0,
    this.backgroundColor,
  });

  final Widget child;
  final double maxWidth;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Em celulares e telas menores, usa 100% da largura nativa
    if (screenWidth <= maxWidth) {
      return child;
    }

    // Em telas maiores, centraliza o layout com sombra suave e fundo contrastante
    return Container(
      color: const Color(0xFFEDE4D7),
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: RepaintBoundary(
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor ?? AppColors.background,
              boxShadow: [
                BoxShadow(
                  color: AppColors.textPrimary.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
