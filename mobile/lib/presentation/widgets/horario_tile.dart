import 'package:flutter/material.dart';
import 'package:passai/core/theme/app_colors.dart';
import 'package:passai/core/theme/app_text_styles.dart';
import 'package:passai/core/constants/app_constants.dart';
import 'package:passai/domain/entities/horario.dart';

/// Tile que exibe um horário da van.
/// Quando alterado, mostra o badge "ALTERADO", a hora original riscada
/// e a hora nova em destaque (RN05, RN06).
class HorarioTile extends StatelessWidget {
  const HorarioTile({super.key, required this.horario});

  final Horario horario;

  @override
  Widget build(BuildContext context) {
    if (horario.alterado) {
      return _HorarioAlteradoTile(horario: horario);
    }
    return _HorarioNormalTile(hora: horario.hora);
  }
}

// ---------------------------------------------------------------------------
// Tile de horário normal
// ---------------------------------------------------------------------------
class _HorarioNormalTile extends StatelessWidget {
  const _HorarioNormalTile({required this.hora});

  final String hora;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.input),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.access_time, color: AppColors.secondary, size: 20),
          const SizedBox(width: 12),
          Text(
            hora,
            style: AppTextStyles.headingMD(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tile de horário alterado (RN06)
// ---------------------------------------------------------------------------
class _HorarioAlteradoTile extends StatelessWidget {
  const _HorarioAlteradoTile({required this.horario});

  final Horario horario;

  @override
  Widget build(BuildContext context) {
    final alt = horario.alteracao!;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F6),
        borderRadius: BorderRadius.circular(AppRadii.input),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge + hora nova em destaque
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'ALTERADO',
                  style: AppTextStyles.bodyBold(
                    fontSize: 10,
                    color: AppColors.textOnPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                horario.hora, // hora_nova
                style: AppTextStyles.headingMD(color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              // Hora original riscada
              Text(
                alt.horaOriginal,
                style: AppTextStyles.bodyRegular(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                ).copyWith(decoration: TextDecoration.lineThrough),
              ),
            ],
          ),

          // Detalhes da alteração
          if (alt.vanSubstituta != null || alt.motivo != null) ...[
            const SizedBox(height: 8),
            if (alt.vanSubstituta != null)
              _DetalheRow(
                icon: Icons.directions_bus,
                texto: 'Van substituta: ${alt.vanSubstituta}',
              ),
            if (alt.motivo != null)
              _DetalheRow(
                icon: Icons.info_outline,
                texto: alt.motivo!,
              ),
          ],
        ],
      ),
    );
  }
}

class _DetalheRow extends StatelessWidget {
  const _DetalheRow({required this.icon, required this.texto});

  final IconData icon;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              texto,
              style: AppTextStyles.bodyRegular(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
