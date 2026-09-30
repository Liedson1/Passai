import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:passai/core/theme/app_colors.dart';
import 'package:passai/core/theme/app_text_styles.dart';
import 'package:passai/core/constants/app_constants.dart';
import 'package:passai/presentation/providers/resultados_provider.dart';

/// Seletor horizontal de datas — 7 dias com o dia ativo em destaque.
/// Emite [onDateSelected] quando o passageiro toca em um dia diferente.
class DateSelector extends StatelessWidget {
  const DateSelector({
    super.key,
    required this.dias,
    required this.onDateSelected,
  });

  final List<DiaItem> dias;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 76,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: dias.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final dia = dias[index];
          return _DayChip(
            key: ValueKey(dia.data),
            diaItem: dia,
            onTap: () => onDateSelected(dia.data),
          );
        },
      ),
    );
  }
}

/// Chip individual de dia no seletor de datas
class _DayChip extends StatelessWidget {
  const _DayChip({
    super.key,
    required this.diaItem,
    required this.onTap,
  });

  final DiaItem diaItem;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: 52,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: diaItem.selecionado
              ? AppColors.dateChipActive
              : AppColors.dateChipInactive,
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(
            color: diaItem.selecionado
                ? AppColors.primary
                : AppColors.border,
            width: diaItem.selecionado ? 2 : 1,
          ),
          boxShadow: diaItem.selecionado
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              diaItem.diaSemana,
              style: AppTextStyles.bodyMedium(
                fontSize: 11,
                color: diaItem.selecionado
                    ? AppColors.textOnPrimary
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              diaItem.dia,
              style: AppTextStyles.bodySemibold(
                fontSize: 18,
                color: diaItem.selecionado
                    ? AppColors.textOnPrimary
                    : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
