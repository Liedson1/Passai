import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:passai/core/constants/app_constants.dart';
import 'package:passai/core/theme/app_colors.dart';
import 'package:passai/presentation/widgets/common/passai_logo.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:passai/presentation/providers/pwa_provider.dart';
import 'package:passai/presentation/widgets/web/pwa_install_modal.dart';

/// Barra de navegação superior para a versão Desktop Web do Passaí
class WebNavbar extends ConsumerWidget implements PreferredSizeWidget {
  const WebNavbar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(68);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pwaState = ref.watch(pwaProvider);

    bool isHomeSelected = false;
    try {
      isHomeSelected =
          GoRouterState.of(context).matchedLocation == AppRoutes.home;
    } catch (_) {
      isHomeSelected = false;
    }

    return Container(
      height: 68,
      width: double.infinity,
      color: AppColors.primary,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1140),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Logo Passaí Oficial (clicável para ir para a Home)
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      try {
                        context.go(AppRoutes.home);
                      } catch (_) {}
                    },
                    child: const PassaiLogo.horizontal(height: 30),
                  ),
                ),

                // Links de navegação pública
                Row(
                  children: [
                    _NavLink(
                      title: 'Buscar Vans',
                      isSelected: isHomeSelected,
                      onTap: () {
                        try {
                          context.go(AppRoutes.home);
                        } catch (_) {}
                      },
                    ),
                    if ((pwaState.canInstall || pwaState.isIos) &&
                        !pwaState.isStandalone &&
                        !pwaState.isInstalled) ...[
                      const SizedBox(width: 20),
                      ElevatedButton.icon(
                        onPressed: () => showPwaInstallFlow(context, ref),
                        icon: const Icon(Icons.download_rounded, size: 16),
                        label: const Text(
                          'Instalar App',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavLink extends StatefulWidget {
  const _NavLink({
    required this.title,
    this.isSelected = false,
    required this.onTap,
  });

  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Text(
          widget.title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: widget.isSelected ? FontWeight.bold : FontWeight.w500,
            color: widget.isSelected || _isHovered
                ? Colors.white
                : Colors.white.withValues(alpha: 0.8),
            decoration: _isHovered ? TextDecoration.underline : null,
            decorationColor: Colors.white,
          ),
        ),
      ),
    );
  }
}
