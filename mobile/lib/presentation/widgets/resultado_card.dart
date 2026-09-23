import 'package:flutter/material.dart';
import 'package:passai/core/theme/app_colors.dart';
import 'package:passai/core/theme/app_text_styles.dart';
import 'package:passai/core/constants/app_constants.dart';
import 'package:passai/domain/entities/horario.dart';

/// Card individual de resultado na tela de resultados de horários.
/// Exibe horário, preço, nome da rota, duração e tipo de trajeto (direto/paradas).
class ResultadoCard extends StatelessWidget {
  const ResultadoCard({
    super.key,
    required this.horario,
    this.onVerDetalhes,
  });

  final Horario horario;
  final VoidCallback? onVerDetalhes;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: onVerDetalhes != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: onVerDetalhes,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.card),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: AppColors.textPrimary.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Linha 1: Horário + Preço
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Ícone de relógio
                  const Icon(
                    Icons.access_time_rounded,
                    color: AppColors.secondary,
                    size: 22,
                  ),
                  const SizedBox(width: 8),

                  // Horário grande
                  Text(
                    horario.hora,
                    style: AppTextStyles.headingLG(color: AppColors.textPrimary),
                  ),

                  const Spacer(),

                  // Badge de preço
                  if (horario.preco != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(AppRadii.badge),
                      ),
                      child: Text(
                        'R\$ ${horario.preco!.toStringAsFixed(2).replaceAll('.', ',')}',
                        style: AppTextStyles.bodyBold(
                          fontSize: 13,
                          color: AppColors.textOnPrimary,
                        ),
                      ),
                    ),
                ],
              ),

              // Linha 2: Nome da rota
              if (horario.nomeRota != null) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 30),
                  child: Text(
                    horario.nomeRota!,
                    style: AppTextStyles.bodyMedium(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],

              // Linha 3: Duração + Tipo de paradas
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 30),
                child: Row(
                  children: [
                    // Ícone de van
                    const Icon(
                      Icons.directions_bus_outlined,
                      color: AppColors.textSecondary,
                      size: 16,
                    ),
                    const SizedBox(width: 6),

                    // Duração
                    if (horario.duracao != null)
                      Text(
                        horario.duracao!,
                        style: AppTextStyles.bodyRegular(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),

                    const Spacer(),

                    // Pill de paradas
                    if (horario.paradas != null) _ParadasPill(paradas: horario.paradas!),
                  ],
                ),
              ),

              // Banner de alteração (quando horário foi alterado - RN06)
              if (horario.alterado) ...[
                const SizedBox(height: 10),
                _AlteracaoBadge(horario: horario),
              ],

              // Botão Ver no Mapa / Detalhes da Viagem
              if (onVerDetalhes != null) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onVerDetalhes,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.map_outlined, size: 14),
                    label: const Text(
                      'Ver Rota no Mapa',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Pill que indica se a viagem é direta ou tem paradas
class _ParadasPill extends StatelessWidget {
  const _ParadasPill({required this.paradas});

  final String paradas;

  @override
  Widget build(BuildContext context) {
    final isDireto = paradas == 'Direto';
    final bgColor = isDireto ? AppColors.successLight : AppColors.warningLight;
    final textColor = isDireto ? AppColors.success : AppColors.warning;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Text(
        paradas,
        style: AppTextStyles.bodySemibold(fontSize: 11, color: textColor),
      ),
    );
  }
}

/// Badge discreto de alteração dentro do card (RN06)
class _AlteracaoBadge extends StatelessWidget {
  const _AlteracaoBadge({required this.horario});

  final Horario horario;

  @override
  Widget build(BuildContext context) {
    final alt = horario.alteracao;

    // Guard explícito: nunca deveria ser null aqui, mas protege contra refactors futuros
    if (alt == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(AppRadii.badge),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'ALTERADO',
              style: AppTextStyles.bodyBold(
                fontSize: 9,
                color: AppColors.textOnPrimary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Era ${alt.horaOriginal}',
            style: AppTextStyles.bodyRegular(
              fontSize: 12,
              color: AppColors.textSecondary,
            ).copyWith(decoration: TextDecoration.lineThrough),
          ),
          if (alt.motivo != null) ...[
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                '• ${alt.motivo}',
                style: AppTextStyles.bodyRegular(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
