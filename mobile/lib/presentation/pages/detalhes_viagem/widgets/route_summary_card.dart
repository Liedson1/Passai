import 'package:flutter/material.dart';
import 'package:passai/core/constants/app_constants.dart';
import 'package:passai/core/theme/app_colors.dart';
import 'package:passai/core/theme/app_text_styles.dart';
import 'package:passai/core/utils/duracao_estimativa.dart';
import 'package:passai/domain/entities/detalhes_viagem.dart';
import 'package:passai/presentation/pages/detalhes_viagem/widgets/metrica_item.dart';

/// Card de resumo da rota com tarifa, chegada prevista, duração e extensão
class RouteSummaryCard extends StatelessWidget {
  const RouteSummaryCard({super.key, required this.detalhes});

  final DetalhesViagem detalhes;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.directions_bus_filled,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Resumo da Viagem',
                  style: AppTextStyles.headingMD(color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TARIFA OFICIAL',
                      style: AppTextStyles.bodyBold(
                        fontSize: 11,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      detalhes.preco.isNotEmpty ? detalhes.preco : 'A consultar',
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    'por assento',
                    style: AppTextStyles.bodySemibold(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: MetricaItem(
                  icon: Icons.flag_outlined,
                  label: 'Chegada Prevista',
                  valor: detalhes.chegadaPrevista ?? '--:--',
                  destaque: true,
                  corDestaque: AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: MetricaItem(
                  icon: Icons.hourglass_empty_rounded,
                  label: 'Duração',
                  valor: DuracaoEstimativa.padronizar(detalhes.duracao) ??
                      'A consultar',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: MetricaItem(
                  icon: Icons.straighten_rounded,
                  label: 'Extensão',
                  valor: detalhes.distancia ?? 'A consultar',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
