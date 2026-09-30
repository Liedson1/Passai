import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:passai/core/theme/app_colors.dart';
import 'package:passai/core/theme/app_text_styles.dart';
import 'package:passai/core/constants/app_constants.dart';
import 'package:passai/domain/entities/detalhes_viagem.dart';
import 'package:passai/domain/entities/parada_itinerario.dart';
import 'package:passai/presentation/providers/paradas_provider.dart';
import 'package:passai/presentation/widgets/responsive_shell.dart';
import 'package:passai/presentation/widgets/web/web_navbar.dart';
import 'package:passai/presentation/widgets/web/web_footer.dart';

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

/// Tela de Detalhes da Viagem no padrão visual do Passaí
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

    final isDesktop = MediaQuery.of(context).size.width > 800;

    final contentItems = [
      // 1. Card de resumo da rota
      _RouteSummaryCard(detalhes: detalhes),
      const SizedBox(height: 12),

      // 2. Informações do veículo
      _VeiculoCard(detalhes: detalhes),
      const SizedBox(height: 20),

      // 3. Seção de itinerário
      if (paradasAsync != null)
        paradasAsync.when(
          loading: () => _SecaoItinerario(
            detalhes: detalhes,
            itinerario: detalhes.itinerario,
            isLoading: true,
          ),
          error: (_, __) => _SecaoItinerario(
            detalhes: detalhes,
            itinerario: detalhes.itinerario,
          ),
          data: (paradas) {
            final listaBruta =
                paradas.isNotEmpty ? paradas : detalhes.itinerario;
            final itinerarioProcessado = _enriquecerItinerario(
              paradas: listaBruta,
              horaSaida: detalhes.horaSaida,
              duracaoStr: detalhes.duracao,
              chegadaPrevista: detalhes.chegadaPrevista,
              origemFallback: detalhes.origem,
              destinoFallback: detalhes.destino,
            );
            return _SecaoItinerario(
              detalhes: detalhes,
              itinerario: itinerarioProcessado,
            );
          },
        )
      else
        _SecaoItinerario(
          detalhes: detalhes,
          itinerario: _enriquecerItinerario(
            paradas: detalhes.itinerario,
            horaSaida: detalhes.horaSaida,
            duracaoStr: detalhes.duracao,
            chegadaPrevista: detalhes.chegadaPrevista,
            origemFallback: detalhes.origem,
            destinoFallback: detalhes.destino,
          ),
        ),
      const SizedBox(height: 16),

      // 4. Card de recomendação
      _RecomendacaoCard(detalhes: detalhes),
      const SizedBox(height: 24),

      // 5. Ações do rodapé
      _AcoesFooter(detalhes: detalhes, args: args),
    ];

    if (isDesktop) {
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
              // AppBar no padrão do site
              _DetalhesAppBar(detalhes: detalhes),

              // Conteúdo principal
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(contentItems),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Calcula horários proporcionais estimados para nós intermediários.
  static List<ParadaItinerario> _enriquecerItinerario({
    required List<ParadaItinerario> paradas,
    required String? horaSaida,
    required String? duracaoStr,
    required String? chegadaPrevista,
    String? origemFallback,
    String? destinoFallback,
  }) {
    if (paradas.isEmpty) return const [];

    final total = paradas.length;
    final saidaStr = horaSaida ?? (paradas.isNotEmpty ? paradas.first.horario : '05:15');

    int saidaMinutos = 315;
    try {
      final parts = saidaStr.split(':');
      saidaMinutos = int.parse(parts[0]) * 60 + int.parse(parts[1]);
    } catch (_) {}

    int duracaoMinutos = 105;
    if (duracaoStr != null && duracaoStr.isNotEmpty) {
      try {
        if (duracaoStr.contains('h')) {
          final parts = duracaoStr.split('h');
          final h = int.parse(parts[0].trim());
          final mStr = parts[1].replaceAll(RegExp(r'[^\d]'), '').trim();
          final m = mStr.isNotEmpty ? int.parse(mStr) : 0;
          duracaoMinutos = h * 60 + m;
        } else if (duracaoStr.contains('min')) {
          final mStr = duracaoStr.replaceAll(RegExp(r'[^\d]'), '').trim();
          duracaoMinutos = int.parse(mStr);
        }
      } catch (_) {}
    }

    final resultado = <ParadaItinerario>[];

    for (int i = 0; i < total; i++) {
      final item = paradas[i];
      final isFirst = i == 0;
      final isLast = i == total - 1;

      String horaCalculada;
      String tipo;
      String? ponto;
      List<String> tags = [];
      String? observacao;

      if (isFirst) {
        tipo = 'origem';
        horaCalculada = saidaStr;
        ponto = item.descricao != null && item.descricao!.isNotEmpty
            ? item.descricao
            : 'Terminal Rodoviário • Ponto de Partida';
        tags = const ['Ponto de Partida', 'Embarque'];
      } else if (isLast) {
        tipo = 'destino';
        if (chegadaPrevista != null && chegadaPrevista.isNotEmpty) {
          horaCalculada = chegadaPrevista;
        } else {
          final totalChegada = (saidaMinutos + duracaoMinutos) % 1440;
          final h = (totalChegada ~/ 60).toString().padLeft(2, '0');
          final m = (totalChegada % 60).toString().padLeft(2, '0');
          horaCalculada = '$h:$m';
        }
        ponto = item.descricao != null && item.descricao!.isNotEmpty
            ? item.descricao
            : 'Terminal Central • Ponto de Chegada';
        tags = const ['Ponto de Chegada', 'Desembarque final'];
      } else {
        tipo = 'intermediaria';
        final fracao = i / (total - 1);
        final estimativaMin = saidaMinutos + (duracaoMinutos * fracao).round();
        final arredondado = ((estimativaMin + 2) ~/ 5) * 5;
        final h = ((arredondado ~/ 60) % 24).toString().padLeft(2, '0');
        final m = (arredondado % 60).toString().padLeft(2, '0');
        horaCalculada = '$h:$m';

        ponto = item.descricao != null && item.descricao!.isNotEmpty
            ? item.descricao
            : (item.parada.isNotEmpty ? item.parada : 'Parada intermediária');
        observacao = item.observacao ?? 'Embarque e desembarque rápido';
      }

      resultado.add(
        item.copyWith(
          horario: horaCalculada,
          tipo: tipo,
          descricao: ponto,
          tags: tags,
          observacao: observacao,
        ),
      );
    }

    return resultado;
  }
}

