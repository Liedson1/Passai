import 'package:flutter/material.dart';
import 'package:passai/core/constants/app_constants.dart';
import 'package:passai/core/theme/app_colors.dart';
import 'package:passai/core/theme/app_text_styles.dart';
import 'package:passai/domain/entities/detalhes_viagem.dart';

/// Card com informações do veículo, comodidades e forma de pagamento
class VeiculoCard extends StatelessWidget {
  const VeiculoCard({super.key, required this.detalhes});

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
          Text(
            'Informações do Veículo',
            style: AppTextStyles.bodyBold(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          _buildVeiculoHeader(),
          if (detalhes.comodidades.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildComodidades(),
          ],
          if (detalhes.alterado && detalhes.vanSubstituta != null) ...[
            const SizedBox(height: 12),
            _buildAvisoSubstituicao(),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: AppColors.border, height: 1),
          ),
          Text(
            'Como Pagar',
            style: AppTextStyles.bodyBold(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          _buildPagamentoInfo(),
        ],
      ),
    );
  }

  Widget _buildVeiculoHeader() {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.inputBackground,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.directions_bus_rounded,
            color: AppColors.primary,
            size: 24,
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
                    detalhes.veiculoNumero ?? 'Van de Linha',
                    style: AppTextStyles.bodyBold(
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryLight,
                      borderRadius: BorderRadius.circular(AppRadii.badge),
                    ),
                    child: Text(
                      'Regulamentado',
                      style: AppTextStyles.bodyBold(
                        fontSize: 10,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                (detalhes.veiculoModelo != null &&
                        detalhes.veiculoModelo!.isNotEmpty)
                    ? '${detalhes.veiculoModelo}${detalhes.veiculoPlaca != null ? " • Placa ${detalhes.veiculoPlaca}" : ""}'
                    : 'Transporte Complementar Intermunicipal',
                style: AppTextStyles.bodyRegular(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildComodidades() {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: detalhes.comodidades.map((c) {
        final isAc = c.toLowerCase().contains('ar');
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isAc ? Icons.ac_unit_rounded : Icons.accessible_rounded,
                size: 14,
                color: AppColors.primary,
              ),
              const SizedBox(width: 5),
              Text(
                c,
                style: AppTextStyles.bodyMedium(
                  fontSize: 11,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAvisoSubstituicao() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: BorderRadius.circular(AppRadii.badge),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.warning,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Veículo substituto hoje: ${detalhes.vanSubstituta}${detalhes.alteracaoMotivo != null ? " (${detalhes.alteracaoMotivo})" : ""}',
              style: AppTextStyles.bodyBold(
                fontSize: 12,
                color: AppColors.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagamentoInfo() {
    return Row(
      children: [
        const Icon(
          Icons.payments_outlined,
          size: 18,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                detalhes.formasPagamento.isNotEmpty
                    ? 'Pagamento: ${detalhes.formasPagamento.join(" • ")}'
                    : 'Tarifa paga no embarque',
                style: AppTextStyles.bodySemibold(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                detalhes.responsavelPagamento ??
                    'Pagamento direto com o motorista',
                style: AppTextStyles.bodyRegular(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
