import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:passai/core/theme/app_colors.dart';
import 'package:passai/core/theme/app_text_styles.dart';
import 'package:passai/core/constants/app_constants.dart';
import 'package:passai/domain/entities/detalhes_viagem.dart';
import 'package:passai/domain/entities/parada_itinerario.dart';
import 'package:passai/presentation/providers/paradas_provider.dart';
import 'package:passai/presentation/widgets/responsive_shell.dart';

/// Argumentos de navegação para a tela de detalhes da viagem
class DetalhesViagemArgs {
  const DetalhesViagemArgs({
    required this.detalhes,
    this.rotaId,
    this.sentido,
  });

  final DetalhesViagem detalhes;

  /// ID da rota no Supabase — quando fornecido, o itinerário é buscado do banco
  final int? rotaId;

  /// 'IDA' ou 'VOLTA' — obrigatório quando [rotaId] é fornecido
  final String? sentido;

  /// Indica se há dados suficientes para buscar paradas do Supabase
  bool get temDadosParaBusca => rotaId != null && sentido != null;
}

/// Tela de Detalhes da Viagem — exibe itinerário completo, código da linha,
/// preço, rota e paradas intermediárias de uma viagem selecionada.
/// Quando [rotaId] e [sentido] são fornecidos, busca o itinerário real do Supabase.
/// Caso contrário, exibe o itinerário estático passado em [DetalhesViagem.itinerario].
class DetalhesViagemPage extends ConsumerWidget {
  const DetalhesViagemPage({super.key, required this.args});

  final DetalhesViagemArgs args;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detalhes = args.detalhes;

    // Busca paradas do Supabase quando rotaId e sentido estão disponíveis
    final paradasAsync = args.temDadosParaBusca
        ? ref.watch(paradasRotaProvider(
            ParadasParams(rotaId: args.rotaId!, sentido: args.sentido!),
          ))
        : null;

