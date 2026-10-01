import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:passai/core/theme/app_colors.dart';
import 'package:passai/core/theme/app_text_styles.dart';
import 'package:passai/core/constants/app_constants.dart';
import 'package:passai/core/utils/itinerario_helper.dart';
import 'package:passai/domain/entities/detalhes_viagem.dart';
import 'package:passai/domain/entities/horario.dart';
import 'package:passai/domain/entities/rota.dart';
import 'package:passai/presentation/pages/detalhes_viagem/detalhes_viagem_page.dart';
import 'package:passai/presentation/providers/resultados_provider.dart';
import 'package:passai/presentation/widgets/date_selector.dart';
import 'package:passai/presentation/widgets/period_filter.dart';
import 'package:passai/presentation/widgets/responsive_shell.dart';
import 'package:passai/presentation/widgets/resultado_card.dart';
import 'widgets/resultados_desktop_view.dart';

/// Argumentos de navegação para a tela de resultados
class ResultadosArgs {
  const ResultadosArgs({
    required this.rota,
    required this.sentido,
  });

  final Rota rota;
  final Sentido sentido;
}

/// Tela de resultados de horários — segunda tela principal do Passaí.
/// Exibe horários filtrados por data e período, com cards ricos contendo
/// preço, duração, paradas e indicação visual de alterações.
class ResultadosPage extends ConsumerStatefulWidget {
  const ResultadosPage({super.key, required this.args});

  final ResultadosArgs args;

  @override
  ConsumerState<ResultadosPage> createState() => _ResultadosPageState();
}

class _ResultadosPageState extends ConsumerState<ResultadosPage> {
  late Sentido _sentidoAtual;

