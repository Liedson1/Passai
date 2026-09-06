import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:passai/core/theme/app_colors.dart';
import 'package:passai/presentation/providers/pwa_provider.dart';
import 'package:passai/presentation/widgets/common/passai_logo.dart';
import 'package:passai/presentation/widgets/web/pwa_install_modal.dart';

final pwaBannerDismissedProvider = StateProvider<bool>((ref) => false);

/// Banner sutil na Home convidando o passageiro a instalar o app na tela inicial.
class PwaInstallBanner extends ConsumerWidget {
  const PwaInstallBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Apenas na Web
    if (!kIsWeb) return const SizedBox.shrink();

    final isDismissed = ref.watch(pwaBannerDismissedProvider);
    if (isDismissed) return const SizedBox.shrink();

    final pwaState = ref.watch(pwaProvider);

    // Se já estiver rodando instalado (standalone) ou não for instalável, esconde
    if (pwaState.isStandalone || pwaState.isInstalled) {
      return const SizedBox.shrink();
    }

    // Apenas exibe se o navegador suportar instalação ou for iOS Safari
    if (!pwaState.canInstall && !pwaState.isIos) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const PassaiLogo(size: 38),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Instale o App Passaí',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  pwaState.isIos
                      ? 'Adicione à tela de início do seu iPhone'
                      : 'Consulte horários com 1 toque na tela inicial',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () => showPwaInstallFlow(context, ref),
            style: TextButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              'Instalar',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 18),
            color: AppColors.textSecondary,
            visualDensity: VisualDensity.compact,
            tooltip: 'Dispensar',
            onPressed: () {
              ref.read(pwaBannerDismissedProvider.notifier).state = true;
            },
          ),
        ],
      ),
    );
  }
}
