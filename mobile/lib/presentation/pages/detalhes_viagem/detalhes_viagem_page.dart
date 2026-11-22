import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:passai/core/constants/app_constants.dart';
import 'package:passai/core/theme/app_colors.dart';
import 'package:passai/core/utils/itinerario_helper.dart';
import 'package:passai/domain/entities/detalhes_viagem.dart';
import 'package:passai/presentation/pages/detalhes_viagem/widgets/acoes_footer.dart';
import 'package:passai/presentation/pages/detalhes_viagem/widgets/detalhes_app_bar.dart';
import 'package:passai/presentation/pages/detalhes_viagem/widgets/detalhes_viagem_desktop_view.dart';
import 'package:passai/presentation/pages/detalhes_viagem/widgets/recomendacao_card.dart';
import 'package:passai/presentation/pages/detalhes_viagem/widgets/route_summary_card.dart';
import 'package:passai/presentation/pages/detalhes_viagem/widgets/secao_itinerario.dart';
import 'package:passai/presentation/pages/detalhes_viagem/widgets/veiculo_card.dart';
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
  final int? rotaId;
  final String? sentido;

  bool get temDadosParaBusca => rotaId != null && sentido != null;
}

/// Tela de Detalhes da Viagem no padrão visual do Passaí
class DetalhesViagemPage extends ConsumerWidget {
  const DetalhesViagemPage({super.key, required this.args});

  final DetalhesViagemArgs args;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detalhes = args.detalhes;
    final paradasAsync = args.temDadosParaBusca
        ? ref.watch(paradasRotaProvider(
            ParadasParams(rotaId: args.rotaId!, sentido: args.sentido!),
          ))
        : null;

    final isDesktop = MediaQuery.of(context).size.width > 800;

    final contentItems = [
      RouteSummaryCard(detalhes: detalhes),
      const SizedBox(height: 12),
      VeiculoCard(detalhes: detalhes),
      const SizedBox(height: 20),
      _buildItinerarioSection(detalhes, paradasAsync),
      const SizedBox(height: 16),
      RecomendacaoCard(detalhes: detalhes),
      const SizedBox(height: 24),
      AcoesFooter(detalhes: detalhes, args: args),
    ];

    if (isDesktop) {
      return DetalhesViagemDesktopView(contentItems: contentItems);
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
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              DetalhesAppBar(detalhes: detalhes, args: args),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  20,
                  20,
                  40 + MediaQuery.of(context).padding.bottom,
                ),
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

  Widget _buildItinerarioSection(
    DetalhesViagem detalhes,
    AsyncValue<dynamic>? paradasAsync,
  ) {
    if (paradasAsync == null) {
      return SecaoItinerario(
        detalhes: detalhes,
        itinerario: ItinerarioHelper.enriquecerItinerario(
          paradas: detalhes.itinerario,
          horaSaida: detalhes.horaSaida,
          duracaoStr: detalhes.duracao,
          chegadaPrevista: detalhes.chegadaPrevista,
          origemFallback: detalhes.origem,
          destinoFallback: detalhes.destino,
        ),
      );
    }

    return paradasAsync.when(
      loading: () => SecaoItinerario(
        detalhes: detalhes,
        itinerario: detalhes.itinerario,
        isLoading: true,
      ),
      error: (_, __) => SecaoItinerario(
        detalhes: detalhes,
        itinerario: detalhes.itinerario,
      ),
      data: (paradas) {
        final listaBruta =
            paradas.isNotEmpty ? paradas : detalhes.itinerario;
        final itinerarioProcessado = ItinerarioHelper.enriquecerItinerario(
          paradas: listaBruta,
          horaSaida: detalhes.horaSaida,
          duracaoStr: detalhes.duracao,
          chegadaPrevista: detalhes.chegadaPrevista,
          origemFallback: detalhes.origem,
          destinoFallback: detalhes.destino,
        );
        return SecaoItinerario(
          detalhes: detalhes,
          itinerario: itinerarioProcessado,
        );
      },
    );
  }
}
