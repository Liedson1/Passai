import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:passai/core/constants/app_constants.dart';
import 'package:passai/core/theme/app_colors.dart';
import 'package:passai/core/theme/app_text_styles.dart';
import 'package:passai/domain/entities/detalhes_viagem.dart';
import 'package:passai/presentation/pages/detalhes_viagem/detalhes_viagem_page.dart';
import 'package:passai/presentation/pages/detalhes_viagem/widgets/detalhes_viagem_share_helper.dart';

/// AppBar deslizante no topo da tela de detalhes da viagem
class DetalhesAppBar extends StatelessWidget {
  const DetalhesAppBar({super.key, required this.detalhes, this.args});

  final DetalhesViagem detalhes;
  final DetalhesViagemArgs? args;

  @override
  Widget build(BuildContext context) {
    final origem = detalhes.origem ?? '';
    final destino = detalhes.destino ?? '';
    final tipoLinha = detalhes.tipoLinha;

    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: AppColors.primary,
      iconTheme: const IconThemeData(color: AppColors.textOnPrimary),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textOnPrimary),
        tooltip: 'Voltar',
        onPressed: () {
          HapticFeedback.lightImpact();
          if (context.canPop()) {
            context.pop();
          } else {
            context.go(AppRoutes.home);
          }
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share_outlined, color: AppColors.textOnPrimary),
          tooltip: 'Compartilhar viagem',
          onPressed: () {
            HapticFeedback.lightImpact();
            DetalhesViagemShareHelper.compartilhar(
              context,
              detalhes,
              rotaId: args?.rotaId,
              sentido: args?.sentido,
            );
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: AppColors.primary,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (origem.isNotEmpty && destino.isNotEmpty)
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        origem,
                        style: AppTextStyles.headingLG(color: AppColors.textOnPrimary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
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
                        style: AppTextStyles.headingLG(color: AppColors.textOnPrimary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                )
              else
                Text(
                  detalhes.rota,
                  style: AppTextStyles.headingLG(color: AppColors.textOnPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.heroOverlay,
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                    ),
                    child: Text(
                      [
                        if (tipoLinha.isNotEmpty) tipoLinha,
                        if (detalhes.horaSaida != null) 'Saída ${detalhes.horaSaida}',
                      ].join(' • '),
                      style: AppTextStyles.bodyBold(
                        fontSize: 12,
                        color: AppColors.textOnPrimary,
                      ),
                    ),
                  ),
                  if (detalhes.cooperativa != null && detalhes.cooperativa!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.heroOverlay,
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                      ),
                      child: Text(
                        detalhes.cooperativa!,
                        style: AppTextStyles.bodyBold(
                          fontSize: 12,
                          color: AppColors.textOnPrimary,
                        ),
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: detalhes.alterado ? AppColors.warningLight : AppColors.successLight,
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: detalhes.alterado ? AppColors.warning : AppColors.success,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          detalhes.alterado ? 'Horário Alterado Hoje' : detalhes.status,
                          style: AppTextStyles.bodyBold(
                            fontSize: 12,
                            color: detalhes.alterado ? AppColors.warning : AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
