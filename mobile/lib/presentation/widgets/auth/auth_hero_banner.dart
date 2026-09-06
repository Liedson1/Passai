import 'package:flutter/material.dart';
import 'package:passai/core/theme/app_colors.dart';
import 'package:passai/core/theme/app_text_styles.dart';
import 'package:passai/presentation/widgets/common/passai_logo.dart';

/// Hero banner vermelho reutilizável nas telas de autenticação.
/// Exibe a logo do Passaí, título e subtítulo configuráveis.
class AuthHeroBanner extends StatelessWidget {
  const AuthHeroBanner({
    super.key,
    required this.titulo,
    required this.subtitulo,
  });

  final String titulo;
  final String subtitulo;

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final now = DateTime.now();
    final hora =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    return Container(
      width: double.infinity,
      color: AppColors.primary,
      padding: EdgeInsets.fromLTRB(24, statusBarHeight + 12, 24, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status bar simulada
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                hora,
                style: AppTextStyles.bodySemibold(
                  fontSize: 14,
                  color: AppColors.textOnPrimary,
                ),
              ),
              const Row(
                children: [
                  Icon(Icons.signal_cellular_alt,
                      color: AppColors.textOnPrimary, size: 16),
                  SizedBox(width: 4),
                  Icon(Icons.wifi, color: AppColors.textOnPrimary, size: 16),
                  SizedBox(width: 4),
                  Icon(Icons.battery_full,
                      color: AppColors.textOnPrimary, size: 16),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Logo Oficial Horizontal SVG
          const PassaiLogo.horizontal(height: 38),

          const SizedBox(height: 16),

          // Título e subtítulo
          Text(
            titulo,
            style: AppTextStyles.headingLG(color: AppColors.textOnPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            subtitulo,
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
