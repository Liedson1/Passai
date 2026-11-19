import 'package:flutter/material.dart';
import 'package:passai/core/constants/app_constants.dart';
import 'package:passai/core/theme/app_colors.dart';
import 'package:passai/core/theme/app_text_styles.dart';
import 'package:passai/domain/entities/horario.dart';

/// Badge visual para sinalizar alterações operacionais no horário (RN06)
class AlteracaoBadge extends StatelessWidget {
  const AlteracaoBadge({super.key, required this.horario});

  final Horario horario;

  @override
  Widget build(BuildContext context) {
    final alt = horario.alteracao;
    if (alt == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(AppRadii.badge),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'ALTERADO',
              style: AppTextStyles.bodyBold(
                fontSize: 9,
                color: AppColors.textOnPrimary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Era ${alt.horaOriginal}',
            style: AppTextStyles.bodyRegular(
              fontSize: 12,
              color: AppColors.textSecondary,
            ).copyWith(decoration: TextDecoration.lineThrough),
          ),
          if (alt.motivo != null) ...[
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                '• ${alt.motivo}',
                style: AppTextStyles.bodyRegular(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