  @override
  void initState() {
    super.initState();
    _sentidoAtual = widget.args.sentido;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dataSelecionadaProvider.notifier).state = DateTime.now();
      ref.read(filtroPeriodoProvider.notifier).state = FiltroPeriodo.todos;
    });
  }

  @override
  void didUpdateWidget(ResultadosPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.args.sentido != oldWidget.args.sentido) {
      _sentidoAtual = widget.args.sentido;
    }
  }

  void _inverterSentido() {
    HapticFeedback.lightImpact();
    setState(() {
      _sentidoAtual =
          _sentidoAtual == Sentido.ida ? Sentido.volta : Sentido.ida;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;
    if (isDesktop) {
      return ResultadosDesktopView(
        args: widget.args,
        sentidoAtual: _sentidoAtual,
        onInverterSentido: _inverterSentido,
      );
    }

    final dataSelecionada = ref.watch(dataSelecionadaProvider);
    final filtro = ref.watch(filtroPeriodoProvider);
    final dias = gerarDiasSeletor(dataSelecionada);

    final params = ResultadosParams(
      rotaId: widget.args.rota.id,
      sentido: _sentidoAtual,
      data: dataSelecionada,
    );
    final horariosAsync = ref.watch(resultadosHorariosProvider(params));

    final rota = widget.args.rota;
    final sentido = _sentidoAtual;
    final origemExibida = sentido == Sentido.ida ? rota.origem : rota.destino;
    final destinoExibido = sentido == Sentido.ida ? rota.destino : rota.origem;

    return ResponsiveShell(
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) {
            context.go(AppRoutes.home);
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            HapticFeedback.lightImpact();
            ref.invalidate(resultadosHorariosProvider(params));
            try {
              await ref.read(resultadosHorariosProvider(params).future);
            } catch (_) {}
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // AppBar com info da rota
              _ResultadosAppBar(
                origem: origemExibida,
                destino: destinoExibido,
                linha: rota.linha,
                via: rota.via,
                onInverterSentido: _inverterSentido,
              ),

              // Seletor de data
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 12),
                  child: DateSelector(
                    dias: dias,
                    onDateSelected: (data) {
                      ref.read(dataSelecionadaProvider.notifier).state = data;
                    },
                  ),
                ),
              ),

              // Filtros de período
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: PeriodFilter(
                    filtroAtivo: filtro,
                    onFilterChanged: (novoFiltro) {
                      ref.read(filtroPeriodoProvider.notifier).state = novoFiltro;
                    },
                  ),
                ),
              ),

              // Lista de resultados
              horariosAsync.when(
                loading: () => const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
                error: (err, _) => SliverFillRemaining(
                  child: _ErrorState(
                    message: err.toString(),
                    onRetry: () =>
                        ref.invalidate(resultadosHorariosProvider(params)),
                  ),
                ),
                data: (horarios) {
                  final filtrados = FiltroPeriodoUtils.filtrar(horarios, filtro);

                  if (filtrados.isEmpty) {
                    return SliverFillRemaining(
                      child: _EmptyState(
                        isFiltroAtivo: filtro != FiltroPeriodo.todos,
                      ),
                    );
                  }

                  return _ResultadosList(
                    horarios: filtrados,
                    rota: rota,
                    sentido: sentido,
                    origem: origemExibida,
                    destino: destinoExibido,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }
}

// ---------------------------------------------------------------------------
// AppBar customizada com info da rota
// ---------------------------------------------------------------------------
class _ResultadosAppBar extends StatelessWidget {
  const _ResultadosAppBar({
    required this.origem,
    required this.destino,
    required this.linha,
    this.via,
    this.onInverterSentido,
  });

  final String origem;
  final String destino;
  final String linha;
  final String? via;
  final VoidCallback? onInverterSentido;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: AppColors.primary,
      iconTheme: const IconThemeData(color: AppColors.textOnPrimary),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.textOnPrimary),
        tooltip: 'Voltar',
        onPressed: () => context.go(AppRoutes.home),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: AppColors.primary,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Origem ⇄ Destino com botão de swap
              Row(
                children: [
                  Flexible(
                    child: Text(
                      origem,
                      style: AppTextStyles.headingLG(
                        color: AppColors.textOnPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (onInverterSentido != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Tooltip(
                        message: 'Inverter para volta',
                        child: Material(
                          color: Colors.white.withValues(alpha: 0.20),
                          shape: const CircleBorder(),
                          child: InkWell(
                            onTap: onInverterSentido,
                            customBorder: const CircleBorder(),
                            child: const Padding(
                              padding: EdgeInsets.all(8),
                              child: Icon(
                                Icons.swap_horiz_rounded,
                                color: AppColors.titleGold,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(
                        Icons.arrow_forward,
                        color: AppColors.textOnPrimary,
                        size: 18,
                      ),
                    ),
                  Flexible(
                    child: Text(
                      destino,
                      style: AppTextStyles.headingLG(
                        color: AppColors.textOnPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Badge da rota: exibe apenas a via se existir para evitar duplicação
              if (via != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.titleGold.withValues(alpha: 0.25),
                    border: Border.all(
                      color: AppColors.titleGold.withValues(alpha: 0.6),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                  child: Text(
                    via!,
                    style: AppTextStyles.bodyBold(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.heroOverlay,
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                  child: Text(
                    'Linha $linha',
                    style: AppTextStyles.bodyBold(
                      fontSize: 12,
                      color: AppColors.textOnPrimary,
                    ),
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
// Lista de resultados
// ---------------------------------------------------------------------------
class _ResultadosList extends StatelessWidget {
  const _ResultadosList({
    required this.horarios,
    required this.rota,
    required this.sentido,
    required this.origem,
    required this.destino,
  });

  final List<Horario> horarios;
  final Rota rota;
  final Sentido sentido;
  final String origem;
  final String destino;

  @override
  Widget build(BuildContext context) {
    // Conta horários alterados para o banner informativo
    final numAlterados = horarios.where((h) => h.alterado).length;

    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 32 + bottomPadding),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == 0) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Contador de resultados
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      '${horarios.length} horário${horarios.length > 1 ? 's' : ''} encontrado${horarios.length > 1 ? 's' : ''}',
                      style: AppTextStyles.bodySemibold(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),

                  // Banner de aviso quando há alterações no dia (RN06)
                  if (numAlterados > 0) ...[
                    _AlteracaoBanner(quantidade: numAlterados),
                    const SizedBox(height: 12),
                  ],
                ],
              );
            }

            final horario = horarios[index - 1];
            return Padding(
              key: ValueKey(horario.id),
              padding: const EdgeInsets.only(bottom: 10),
              child: RepaintBoundary(
                child: ResultadoCard(
                  horario: horario,
                  onVerDetalhes: () {
                    final precoFormatado = horario.preco != null
                        ? 'R\$ ${horario.preco!.toStringAsFixed(2).replaceAll('.', ',')}'
                        : (rota.tarifa != null
                            ? 'R\$ ${rota.tarifa!.toStringAsFixed(2).replaceAll('.', ',')}'
                            : 'Consulte');

                    final itinerarioFallback = ItinerarioHelper.criarItinerarioFallback(
                      origem: origem,
                      destino: destino,
                      horarioSaida: horario.hora,
                      rotaId: rota.id,
                      seccionamentos: rota.seccionamentos,
                    );

                    final duracaoStr = horario.duracao ??
                        (rota.distanciaKm != null
                            ? '${(rota.distanciaKm! * 1.15).round()} min'
                            : 'A consultar');

                    final distanciaStr = rota.distanciaKm != null
                        ? '${rota.distanciaKm} km'
                        : 'A consultar';

                    final detalhes = DetalhesViagem(
                      codigo: horario.nomeRota ?? rota.linha,
                      preco: precoFormatado,
                      rota: '$origem x $destino',
                      origem: origem,
                      destino: destino,
                      itinerario: itinerarioFallback,
                      horaSaida: horario.hora,
                      duracao: duracaoStr,
                      distancia: distanciaStr,
                      tipoLinha: 'Transporte Intermunicipal',
                      veiculoNumero: horario.alteracao?.vanSubstituta ??
                          horario.alteracao?.vanOriginal,
                      vanOriginal: horario.alteracao?.vanOriginal,
                      vanSubstituta: horario.alteracao?.vanSubstituta,
                      via: rota.via,
                      diasOperacao: rota.diasOperacao,
                      seccionamentos: rota.seccionamentos,
                      alterado: horario.alterado,
                      alteracaoMotivo: horario.alteracao?.motivo,
                    );

                    final sentidoStr = sentido == Sentido.ida ? 'IDA' : 'VOLTA';
                    final horaEncoded = Uri.encodeComponent(horario.hora);
                    context.push(
                      '${AppRoutes.detalhesViagem}?rotaId=${rota.id}&sentido=$sentidoStr&hora=$horaEncoded',
                      extra: DetalhesViagemArgs(
                        detalhes: detalhes,
                        rotaId: rota.id,
                        sentido: sentidoStr,
                      ),
                    );
                  },
                ),
              ),
            );
          },
          childCount: horarios.length + 1,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Banner de alerta quando há alterações no dia (RN06)
// ---------------------------------------------------------------------------
class _AlteracaoBanner extends StatelessWidget {
  const _AlteracaoBanner({required this.quantidade});

  final int quantidade;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(AppRadii.input),
        border: Border.all(color: const Color(0x80FFD700)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFF856404),
            size: 20,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              '$quantidade horário${quantidade > 1 ? 's' : ''} '
              'foi alterado hoje. Os itens marcados indicam a mudança.',
              style: AppTextStyles.bodyRegular(
                fontSize: 13,
                color: const Color(0xFF856404),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Estado vazio
// ---------------------------------------------------------------------------
class _EmptyState extends StatelessWidget {
  const _EmptyState({this.isFiltroAtivo = false});

  final bool isFiltroAtivo;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.directions_bus_outlined,
            size: 60,
            color: AppColors.border,
          ),
          const SizedBox(height: 16),
          Text(
            isFiltroAtivo
                ? 'Nenhum horário neste período'
                : 'Nenhum horário disponível',
            style: AppTextStyles.headingMD(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            isFiltroAtivo
                ? 'Tente selecionar outro período ou outra data.'
                : 'Não há horários cadastrados para esta data.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyRegular(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Estado de erro
// ---------------------------------------------------------------------------
class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              size: 60,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar horários',
              style: AppTextStyles.headingMD(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              message.contains('Exception') ||
                      message.contains('Socket') ||
                      message.contains('Postgrest')
                  ? 'Não foi possível carregar os horários. Verifique sua conexão e tente novamente.'
                  : message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyRegular(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.button),
                  ),
                ),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Tentar novamente'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
