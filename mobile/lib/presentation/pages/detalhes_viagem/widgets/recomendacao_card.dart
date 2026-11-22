import 'package:flutter/material.dart';
import 'package:passai/core/constants/app_constants.dart';
import 'package:passai/core/theme/app_colors.dart';
import 'package:passai/core/theme/app_text_styles.dart';
import 'package:passai/domain/entities/detalhes_viagem.dart';

/// Card informativo com recomendações e orientações de embarque para o passageiro
class RecomendacaoCard extends StatelessWidget {
  const RecomendacaoCard({super.key, required this.detalhes});

  final DetalhesViagem detalhes;

  @override
  Widget build(BuildContext context) {
    final origemNome = detalhes.origem ??
        (detalhes.itinerario.isNotEmpty
            ? detalhes.itinerario.first.parada
            : 'na origem');

    final avisoMensagem = detalhes.aviso ??
        'Chegue com 10 a 15 minutos de antecedência no ponto de partida em $origemNome para garantir seu lugar no veículo. O embarque é realizado por ordem de chegada.';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.22),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.15),
              ),
            ),
            child: const Icon(
              Icons.tips_and_updates_outlined,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Recomendação Passaí',
                      style: AppTextStyles.bodyBold(
                        fontSize: 13,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Dica',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  avisoMensagem,
                  style: AppTextStyles.bodyRegular(
                    fontSize: 12,
                    color: AppColors.textPrimary,
                  ).copyWith(height: 1.45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
