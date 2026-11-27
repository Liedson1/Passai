import 'package:flutter/material.dart';
import 'package:passai/core/theme/app_colors.dart';
import 'package:passai/core/theme/app_text_styles.dart';

/// Pílula de confiança para exibição rápida no Hero
class HeroTrustBadge extends StatelessWidget {
  const HeroTrustBadge({
    super.key,
    required this.icon,
    required this.label,
    this.isLight = true,
  });

  final IconData icon;
  final String label;
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isLight
            ? Colors.white.withValues(alpha: 0.16)
            : AppColors.primaryLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isLight
              ? Colors.white.withValues(alpha: 0.25)
              : AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isLight ? AppColors.titleGold : AppColors.primary,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isLight ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Seção de Marketing e Proposta de Valor do Passaí:
/// Explica as dores que o app soluciona, benefícios e público-alvo
class WhyPassaiSection extends StatelessWidget {
  const WhyPassaiSection({
    super.key,
    this.isDesktop = false,
  });

  final bool isDesktop;

  static const _beneficios = [
    _BeneficioItem(
      icon: Icons.payments_outlined,
      tag: 'Sem Surpresas',
      tagColor: AppColors.amber,
      tagBgColor: AppColors.amberLight,
      titulo: 'Preço certo antes de sair de casa',
      descricao:
          'Consulte o valor exato da tarifa com antecedência. Sem surpresas ou dúvidas de quanto vai custar a passagem no momento do embarque.',
    ),
    _BeneficioItem(
      icon: Icons.bolt_rounded,
      tag: 'Zero Burocracia',
      tagColor: AppColors.success,
      tagBgColor: AppColors.successLight,
      titulo: 'Direto ao ponto, sem login',
      descricao:
          'Nada de cadastros obrigatórios, confirmações de e-mail ou senhas. O aplicativo é 100% aberto e gratuito para qualquer cidadão consultar em segundos.',
    ),
    _BeneficioItem(
      icon: Icons.map_outlined,
      tag: 'Conexão Estadual',
      tagColor: AppColors.secondary,
      tagBgColor: AppColors.secondaryLight,
      titulo: 'Tudo em um único lugar',
      descricao:
          'Toda a malha do transporte complementar organizada em um só lugar. Encontre rotas, primeiras e últimas viagens para planejar seu dia com tranquilidade.',
    ),
  ];

  static const _publicos = [
    _PublicoItem(
      icone: Icons.school_outlined,
      titulo: 'Estudantes',
      descricao:
          'Acesso rápido a horários de ida e volta para universidades, institutos federais e polos educacionais.',
    ),
    _PublicoItem(
      icone: Icons.work_outline_rounded,
      titulo: 'Trabalhadores',
      descricao:
          'Garantia do primeiro horário da manhã e retorno certo após o expediente, sem perder o dia de serviço.',
    ),
    _PublicoItem(
      icone: Icons.local_hospital_outlined,
      titulo: 'Saúde e Serviços',
      descricao:
          'Planejamento seguro para consultas, exames médicos e compras nas cidades polo com volta garantida.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    if (isDesktop) {
      return _buildDesktop(context);
    }
    return _buildMobile(context);
  }

  Widget _buildDesktop(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 68, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header da Seção
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        'POR QUE O PASSAÍ?',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Feito para a realidade do transporte intermunicipal',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.6,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 640),
                      child: const Text(
                        'Eliminamos a incerteza do ponto de van para que você se desloque por Alagoas com total segurança e pontualidade.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // Grid com os 3 Benefícios Reais
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int i = 0; i < _beneficios.length; i++) ...[
                    if (i > 0) const SizedBox(width: 20),
                    Expanded(child: _BeneficioCard(item: _beneficios[i])),
                  ],
                ],
              ),

              const SizedBox(height: 56),

              // Bloco "Para quem foi feito"
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 20,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Desenvolvido para quem vive na estrada',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _publicos.map((pub) {
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: _PublicoCard(item: pub),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobile(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              'POR QUE O PASSAÍ?',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Feito para a realidade de quem viaja de van',
            style: AppTextStyles.headingMD(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            'Menos incerteza na parada e mais segurança para a sua rotina em Alagoas.',
            style: AppTextStyles.bodyRegular(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),

          // Cards de Benefícios
          ..._beneficios.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _BeneficioCard(item: item),
            );
          }),

          const SizedBox(height: 20),

          // Bloco Para Quem É
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Para quem o Passaí foi feito?',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 14),
                ..._publicos.map((pub) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Icon(
                            pub.icone,
                            size: 16,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pub.titulo,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                pub.descricao,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BeneficioItem {
  const _BeneficioItem({
    required this.icon,
    required this.tag,
    required this.tagColor,
    required this.tagBgColor,
    required this.titulo,
    required this.descricao,
  });

  final IconData icon;
  final String tag;
  final Color tagColor;
  final Color tagBgColor;
  final String titulo;
  final String descricao;
}

class _BeneficioCard extends StatelessWidget {
  const _BeneficioCard({required this.item});

  final _BeneficioItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: item.tagBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, color: item.tagColor, size: 22),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: item.tagBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  item.tag,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: item.tagColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            item.titulo,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.descricao,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _PublicoItem {
  const _PublicoItem({
    required this.icone,
    required this.titulo,
    required this.descricao,
  });

  final IconData icone;
  final String titulo;
  final String descricao;
}

class _PublicoCard extends StatelessWidget {
  const _PublicoCard({required this.item});

  final _PublicoItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item.icone, size: 20, color: AppColors.primary),
          ),
          const SizedBox(height: 12),
          Text(
            item.titulo,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.descricao,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
