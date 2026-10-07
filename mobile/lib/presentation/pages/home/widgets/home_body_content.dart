import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:passai/core/errors/exceptions.dart';

import 'package:passai/presentation/providers/rotas_provider.dart';
import 'package:passai/presentation/widgets/web/pwa_install_banner.dart';
import 'home_offline_banner.dart';
import 'home_rotas_populares_section.dart';
import 'home_search_card.dart';
import 'why_passai_section.dart';

/// Corpo principal da HomePage mobile — orquestra os sub-widgets de conteúdo
class HomeBodyContent extends ConsumerWidget {
  const HomeBodyContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rotasAsync = ref.watch(todasAsRotasProvider);
    final cidadesAsync = ref.watch(cidadesProvider);

    final isOffline = (rotasAsync.hasError && cidadesAsync.hasError) ||
        (rotasAsync.error is NetworkException ||
            cidadesAsync.error is NetworkException);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isOffline)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: HomeOfflineBanner(
                onRetry: () {
                  ref.invalidate(cidadesProvider);
                  ref.invalidate(todasAsRotasProvider);
                },
              ),
            ),
          const HomeSearchCard(),
          const SizedBox(height: 16),
          const SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                HeroTrustBadge(
                  icon: Icons.check_circle_outline_rounded,
                  label: '100% gratuito e sem cadastro',
                  isLight: false,
                ),
                SizedBox(width: 8),
                HeroTrustBadge(
                  icon: Icons.update_rounded,
                  label: 'Horários do dia atualizados',
                  isLight: false,
                ),
                SizedBox(width: 8),
                HeroTrustBadge(
                  icon: Icons.payments_outlined,
                  label: 'Tarifas oficiais de Alagoas',
                  isLight: false,
                ),
              ],
            ),
          ),
          const PwaInstallBanner(),
          const SizedBox(height: 24),
          const HomeRotasPopularesSection(),
          const SizedBox(height: 24),
          const WhyPassaiSection(isDesktop: false),
        ],
      ),
    );
  }
}
