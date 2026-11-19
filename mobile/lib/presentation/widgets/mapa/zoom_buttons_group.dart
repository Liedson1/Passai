import 'package:flutter/material.dart';
import 'package:passai/core/theme/app_colors.dart';

/// Agrupamento vertical de botões Zoom (+ e -) estilo Google Maps
class ZoomButtonsGroup extends StatelessWidget {
  const ZoomButtonsGroup({
    super.key,
    required this.onZoomIn,
    required this.onZoomOut,
  });

  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  @override
  Widget build(BuildContext context) {
    return Container(
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: InkWell(
                onTap: onZoomIn,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                child: const Tooltip(
                  message: 'Aproximar',
                  child: SizedBox(
                    width: 36,
                    height: 34,
                    child: Icon(
                      Icons.add_rounded,
                      size: 20,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              width: 26,
              height: 1.0,
              color: AppColors.border,
            ),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: InkWell(
                onTap: onZoomOut,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
                child: const Tooltip(
                  message: 'Afastar',
                  child: SizedBox(
                    width: 36,
                    height: 34,
                    child: Icon(
                      Icons.remove_rounded,
                      size: 20,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
