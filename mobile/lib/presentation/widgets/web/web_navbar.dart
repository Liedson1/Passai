import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:passai/core/constants/app_constants.dart';
import 'package:passai/core/theme/app_colors.dart';
import 'package:passai/presentation/widgets/common/passai_logo.dart';

/// Barra de navegação superior para a versão Desktop Web do Passaí
class WebNavbar extends StatelessWidget implements PreferredSizeWidget {
  const WebNavbar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(68);

  @override
  Widget build(BuildContext context) {
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
                    onTap: () => context.go(AppRoutes.home),
                    child: const PassaiLogo.horizontal(height: 30),
                  ),
                ),

                // Links de navegação pública
                Row(
                  children: [
                    _NavLink(
                      title: 'Buscar Vans',
                      isSelected: true,
                      onTap: () => context.go(AppRoutes.home),
                    ),
                    const SizedBox(width: 24),
                    _NavLink(
                      title: 'Rotas e Horários',
                      onTap: () => context.go(AppRoutes.home),
                    ),
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
