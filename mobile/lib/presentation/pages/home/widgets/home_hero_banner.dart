import 'package:flutter/material.dart';
import 'package:passai/core/constants/app_constants.dart';
import 'package:passai/core/theme/app_colors.dart';
import 'package:passai/core/theme/app_text_styles.dart';
import 'package:passai/presentation/widgets/common/passai_logo.dart';

/// Banner hero da tela principal — exibe logo e tagline do Passaí
class HomeHeroBanner extends StatelessWidget {
  const HomeHeroBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      color: AppColors.primary,
      padding: EdgeInsets.fromLTRB(24, statusBarHeight + 16, 24, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo Passaí Oficial Horizontal SVG
          const PassaiLogo.horizontal(height: 38),

          const SizedBox(height: 16),

          RichText(
            text: TextSpan(
              style: AppTextStyles.headingLG(color: AppColors.textOnPrimary),
              children: const [
                TextSpan(text: 'Para onde você '),
                TextSpan(
                  text: 'vai hoje?',
                  style: TextStyle(color: AppColors.titleGold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppConstants.taglineSubtitle,
            style: AppTextStyles.bodyRegular(
              fontSize: 14,
              color: AppColors.heroSubtitle,
            ),
          ),
        ],
      ),
    );
  }
}