// ---------------------------------------------------------------------------
// 1. AppBar no padrão Passaí (terracota com FlexibleSpaceBar)
// ---------------------------------------------------------------------------
class _DetalhesAppBar extends StatelessWidget {
  const _DetalhesAppBar({required this.detalhes});

  final DetalhesViagem detalhes;

  @override
  Widget build(BuildContext context) {
    final origem = detalhes.origem ?? '';
    final destino = detalhes.destino ?? '';
    final tipoLinha = detalhes.tipoLinha;

    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: AppColors.primary,
      iconTheme: const IconThemeData(color: AppColors.textOnPrimary),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textOnPrimary),
        tooltip: 'Voltar',
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go(AppRoutes.home);
          }
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share_outlined, color: AppColors.textOnPrimary),
          tooltip: 'Compartilhar viagem',
          onPressed: () => _compartilharViagem(context, detalhes),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: AppColors.primary,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Origem → Destino
              if (origem.isNotEmpty && destino.isNotEmpty)
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        origem,
                        style: AppTextStyles.headingLG(color: AppColors.textOnPrimary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(Icons.arrow_forward, color: AppColors.textOnPrimary, size: 18),
                    ),
                    Flexible(
                      child: Text(
                        destino,
                        style: AppTextStyles.headingLG(color: AppColors.textOnPrimary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                )
              else
                Text(
                  detalhes.rota,
                  style: AppTextStyles.headingLG(color: AppColors.textOnPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 6),
              // Badges (Linha e Status Operacional)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  // Badge de tipo de linha / sentido
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.heroOverlay,
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                    ),
                    child: Text(
                      [
                        if (tipoLinha.isNotEmpty) tipoLinha,
                        if (detalhes.horaSaida != null) 'Saída ${detalhes.horaSaida}',
                      ].join(' • '),
                      style: AppTextStyles.bodyBold(fontSize: 12, color: AppColors.textOnPrimary),
                    ),
                  ),
                  // Badge de cooperativa / transporte
                  if (detalhes.cooperativa != null && detalhes.cooperativa!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.heroOverlay,
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                      ),
                      child: Text(
                        detalhes.cooperativa!,
                        style: AppTextStyles.bodyBold(fontSize: 12, color: AppColors.textOnPrimary),
                      ),
                    ),
                  // Badge de status operacional
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: detalhes.alterado ? AppColors.warningLight : AppColors.successLight,
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle, 
                            color: detalhes.alterado ? AppColors.warning : AppColors.success,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          detalhes.alterado ? 'Horário Alterado Hoje' : detalhes.status,
                          style: AppTextStyles.bodyBold(
                            fontSize: 12, 
                            color: detalhes.alterado ? AppColors.warning : AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void _compartilharViagem(BuildContext context, DetalhesViagem detalhes) {
    final buffer = StringBuffer();
    buffer.writeln('🚐 *Passaí — Detalhes da Viagem*');
    buffer.writeln('Linha: ${detalhes.rota}');
    if (detalhes.via != null) buffer.writeln('Via: ${detalhes.via}');
    if (detalhes.horaSaida != null) buffer.writeln('Partida: ${detalhes.horaSaida}');
    if (detalhes.chegadaPrevista != null) buffer.writeln('Chegada prevista: ${detalhes.chegadaPrevista}');
    buffer.writeln('Tarifa: ${detalhes.preco} (por assento)');
    buffer.writeln('Veículo: ${detalhes.veiculoNumero ?? "Van"} (${detalhes.veiculoModelo})');
    buffer.writeln('\nItinerário:');
    for (int i = 0; i < detalhes.itinerario.length; i++) {
      final p = detalhes.itinerario[i];
      buffer.writeln('${i + 1}. ${p.parada} ${p.horario.isNotEmpty ? "(${p.horario})" : ""}');
    }
    buffer.writeln('\nConsulte horários no Passaí!');

    Clipboard.setData(ClipboardData(text: buffer.toString()));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Expanded(child: Text('Detalhes copiados para a área de transferência!')),
          ],
        ),
        backgroundColor: AppColors.primaryDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}



