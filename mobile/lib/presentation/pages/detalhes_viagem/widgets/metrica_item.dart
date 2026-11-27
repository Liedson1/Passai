import 'package:flutter/material.dart';
import 'package:passai/core/theme/app_colors.dart';
import 'package:passai/core/theme/app_text_styles.dart';

/// Item individual de métrica reutilizável com ícone e rótulo
class MetricaItem extends StatelessWidget {
  const MetricaItem({
    super.key,
    required this.icon,
    required this.label,
    required this.valor,
    this.destaque = false,
    this.corDestaque,
  });

  final IconData icon;
  final String label;
  final String valor;
  final bool destaque;
  final Color? corDestaque;

  @override
  Widget build(BuildContext context) {
    final activeColor = corDestaque ?? AppColors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: destaque ? activeColor : AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodyRegular(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  valor,
                  style: AppTextStyles.bodyBold(
                    fontSize: 13,
                    color: destaque ? activeColor : AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
