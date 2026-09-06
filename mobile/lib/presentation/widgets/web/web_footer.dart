import 'package:flutter/material.dart';
import 'package:passai/core/theme/app_colors.dart';
import 'package:passai/presentation/widgets/common/passai_logo.dart';

/// Rodapé escuro completo para a versão Desktop Web do Passaí
class WebFooter extends StatelessWidget {
  const WebFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.footerBackground,
      padding: const EdgeInsets.only(top: 56, bottom: 36),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1140),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Linha superior com Logo/Descrição e Colunas de Links
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Coluna da Marca
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const PassaiLogo.horizontal(height: 30),
                          const SizedBox(height: 14),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 380),
                            child: const Text(
                              'A plataforma definitiva para consulta de linhas, horários e tarifas de vans intermunicipais e transporte complementar no Sertão de Alagoas.',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.footerText,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 32),

                    // Coluna Cidades Atendidas
                    const Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cidades Atendidas',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 12),
                          _FooterLink(title: 'Delmiro Gouveia'),
                          _FooterLink(title: 'Piranhas'),
                          _FooterLink(title: 'Arapiraca'),
                          _FooterLink(title: 'Maceió'),
                        ],
                      ),
                    ),

                    // Coluna Legal
                    const Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Legal',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 12),
                          _FooterLink(title: 'Termos de Uso'),
                          _FooterLink(title: 'Políticas de Privacidade'),
                          _FooterLink(title: 'Contato e Suporte'),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),
                const Divider(color: Color(0xFF382E2A), height: 1),
                const SizedBox(height: 24),

                // Linha inferior de Copyright e Redes
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '© 2026 Passaí. Todos os direitos reservados. Desenvolvimento focado na mobilidade sertaneja.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.footerText.withValues(alpha: 0.8),
                      ),
                    ),
                    const Row(
                      children: [
                        _SocialIcon(icon: Icons.camera_alt_outlined),
                        SizedBox(width: 14),
                        _SocialIcon(icon: Icons.public),
                      ],
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

class _FooterLink extends StatelessWidget {
  const _FooterLink({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.footerText,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }
}

class _SocialIcon extends StatelessWidget {
  const _SocialIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Icon(
        icon,
        color: AppColors.footerText,
        size: 18,
      ),
    );
  }
}
