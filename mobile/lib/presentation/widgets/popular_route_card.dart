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

/// Card de rota popular exibido na lista da tela home (Mobile & PWA)
class PopularRouteCard extends StatelessWidget {
  const PopularRouteCard({
    super.key,
    required this.route,
    this.onTap,
    this.onVerDetalhes,
  });

  final PopularRoute route;
  final VoidCallback? onTap;
  final VoidCallback? onVerDetalhes;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onVerDetalhes ?? onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.card),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Linha Superior: Origem ➔ Destino e Badge de Preço
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              route.from,
                              style: AppTextStyles.bodyBold(
                                fontSize: 15,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 6),
                              child: Icon(
                                Icons.arrow_forward_rounded,
                                color: AppColors.primary,
                                size: 16,
                              ),
                            ),
                            Flexible(
                              child: Text(
                                route.via != null
                                    ? '${route.to} (${route.via})'
                                    : route.to,
                                style: AppTextStyles.bodyBold(
                                  fontSize: 15,
                                  color: AppColors.textPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          route.subtitle ?? 'Próxima saída: ${route.nextTime}',
                          style: AppTextStyles.bodyRegular(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Badge de Preço
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
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

              const SizedBox(height: 14),

              // Linha Inferior: Botões de Ação para PWA/Mobile
              Row(
                children: [
                  // Botão Ver no Mapa / Detalhes da Rota
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onVerDetalhes,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.alt_route_rounded, size: 15),
                      label: const Text(
                        'Ver Itinerário',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  if (onTap != null) ...[
                    const SizedBox(width: 8),
                    // Botão Ver Horários do Dia
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.schedule_rounded, size: 15),
                        label: const Text(
                          'Ver Horários',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
