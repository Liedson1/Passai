import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:passai/core/constants/app_constants.dart';
import 'package:passai/core/theme/app_colors.dart';
import 'package:passai/presentation/widgets/web/web_footer.dart';
import 'package:passai/presentation/widgets/web/web_navbar.dart';

/// Layout desktop para a página de detalhes da viagem
class DetalhesViagemDesktopView extends StatelessWidget {
  const DetalhesViagemDesktopView({
    super.key,
    required this.contentItems,
  });

  final List<Widget> contentItems;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: [
            const RepaintBoundary(child: WebNavbar()),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 960),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 36,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go(AppRoutes.home);
                            }
                          },
                          child: const Row(
                            children: [
                              Icon(
                                Icons.arrow_back_rounded,
                                size: 18,
                                color: AppColors.textPrimary,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Voltar para resultados',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ...contentItems,
                    ],
                  ),
                ),
              ),
            ),
            const RepaintBoundary(child: WebFooter()),
          ],
        ),
      ),
    );
  }
}
