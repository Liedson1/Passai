import 'package:flutter/material.dart';
import 'package:passai/core/theme/app_colors.dart';
import 'package:passai/core/theme/app_text_styles.dart';
import 'package:passai/core/constants/app_constants.dart';
import 'package:passai/presentation/providers/resultados_provider.dart';

/// Chips de filtro por período do dia (Todos, Manhã, Tarde, Noite).
/// Emite [onFilterChanged] quando o passageiro seleciona um período.
class PeriodFilter extends StatelessWidget {
  const PeriodFilter({
    super.key,
    required this.filtroAtivo,
    required this.onFilterChanged,
  });

  final FiltroPeriodo filtroAtivo;
  final ValueChanged<FiltroPeriodo> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: FiltroPeriodo.values.map((filtro) {
          final isSelected = filtro == filtroAtivo;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _FilterChip(
              label: _labelParaFiltro(filtro),
              isSelected: isSelected,
              onTap: () => onFilterChanged(filtro),
            ),
          );
        }).toList(),
      ),
    );
  }

  static String _labelParaFiltro(FiltroPeriodo filtro) {
    switch (filtro) {
      case FiltroPeriodo.todos:
        return 'Todos os horários';
      case FiltroPeriodo.manha:
        return 'Manhã';
      case FiltroPeriodo.tarde:
        return 'Tarde';
      case FiltroPeriodo.noite:
        return 'Noite';
    }
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySemibold(
            fontSize: 13,
            color: isSelected
                ? AppColors.textOnPrimary
                : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
