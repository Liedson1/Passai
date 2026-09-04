import 'package:flutter/material.dart';
import 'package:passai/core/constants/app_constants.dart';
import 'package:passai/core/theme/app_colors.dart';
import 'package:passai/core/theme/app_text_styles.dart';

/// Botão de login social (Google, Apple, etc.).
/// Recebe um [iconWidget] genérico para suportar qualquer ícone.
class SocialButton extends StatelessWidget {
  const SocialButton({
    super.key,
    required this.label,
    required this.iconWidget,
    required this.onTap,
  });

  final String label;
  final Widget iconWidget;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.input),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconWidget,
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.bodySemibold(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
