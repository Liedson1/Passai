import 'package:flutter/material.dart';
import 'package:passai/core/constants/app_constants.dart';
import 'package:passai/core/theme/app_colors.dart';
import 'package:passai/core/theme/app_text_styles.dart';
import 'package:passai/domain/entities/detalhes_viagem.dart';
import 'package:passai/domain/entities/parada_itinerario.dart';
import 'package:passai/presentation/pages/detalhes_viagem/widgets/timeline_node.dart';
import 'package:passai/presentation/pages/detalhes_viagem/widgets/timeline_skeleton.dart';
import 'package:passai/presentation/widgets/itinerario_mapa_widget.dart';

/// Seção com mapa e timeline vertical do itinerário de viagem
class SecaoItinerario extends StatelessWidget {
  const SecaoItinerario({
    super.key,
    required this.detalhes,
    required this.itinerario,
    this.isLoading = false,
  });

  final DetalhesViagem detalhes;
  final List<ParadaItinerario> itinerario;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Itinerário & Paradas',
                style: AppTextStyles.headingMD(color: AppColors.textPrimary),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppRadii.badge),
                ),
                child: Text(
                  '${itinerario.length} paradas',
                  style: AppTextStyles.bodyBold(
                    fontSize: 11,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (!isLoading) ...[
            ItinerarioMapaWidget(
              paradas: itinerario,
              altura: MediaQuery.of(context).size.width > 800 ? 300 : 240,
            ),
            if (itinerario.any((p) => p.temCoordenadas))
              const SizedBox(height: 16),
          ],
          if (isLoading)
            const TimelineSkeleton()
          else if (itinerario.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'Itinerário não disponível para esta viagem.',
                  style: AppTextStyles.bodyRegular(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            Column(
              children: [
                ...List.generate(itinerario.length, (index) {
                  final parada = itinerario[index];
                  final isFirst = index == 0 || parada.tipo == 'origem';
                  final isLast =
                      index == itinerario.length - 1 || parada.tipo == 'destino';

                  return TimelineNode(
                    parada: parada,
                    isFirst: isFirst,
                    isLast: isLast,
                    ordem: index + 1,
                  );
                }),
                if (itinerario.length > 2) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Horários das paradas intermediárias são estimativas sujeitas ao trânsito e embarque.',
                            style: AppTextStyles.bodyRegular(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }
}
