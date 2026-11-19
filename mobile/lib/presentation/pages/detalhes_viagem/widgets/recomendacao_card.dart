import 'package:flutter/material.dart';
import 'package:passai/core/constants/app_constants.dart';
import 'package:passai/core/theme/app_colors.dart';
import 'package:passai/core/theme/app_text_styles.dart';
import 'package:passai/domain/entities/detalhes_viagem.dart';

/// Card retrátil com recomendações e orientações de embarque para o passageiro
class RecomendacaoCard extends StatelessWidget {
  const RecomendacaoCard({super.key, required this.detalhes});

  final DetalhesViagem detalhes;

  @override
  Widget build(BuildContext context) {
    final origemNome = detalhes.origem ??
        (detalhes.itinerario.isNotEmpty ? detalhes.itinerario.first.parada : 'na origem');

    final avisoMensagem = detalhes.aviso ??
        'Chegue com 10 a 15 minutos de antecedência no ponto de partida em $origemNome para garantir seu lugar no veículo. O embarque é realizado por ordem de chegada.';

    return Material(
      color: AppColors.primaryLight,
      borderRadius: BorderRadius.circular(AppRadii.card),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            collapsedIconColor: AppColors.primary,
            iconColor: AppColors.primary,
            tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
            childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.lightbulb_outline_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Recomendação Passaí',
                    style: AppTextStyles.bodyBold(
                      fontSize: 13,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
              ],
            ),
            children: [
              Text(
                avisoMensagem,
                style: AppTextStyles.bodyRegular(
                  fontSize: 12,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
