import 'package:flutter/material.dart';
import 'package:passai/core/theme/app_colors.dart';
import 'package:passai/core/theme/app_text_styles.dart';
import 'package:passai/core/constants/app_constants.dart';

/// Widget do campo de input de rota (origem ou destino)
class RouteInputField extends StatelessWidget {
  const RouteInputField({
    super.key,
    required this.label,
    required this.iconColor,
    required this.icon,
    this.value,
    this.placeholder,
  });

  final String label;
  final Color iconColor;
  final IconData icon;
  final String? value;
  final String? placeholder;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadii.input),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.bodyRegular(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value ?? placeholder ?? '',
                style: value != null
                    ? AppTextStyles.bodySemibold(
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      )
                    : AppTextStyles.bodyMedium(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
