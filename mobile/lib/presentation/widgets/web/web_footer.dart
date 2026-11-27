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
                // Linha superior com Logo/Descrição e Coluna Legal
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Coluna da Marca
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const PassaiLogo.horizontal(height: 30),
                        const SizedBox(height: 14),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 440),
                          child: const Text(
                            'A plataforma definitiva para consulta de linhas, horários e tarifas de vans intermunicipais e transporte complementar em Alagoas.',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.footerText,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Coluna Legal
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Legal',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _FooterLink(
                          title: 'Termos de Uso',
                          onTap: () => _showInfoDialog(
                            context,
                            'Termos de Uso',
                            'O Passaí é uma plataforma pública e gratuita de consulta aos horários e tarifas das linhas de vans intermunicipais em Alagoas. As informações apresentadas têm caráter estritamente informativo e refletem a programação operacional dos transportadores.',
                          ),
                        ),
                        _FooterLink(
                          title: 'Políticas de Privacidade',
                          onTap: () => _showInfoDialog(
                            context,
                            'Políticas de Privacidade',
                            'No Passaí valorizamos sua privacidade: nosso serviço é 100% aberto, sem necessidade de cadastro, senhas ou coleta de dados cadastrais (RN01 e RN07).',
                          ),
                        ),
                        _FooterLink(
                          title: 'Contato e Suporte',
                          onTap: () => _showInfoDialog(
                            context,
                            'Contato e Suporte',
                            'Para esclarecimentos, sugestões ou suporte sobre horários do transporte complementar em Alagoas, entre em contato com as cooperativas regionais ou envie um e-mail para suporte@passai.app.',
                          ),
                        ),
                      ],
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
                      '© 2026 Passaí. Todos os direitos reservados.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.footerText.withValues(alpha: 0.8),
                      ),
                    ),
                    const Row(
                      children: [
                        _SocialIcon(
                          icon: Icons.alt_route_rounded,
                          tooltip: 'Passaí Alagoas',
                        ),
                        SizedBox(width: 14),
                        _SocialIcon(
                          icon: Icons.public,
                          tooltip: 'Transporte Intermunicipal',
                        ),
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

  void _showInfoDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  const _FooterLink({required this.title, this.onTap});

  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.footerText,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialIcon extends StatelessWidget {
  const _SocialIcon({required this.icon, this.tooltip});

  final IconData icon;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final widget = Icon(
      icon,
      color: AppColors.footerText,
      size: 18,
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: widget);
    }
    return widget;
  }
}
