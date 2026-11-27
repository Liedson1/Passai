import 'package:flutter/material.dart';
import 'package:passai/core/theme/app_colors.dart';
import 'package:passai/core/theme/app_text_styles.dart';
import 'package:passai/domain/entities/parada_itinerario.dart';

/// Nó individual da timeline de paradas de itinerário
class TimelineNode extends StatelessWidget {
  const TimelineNode({
    super.key,
    required this.parada,
    required this.isFirst,
    required this.isLast,
    required this.ordem,
  });

  final ParadaItinerario parada;
  final bool isFirst;
  final bool isLast;
  final int ordem;

  Color get _nodeColor {
    if (isFirst) return AppColors.primary;
    if (isLast) return AppColors.secondary;
    return AppColors.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 32,
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isFirst || isLast ? _nodeColor : AppColors.surface,
                    border: Border.all(
                      color: _nodeColor,
                      width: isFirst || isLast ? 3 : 2.5,
                    ),
                    boxShadow: isFirst || isLast
                        ? [
                            BoxShadow(
                              color: _nodeColor.withValues(alpha: 0.25),
                              blurRadius: 6,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: isFirst || isLast
                      ? Center(
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.onDark,
                            ),
                          ),
                        )
                      : null,
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: AppColors.border,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 8, bottom: isLast ? 10 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          parada.parada,
                          style: AppTextStyles.bodyBold(
                            fontSize: 15,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (parada.horario.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: isFirst
                                ? AppColors.primaryLight
                                : (isLast
                                    ? AppColors.secondaryLight
                                    : AppColors.background),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isFirst
                                  ? AppColors.primary.withValues(alpha: 0.3)
                                  : (isLast
                                      ? AppColors.secondary.withValues(alpha: 0.3)
                                      : AppColors.border),
                            ),
                          ),
                          child: Text(
                            isFirst
                                ? parada.horario
                                : (isLast
                                    ? '${parada.horario} (chegada)'
                                    : '${parada.horario} (previsto)'),
                            style: AppTextStyles.bodyBold(
                              fontSize: 11,
                              color: isFirst
                                  ? AppColors.primary
                                  : (isLast
                                      ? AppColors.secondary
                                      : AppColors.textSecondary),
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (parada.descricao != null &&
                      parada.descricao!.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      parada.descricao!,
                      style: AppTextStyles.bodyRegular(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  if (parada.tags.isNotEmpty || parada.observacao != null) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        ...parada.tags.map(_buildTag),
                        if (parada.observacao != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.inputBackground,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              parada.observacao!,
                              style: AppTextStyles.bodyMedium(
                                fontSize: 10,
                                color: isLast
                                    ? AppColors.secondary
                                    : AppColors.primary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String tag) {
    final lower = tag.toLowerCase();
    final isChegadaTag =
        isLast || lower.contains('chegada') || lower.contains('desembarque');
    final isPartidaTag =
        isFirst || lower.contains('partida') || lower.contains('embarque');

    final Color tagBg;
    final Color tagBorder;
    final Color tagTextColor;

    if (isChegadaTag) {
      tagBg = AppColors.secondaryLight;
      tagBorder = AppColors.secondary.withValues(alpha: 0.25);
      tagTextColor = AppColors.secondary;
    } else if (isPartidaTag) {
      tagBg = AppColors.primaryLight;
      tagBorder = AppColors.primary.withValues(alpha: 0.25);
      tagTextColor = AppColors.primary;
    } else {
      tagBg = AppColors.surface;
      tagBorder = AppColors.border;
      tagTextColor = AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: tagBg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: tagBorder),
      ),
      child: Text(
        tag,
        style: AppTextStyles.bodyMedium(
          fontSize: 10,
          color: tagTextColor,
        ),
      ),
    );
  }
}
