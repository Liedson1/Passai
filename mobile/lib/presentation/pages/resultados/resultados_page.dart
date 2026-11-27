import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:passai/core/constants/app_constants.dart';
import 'package:passai/core/theme/app_colors.dart';
import 'package:passai/domain/entities/horario.dart';
import 'package:passai/domain/entities/rota.dart';
import 'package:passai/presentation/providers/resultados_provider.dart';
import 'package:passai/presentation/widgets/date_selector.dart';
import 'package:passai/presentation/widgets/period_filter.dart';
import 'package:passai/presentation/widgets/responsive_shell.dart';
import 'widgets/resultados_app_bar.dart';
import 'widgets/resultados_desktop_view.dart';
import 'widgets/resultados_list.dart';
import 'widgets/resultados_states.dart';

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
                ResultadosAppBar(
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
                        ref.read(filtroPeriodoProvider.notifier).state =
                            novoFiltro;
                      },
                    ),
                  ),
                ),

                // Lista de resultados
                horariosAsync.when(
                  loading: () => const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primary),
                    ),
                  ),
                  error: (err, _) => SliverFillRemaining(
                    child: ResultadosErrorState(
                      message: err.toString(),
                      onRetry: () =>
                          ref.invalidate(resultadosHorariosProvider(params)),
                    ),
                  ),
                  data: (horarios) {
                    final filtrados =
                        FiltroPeriodoUtils.filtrar(horarios, filtro);

                    if (filtrados.isEmpty) {
                      return SliverFillRemaining(
                        child: ResultadosEmptyState(
                          isFiltroAtivo: filtro != FiltroPeriodo.todos,
                        ),
                      );
                    }

                    return ResultadosList(
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
