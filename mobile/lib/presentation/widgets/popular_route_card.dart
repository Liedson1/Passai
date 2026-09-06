import 'package:flutter/material.dart';
import 'package:passai/core/theme/app_colors.dart';
import 'package:passai/core/theme/app_text_styles.dart';
import 'package:passai/core/constants/app_constants.dart';

/// Dados de uma rota popular exibida na tela home
class PopularRoute {
  const PopularRoute({
    required this.from,
    required this.to,
    this.via,
    this.nextTime = '—',
    required this.price,
    this.subtitle,
  });

  final String from;
  final String to;
  final String? via;
  final String nextTime;
  final String price;
  final String? subtitle;
}

/// Card de rota popular exibido na lista da tela home
class PopularRouteCard extends StatelessWidget {
  const PopularRouteCard({
    super.key,
    required this.route,
    this.onTap,
  });

  final PopularRoute route;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            // Cidades
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        route.from,
                        style: AppTextStyles.bodyBold(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Icon(
                          Icons.arrow_forward,
                          color: AppColors.primary,
                          size: 14,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          route.via != null ? '${route.to} (${route.via})' : route.to,
                          style: AppTextStyles.bodyBold(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    route.subtitle ?? 'Próxima: ${route.nextTime}',
                    style: AppTextStyles.bodyRegular(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Badge de preço
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(AppRadii.badge),
              ),
              child: Text(
                route.price,
                style: AppTextStyles.bodyBold(
                  fontSize: 13,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}