// ---------------------------------------------------------------------------
// 3. Card de Resumo da Rota
// ---------------------------------------------------------------------------
class _RouteSummaryCard extends StatelessWidget {
  const _RouteSummaryCard({required this.detalhes});

  final DetalhesViagem detalhes;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho: ícone + título genérico
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.directions_bus_filled, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Resumo da Viagem',
                  style: AppTextStyles.headingMD(color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Destaque de Tarifa
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TARIFA OFICIAL',
                      style: AppTextStyles.bodyBold(
                        fontSize: 11,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      detalhes.preco.isNotEmpty ? detalhes.preco : 'A consultar',
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    'por assento',
                    style: AppTextStyles.bodySemibold(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Grid de métricas
          Row(
            children: [
              Expanded(
                child: _MetricaItem(
                  icon: Icons.flag_outlined,
                  label: 'Chegada Prevista',
                  valor: detalhes.chegadaPrevista ?? '--:--',
                  destaque: true,
                  corDestaque: AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _MetricaItem(
                  icon: Icons.hourglass_empty_rounded,
                  label: 'Duração',
                  valor: detalhes.duracao ?? '1h 45m',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MetricaItem(
                  icon: Icons.straighten_rounded,
                  label: 'Extensão',
                  valor: detalhes.distancia ?? '85 km',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Item de métrica reutilizável
class _MetricaItem extends StatelessWidget {
  const _MetricaItem({
    required this.icon,
    required this.label,
    required this.valor,
    this.destaque = false,
    this.corDestaque,
  });

  final IconData icon;
  final String label;
  final String valor;
  final bool destaque;
  final Color? corDestaque;

  @override
  Widget build(BuildContext context) {
    final activeColor = corDestaque ?? AppColors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: destaque ? activeColor : AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodyRegular(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  valor,
                  style: AppTextStyles.bodyBold(
                    fontSize: 13,
                    color: destaque ? activeColor : AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 4. Card de Veículo
// ---------------------------------------------------------------------------
class _VeiculoCard extends StatelessWidget {
  const _VeiculoCard({required this.detalhes});

  final DetalhesViagem detalhes;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informações do Veículo',
            style: AppTextStyles.bodyBold(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          // Ícone + identificação do veículo
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.inputBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.directions_bus_rounded, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          detalhes.veiculoNumero ?? 'Van de Linha',
                          style: AppTextStyles.bodyBold(
                            fontSize: 15,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryLight,
                            borderRadius: BorderRadius.circular(AppRadii.badge),
                          ),
                          child: Text(
                            'Regulamentado',
                            style: AppTextStyles.bodyBold(
                              fontSize: 10,
                              color: AppColors.secondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      (detalhes.veiculoModelo != null && detalhes.veiculoModelo!.isNotEmpty)
                          ? '${detalhes.veiculoModelo}${detalhes.veiculoPlaca != null ? " • Placa ${detalhes.veiculoPlaca}" : ""}'
                          : 'Transporte Complementar Intermunicipal',
                      style: AppTextStyles.bodyRegular(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Chips de comodidades
          if (detalhes.comodidades.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: detalhes.comodidades.map((c) {
                final isAc = c.toLowerCase().contains('ar');
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isAc ? Icons.ac_unit_rounded : Icons.accessible_rounded,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        c,
                        style: AppTextStyles.bodyMedium(
                          fontSize: 11,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],

          // Alerta de substituição de van (RN04)
          if (detalhes.alterado && detalhes.vanSubstituta != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.warningLight,
                borderRadius: BorderRadius.circular(AppRadii.badge),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: AppColors.warning, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Veículo substituto hoje: ${detalhes.vanSubstituta}${detalhes.alteracaoMotivo != null ? " (${detalhes.alteracaoMotivo})" : ""}',
                      style: AppTextStyles.bodyBold(
                        fontSize: 12,
                        color: AppColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: AppColors.border, height: 1),
          ),
          Text(
            'Como Pagar',
            style: AppTextStyles.bodyBold(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),

          // Forma de pagamento
          Row(
            children: [
              const Icon(Icons.payments_outlined, size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      detalhes.formasPagamento.isNotEmpty
                          ? 'Pagamento: ${detalhes.formasPagamento.join(" • ")}'
                          : 'Tarifa paga no embarque',
                      style: AppTextStyles.bodySemibold(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      detalhes.responsavelPagamento ?? 'Pagamento direto com o motorista',
                      style: AppTextStyles.bodyRegular(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 5. Seção de Itinerário com Timeline
// ---------------------------------------------------------------------------
class _SecaoItinerario extends StatelessWidget {
  const _SecaoItinerario({
    required this.detalhes,
    required this.itinerario,
    this.isLoading = false,
  });

  final DetalhesViagem detalhes;
  final List<ParadaItinerario> itinerario;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Itinerário & Paradas',
                style: AppTextStyles.headingMD(color: AppColors.textPrimary),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppRadii.badge),
                ),
                child: Text(
                  '${itinerario.length} paradas',
                  style: AppTextStyles.bodyBold(fontSize: 11, color: AppColors.primaryDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (isLoading)
            const _TimelineSkeleton()
          else if (itinerario.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'Itinerário não disponível para esta viagem.',
                  style: AppTextStyles.bodyRegular(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            Column(
              children: List.generate(itinerario.length, (index) {
                final parada = itinerario[index];
                final isFirst = index == 0 || parada.tipo == 'origem';
                final isLast = index == itinerario.length - 1 || parada.tipo == 'destino';

                return _TimelineNode(
                  parada: parada,
                  isFirst: isFirst,
                  isLast: isLast,
                  ordem: index + 1,
                );
              }),
            ),
        ],
      ),
    );
  }
}

// Skeleton de loading para a timeline
class _TimelineSkeleton extends StatelessWidget {
  const _TimelineSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(3, (index) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 32,
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.border,
                    ),
                  ),
                  if (index < 2)
                    Container(
                      width: 2,
                      height: 40,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: AppColors.border,
                    ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 120,
                      height: 16,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 200,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.border.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

// Nó individual da timeline
class _TimelineNode extends StatelessWidget {
  const _TimelineNode({
    required this.parada,
    required this.isFirst,
    required this.isLast,
    required this.ordem,
  });

  final ParadaItinerario parada;
  final bool isFirst;
  final bool isLast;
  final int ordem;

  Color get _nodeColor {
    if (isFirst) return AppColors.primary;
    if (isLast) return AppColors.secondary;
    return AppColors.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Coluna visual do nó e linha conectora
          SizedBox(
            width: 32,
            child: Column(
              children: [
                const SizedBox(height: 12),
                // Nó estilizado (ícone circular com ponto interno)
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isFirst || isLast ? _nodeColor : AppColors.surface,
                    border: Border.all(color: _nodeColor, width: isFirst || isLast ? 3 : 2.5),
                    boxShadow: isFirst || isLast
                        ? [
                            BoxShadow(
                              color: _nodeColor.withValues(alpha: 0.25),
                              blurRadius: 6,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: isFirst || isLast
                      ? Center(
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : null,
                ),
                // Linha conectora
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: AppColors.border,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Informações da parada
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 8, bottom: isLast ? 10 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nome da cidade + horário
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          parada.parada,
                          style: AppTextStyles.bodyBold(
                            fontSize: 15,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (parada.horario.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isFirst
                                ? AppColors.primaryLight
                                : (isLast ? AppColors.secondaryLight : AppColors.background),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isFirst
                                  ? AppColors.primary.withValues(alpha: 0.3)
                                  : (isLast ? AppColors.secondary.withValues(alpha: 0.3) : AppColors.border),
                            ),
                          ),
                          child: Text(
                            isFirst || isLast ? parada.horario : '~ ${parada.horario}',
                            style: AppTextStyles.bodyBold(
                              fontSize: 12,
                              color: isFirst
                                  ? AppColors.primary
                                  : (isLast ? AppColors.secondary : AppColors.textSecondary),
                            ),
                          ),
                        ),
                    ],
                  ),

                  // Descrição / ponto de referência
                  if (parada.descricao != null && parada.descricao!.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      parada.descricao!,
                      style: AppTextStyles.bodyRegular(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],

                  // Tags / observações
                  if (parada.tags.isNotEmpty || parada.observacao != null) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        ...parada.tags.map(
                          (t) {
                            final lower = t.toLowerCase();
                            final isChegadaTag = isLast || lower.contains('chegada') || lower.contains('desembarque');
                            final isPartidaTag = isFirst || lower.contains('partida') || lower.contains('embarque');

                            final Color tagBg;
                            final Color tagBorder;
                            final Color tagTextColor;

                            if (isChegadaTag) {
                              tagBg = AppColors.secondaryLight;
                              tagBorder = AppColors.secondary.withValues(alpha: 0.25);
                              tagTextColor = AppColors.secondary;
                            } else if (isPartidaTag) {
                              tagBg = AppColors.primaryLight;
                              tagBorder = AppColors.primary.withValues(alpha: 0.25);
                              tagTextColor = AppColors.primary;
                            } else {
                              tagBg = AppColors.surface;
                              tagBorder = AppColors.border;
                              tagTextColor = AppColors.textSecondary;
                            }

                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: tagBg,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: tagBorder),
                              ),
                              child: Text(
                                t,
                                style: AppTextStyles.bodyMedium(
                                  fontSize: 10,
                                  color: tagTextColor,
                                ),
                              ),
                            );
                          },
                        ),
                        if (parada.observacao != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.inputBackground,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              parada.observacao!,
                              style: AppTextStyles.bodyMedium(
                                fontSize: 10,
                                color: isLast ? AppColors.secondary : AppColors.primary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 6. Card de Recomendação Passaí
// ---------------------------------------------------------------------------
class _RecomendacaoCard extends StatelessWidget {
  const _RecomendacaoCard({required this.detalhes});

  final DetalhesViagem detalhes;

  @override
  Widget build(BuildContext context) {
    final origemNome = detalhes.origem ??
        (detalhes.itinerario.isNotEmpty ? detalhes.itinerario.first.parada : 'na origem');

    final avisoMensagem = detalhes.aviso ??
        'Chegue com 10 a 15 minutos de antecedência no ponto de partida em $origemNome para garantir seu lugar no veículo. O embarque é realizado por ordem de chegada.';

    return Material(
      color: AppColors.primaryLight,
      borderRadius: BorderRadius.circular(AppRadii.card),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
          collapsedIconColor: AppColors.primary,
          iconColor: AppColors.primary,
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.lightbulb_outline_rounded, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Recomendação Passaí',
                  style: AppTextStyles.bodyBold(
                    fontSize: 13,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),
          children: [
            Text(
              avisoMensagem,
              style: AppTextStyles.bodyRegular(
                fontSize: 12,
                color: AppColors.textPrimary,
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
// 7. Ações no Rodapé
// ---------------------------------------------------------------------------
class _AcoesFooter extends StatelessWidget {
  const _AcoesFooter({required this.detalhes, this.args});

  final DetalhesViagem detalhes;
  final DetalhesViagemArgs? args;

  @override
  Widget build(BuildContext context) {
    final origemVolta = detalhes.destino ??
        (detalhes.itinerario.isNotEmpty ? detalhes.itinerario.last.parada : '');
    final destinoVolta = detalhes.origem ??
        (detalhes.itinerario.isNotEmpty ? detalhes.itinerario.first.parada : '');

    return Column(
      children: [
        // Botão primário — Compartilhar
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () => _DetalhesAppBar._compartilharViagem(context, detalhes),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.button),
              ),
            ),
            icon: const Icon(Icons.share_rounded, size: 18),
            label: Text(
              'Compartilhar Detalhes da Viagem',
              style: AppTextStyles.bodyBold(fontSize: 14, color: Colors.white),
            ),
          ),
        ),
        if (origemVolta.isNotEmpty && destinoVolta.isNotEmpty) ...[
          const SizedBox(height: 10),
          // Botão secundário — Ver horários de volta (funcional)
          SizedBox(
            width: double.infinity,
            height: 46,
            child: OutlinedButton.icon(
              onPressed: () {
                final sentidoInverso = args?.sentido == 'IDA' ? 'volta' : 'ida';
                context.push(
                  '${AppRoutes.resultados}?origem=${Uri.encodeComponent(origemVolta)}&destino=${Uri.encodeComponent(destinoVolta)}&sentido=$sentidoInverso',
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.button),
                ),
              ),
              icon: const Icon(Icons.swap_horiz_rounded, size: 16),
              label: Text(
                'Ver Horários de Volta ($origemVolta ➔ $destinoVolta)',
                style: AppTextStyles.bodySemibold(fontSize: 13, color: AppColors.primary),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
        const SizedBox(height: 10),

        // Botão terciário — Voltar
        SizedBox(
          width: double.infinity,
          height: 46,
          child: TextButton.icon(
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.home);
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.button),
              ),
            ),
            icon: const Icon(Icons.arrow_back_rounded, size: 16),
            label: Text(
              'Voltar para Resultados',
              style: AppTextStyles.bodySemibold(fontSize: 13, color: AppColors.textPrimary),
            ),
          ),
        ),
      ],
    );
  }
}
