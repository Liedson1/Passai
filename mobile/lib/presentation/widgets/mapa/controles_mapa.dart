import 'package:flutter/material.dart';
import 'package:passai/core/theme/app_colors.dart';
import 'package:passai/presentation/widgets/mapa/bussola_button.dart';
import 'package:passai/presentation/widgets/mapa/zoom_buttons_group.dart';

/// Controles flutuantes de Zoom, Recentralizar e Bússola estilo Google Maps
class ControlesMapa extends StatelessWidget {
  const ControlesMapa({
    super.key,
    required this.rotacaoNotifier,
    required this.onResetRotation,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onResetBounds,
  });

  final ValueNotifier<double> rotacaoNotifier;
  final VoidCallback onResetRotation;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onResetBounds;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ValueListenableBuilder<double>(
          valueListenable: rotacaoNotifier,
          builder: (context, rotacao, _) {
            final estaRotacionado = rotacao.abs() > 1.5;
            if (!estaRotacionado) return const SizedBox.shrink();

            return BussolaButton(
              rotacao: rotacao,
              onResetRotation: onResetRotation,
            );
          },
        ),

        // Botão para recentralizar / enquadrar a rota inteira
        Container(
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
                onTap: onResetBounds,
                borderRadius: BorderRadius.circular(8),
                child: const Tooltip(
                  message: 'Enquadrar rota',
                  child: SizedBox(
                    width: 36,
                    height: 36,
                    child: Icon(
                      Icons.crop_free_rounded,
                      size: 20,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Agrupamento Zoom (+ e -) estilo Google Maps
        ZoomButtonsGroup(
          onZoomIn: onZoomIn,
          onZoomOut: onZoomOut,
        ),
      ],
    );
  }
}
