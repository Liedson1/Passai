import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:passai/core/constants/app_constants.dart';
import 'package:passai/core/theme/app_colors.dart';
import 'package:passai/core/theme/app_text_styles.dart';

/// AppBar customizada da tela de resultados — exibe rota, via e botão de inverter sentido
class ResultadosAppBar extends StatelessWidget {
  const ResultadosAppBar({
    super.key,
    required this.origem,
    required this.destino,
    required this.linha,
    this.via,
    this.onInverterSentido,
  });

  final String origem;
  final String destino;
  final String linha;
  final String? via;
  final VoidCallback? onInverterSentido;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: AppColors.primary,
      iconTheme: const IconThemeData(color: AppColors.textOnPrimary),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.textOnPrimary),
        tooltip: 'Voltar',
        onPressed: () => context.go(AppRoutes.home),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: AppColors.primary,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Origem ⇄ Destino com botão de swap
              Row(
                children: [
                  Flexible(
                    child: Text(
                      origem,
                      style: AppTextStyles.headingLG(
                        color: AppColors.textOnPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (onInverterSentido != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Tooltip(
                        message: 'Inverter para volta',
                        child: Material(
                          color: Colors.white.withValues(alpha: 0.20),
                          shape: const CircleBorder(),
                          child: InkWell(
                            onTap: onInverterSentido,
                            customBorder: const CircleBorder(),
                            child: const Padding(
                              padding: EdgeInsets.all(8),
                              child: Icon(
                                Icons.swap_horiz_rounded,
                                color: AppColors.titleGold,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(
                        Icons.arrow_forward,
                        color: AppColors.textOnPrimary,
                        size: 18,
                      ),
                    ),
                  Flexible(
                    child: Text(
                      destino,
                      style: AppTextStyles.headingLG(
                        color: AppColors.textOnPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Badge da rota: exibe apenas a via se existir para evitar duplicação
              if (via != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.titleGold.withValues(alpha: 0.25),
                    border: Border.all(
                      color: AppColors.titleGold.withValues(alpha: 0.6),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                  child: Text(
                    via!,
                    style: AppTextStyles.bodyBold(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.heroOverlay,
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                  child: Text(
                    'Linha $linha',
                    style: AppTextStyles.bodyBold(
                      fontSize: 12,
                      color: AppColors.textOnPrimary,
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
