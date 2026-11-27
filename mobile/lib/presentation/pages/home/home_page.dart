import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:passai/core/theme/app_colors.dart';
import 'package:passai/data/repositories/rotas_repository_impl.dart';
import 'package:passai/presentation/providers/rotas_provider.dart';
import 'package:passai/presentation/widgets/responsive_shell.dart';
import 'widgets/home_body_content.dart';
import 'widgets/home_desktop_view.dart';
import 'widgets/home_hero_banner.dart';

/// Tela principal do Passaí — consulta de horários de vans
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    if (isDesktop) {
      return const HomeDesktopView();
    }

    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return ResponsiveShell(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Listener(
          onPointerDown: (_) {
            final currentFocus = FocusManager.instance.primaryFocus;
            if (currentFocus != null && currentFocus.hasFocus) {
              currentFocus.unfocus();
            }
          },
          child: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              HapticFeedback.lightImpact();
              // Limpa o cache do repositório para forçar nova consulta ao banco
              final repo = ref.read(rotasRepositoryProvider);
              if (repo is RotasRepositoryImpl) {
                repo.limparCache();
              }
              ref.invalidate(todasAsRotasProvider);
              ref.invalidate(cidadesProvider);
              try {
                await ref.read(todasAsRotasProvider.future);
              } catch (_) {}
            },
            child: CustomScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                const SliverToBoxAdapter(
                  child: HomeHeroBanner(),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, bottomPadding),
                  sliver: const SliverToBoxAdapter(
                    child: HomeBodyContent(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
