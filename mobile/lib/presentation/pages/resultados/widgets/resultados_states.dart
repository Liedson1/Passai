import 'package:flutter/material.dart';
import 'package:passai/core/constants/app_constants.dart';
import 'package:passai/core/theme/app_colors.dart';
import 'package:passai/core/theme/app_text_styles.dart';

/// Banner de aviso quando há alterações no dia (RN06)
class ResultadosAlteracaoBanner extends StatelessWidget {
  const ResultadosAlteracaoBanner({super.key, required this.quantidade});

  final int quantidade;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(AppRadii.input),
        border: Border.all(color: const Color(0x80FFD700)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFF856404),
            size: 20,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              '$quantidade horário${quantidade > 1 ? 's' : ''} '
              'foi alterado hoje. Os itens marcados indicam a mudança.',
              style: AppTextStyles.bodyRegular(
                fontSize: 13,
                color: const Color(0xFF856404),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Estado vazio — sem horários disponíveis para os filtros selecionados
class ResultadosEmptyState extends StatelessWidget {
  const ResultadosEmptyState({super.key, this.isFiltroAtivo = false});

  final bool isFiltroAtivo;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.directions_bus_outlined,
            size: 60,
            color: AppColors.border,
          ),
          const SizedBox(height: 16),
          Text(
            isFiltroAtivo
                ? 'Nenhum horário neste período'
                : 'Nenhum horário disponível',
            style: AppTextStyles.headingMD(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            isFiltroAtivo
                ? 'Tente selecionar outro período ou outra data.'
                : 'Não há horários cadastrados para esta data.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyRegular(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Estado de erro — falha ao carregar horários
class ResultadosErrorState extends StatelessWidget {
  const ResultadosErrorState({
    super.key,
    required this.message,
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              size: 60,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar horários',
              style: AppTextStyles.headingMD(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              message.contains('Exception') ||
                      message.contains('Socket') ||
                      message.contains('Postgrest')
                  ? 'Não foi possível carregar os horários. Verifique sua conexão e tente novamente.'
                  : message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyRegular(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.button),
                  ),
                ),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Tentar novamente'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