    return ResponsiveShell(
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.home);
            }
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            physics: const ClampingScrollPhysics(),
            slivers: [
              // AppBar com título e subtítulo
              _DetalhesAppBar(detalhes: detalhes),

              // Conteúdo principal
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Card de identificação da rota
                    _IdentificacaoCard(detalhes: detalhes),
                    const SizedBox(height: 24),

                    // Seção de itinerário — real do banco ou estático
                    if (paradasAsync != null)
                      paradasAsync.when(
                        loading: () => _SecaoItinerario(
                          itinerario: detalhes.itinerario,
                          horaSaida: detalhes.horaSaida,
                          isLoading: true,
                        ),
                        error: (_, __) => _SecaoItinerario(
                          itinerario: detalhes.itinerario,
                          horaSaida: detalhes.horaSaida,
                        ),
                        data: (paradas) {
                          // Quando o banco retorna paradas, usa-as; caso contrário,
                          // cai no itinerário estático (fallback)
                          final itinerario = paradas.isNotEmpty
                              ? paradas
                              : detalhes.itinerario;
                          return _SecaoItinerario(
                            itinerario: itinerario,
                            horaSaida: detalhes.horaSaida,
                          );
                        },
                      )
                    else
                      _SecaoItinerario(
                        itinerario: detalhes.itinerario,
                        horaSaida: detalhes.horaSaida,
                      ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// AppBar customizada com título e subtítulo da viagem
// ---------------------------------------------------------------------------
class _DetalhesAppBar extends StatelessWidget {
  const _DetalhesAppBar({required this.detalhes});

  final DetalhesViagem detalhes;

  @override
  Widget build(BuildContext context) {
    final subtitulo = [
      if (detalhes.horaSaida != null) 'Saída às ${detalhes.horaSaida}',
      if (detalhes.tipoLinha != null) detalhes.tipoLinha!,
    ].join(' • ');

    return SliverAppBar(
      pinned: true,
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      surfaceTintColor: Colors.transparent,
      shadowColor: AppColors.border,
      elevation: 1,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        tooltip: 'Voltar',
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go(AppRoutes.home);
          }
        },
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Detalhes da Viagem',
            style: AppTextStyles.headingMD(color: AppColors.textPrimary),
          ),
          if (subtitulo.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              subtitulo,
              style: AppTextStyles.bodyRegular(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Card de identificação: código, preço, rota e via
// ---------------------------------------------------------------------------
class _IdentificacaoCard extends StatelessWidget {
  const _IdentificacaoCard({required this.detalhes});

  final DetalhesViagem detalhes;

  String _getBadgeText() {
    final raw = detalhes.codigo.trim();
    // Se o código for longo ou repetir o trajeto (ex: "Arapiraca x Maceió (via LITORAL)"),
    // prioriza o tipo da linha ("Linha Intermunicipal") para evitar redundância e quebras
    final isRouteOrLong = raw.toLowerCase().contains(' x ') ||
        raw.toLowerCase().contains(' - ') ||
        raw.length > 22;

    if (isRouteOrLong) {
      return detalhes.tipoLinha ?? 'Linha Intermunicipal';
    }

    if (raw.toLowerCase().startsWith('linha') ||
        raw.toLowerCase().startsWith('código') ||
        raw.toLowerCase().startsWith('codigo')) {
      return raw;
    }

    return 'Linha $raw';
  }

  @override
  Widget build(BuildContext context) {
    final badgeText = _getBadgeText();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Linha superior: badge do tipo/código + preço em destaque
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Badge flexível (nunca transborda nem empurra o preço para fora)
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryLight,
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                    border: Border.all(
                      color: AppColors.secondary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    badgeText,
                    style: AppTextStyles.bodySemibold(
                      fontSize: 12,
                      color: AppColors.secondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),

              if (detalhes.preco.isNotEmpty) ...[
                const SizedBox(width: 12),
                // Preço em destaque sempre contido no card
                Text(
                  detalhes.preco,
                  style: AppTextStyles.headingMD(color: AppColors.primary),
                ),
              ],
            ],
          ),

          const SizedBox(height: 12),

          // Nome da rota
          Text(
            detalhes.rota,
            style: AppTextStyles.bodySemibold(
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),

          // Via (quando existir)
          if (detalhes.via != null && detalhes.via!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              detalhes.via!,
              style: AppTextStyles.bodyRegular(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Seção de itinerário com linha do tempo visual
// ---------------------------------------------------------------------------
class _SecaoItinerario extends StatelessWidget {
  const _SecaoItinerario({
    required this.itinerario,
    this.horaSaida,
    this.isLoading = false,
  });

  final List<ParadaItinerario> itinerario;
  final String? horaSaida;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título da seção
        Text(
          'Itinerário & Paradas',
          style: AppTextStyles.headingMD(color: AppColors.textPrimary),
        ),
        const SizedBox(height: 16),

        // Container do itinerário
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.card),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: AppColors.textPrimary.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: isLoading
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2,
                    ),
                  ),
                )
              : Column(
                  children: List.generate(itinerario.length, (index) {
                    final parada = itinerario[index];
                    final isFirst = index == 0;
                    final isLast = index == itinerario.length - 1;

                    // Exibe horário de saída apenas na primeira parada
                    final horarioExibido = isFirst && horaSaida != null
                        ? horaSaida!
                        : parada.horario;

                    return _ItemItinerario(
                      parada: parada.copyWith(horario: horarioExibido),
                      isFirst: isFirst,
                      isLast: isLast,
                      showConnector: !isLast,
                    );
                  }),
                ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Item individual do itinerário com linha do tempo
// ---------------------------------------------------------------------------
class _ItemItinerario extends StatelessWidget {
  const _ItemItinerario({
    required this.parada,
    required this.isFirst,
    required this.isLast,
    required this.showConnector,
  });

  final ParadaItinerario parada;
  final bool isFirst;
  final bool isLast;
  final bool showConnector;

  /// Cor do indicador visual: vermelho para partida/chegada, teal para intermediárias
  Color get _indicadorColor {
    if (isFirst || isLast) return AppColors.primary;
    return AppColors.secondary;
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Coluna visual da linha do tempo
          SizedBox(
            width: 56,
            child: Column(
              children: [
                const SizedBox(height: 18),
                // Indicador (círculo preenchido ou vazio)
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isFirst || isLast
                        ? _indicadorColor
                        : Colors.transparent,
                    border: Border.all(
                      color: _indicadorColor,
                      width: 2,
                    ),
                  ),
                ),
                // Conector vertical até a próxima parada
                if (showConnector)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.only(top: 4),
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Conteúdo da parada
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: 20,
                top: 12,
                bottom: showConnector ? 12 : 16,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nome e descrição da parada
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          parada.parada,
                          style: AppTextStyles.bodySemibold(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (parada.descricao != null &&
                            parada.descricao!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            parada.descricao!,
                            style: AppTextStyles.bodyRegular(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Horário (exibido apenas quando disponível)
                  if (parada.horario.isNotEmpty)
                    Text(
                      parada.horario,
                      style: AppTextStyles.bodyBold(
                        fontSize: 14,
                        color: AppColors.secondary,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
