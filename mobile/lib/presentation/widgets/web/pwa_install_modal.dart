import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:passai/core/theme/app_colors.dart';
import 'package:passai/presentation/providers/pwa_provider.dart';
import 'package:passai/presentation/widgets/common/passai_logo.dart';

/// Exibe o fluxo de instalação do PWA adequado para a plataforma atual:
/// - No Android/Desktop: aciona o prompt nativo do navegador via [PwaNotifier.promptInstall].
/// - No iOS: exibe um modal ilustrado explicando como "Adicionar à Tela de Início" no Safari.
Future<void> showPwaInstallFlow(BuildContext context, WidgetRef ref) async {
  final pwaState = ref.read(pwaProvider);

  if (pwaState.isIos) {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => const _IosInstallSheet(),
    );
    return;
  }

  // No Android ou Desktop, dispara o prompt nativo
  final success = await ref.read(pwaProvider.notifier).promptInstall();
  if (success && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Aplicativo instalado com sucesso!'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _IosInstallSheet extends StatelessWidget {
  const _IosInstallSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const PassaiLogo(size: 56),
            const SizedBox(height: 12),
            const Text(
              'Instalar o Passaí no iPhone',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Acesse horários em tempo real direto da sua tela inicial, sem precisar abrir o Safari.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            const _StepRow(
              number: '1',
              title: 'Toque em Compartilhar',
              description: 'No menu inferior do Safari, toque no ícone com um quadrado e seta para cima.',
              icon: Icons.ios_share_rounded,
            ),
            const SizedBox(height: 16),
            const _StepRow(
              number: '2',
              title: 'Adicionar à Tela de Início',
              description: 'Role as opções para baixo e toque em "Adicionar à Tela de Início".',
              icon: Icons.add_box_outlined,
            ),
            const SizedBox(height: 16),
            const _StepRow(
              number: '3',
              title: 'Confirmar',
              description: 'Toque em "Adicionar" no canto superior direito para concluir.',
              icon: Icons.check_circle_outline_rounded,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Entendi',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.number,
    required this.title,
    required this.description,
    required this.icon,
  });

  final String number;
  final String title;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(icon, size: 16, color: AppColors.primary),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
