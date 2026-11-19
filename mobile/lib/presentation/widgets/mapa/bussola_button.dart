import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:passai/core/theme/app_colors.dart';

/// Botão flutuante de bússola para redefinir a rotação do mapa para o Norte
class BussolaButton extends StatelessWidget {
  const BussolaButton({
    super.key,
    required this.rotacao,
    required this.onResetRotation,
  });

  final double rotacao;
  final VoidCallback onResetRotation;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border, width: 1.0),
          boxShadow: const [
            BoxShadow(
              color: Color(0x2A000000),
              blurRadius: 4,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: InkWell(
              onTap: onResetRotation,
              borderRadius: BorderRadius.circular(8),
              child: Tooltip(
                message: 'Redefinir orientação para o Norte',
                child: SizedBox(
                  width: 36,
                  height: 36,
                  child: Center(
                    child: Transform.rotate(
                      angle: -rotacao * math.pi / 180,
                      child: const Icon(
                        Icons.explore_rounded,
                        size: 22,
                        color: Color(0xFFDC2626), // Vermelho bússola Norte
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
