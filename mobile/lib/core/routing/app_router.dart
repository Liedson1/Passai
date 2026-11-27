import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:passai/core/constants/app_constants.dart';
import 'package:passai/domain/entities/rota.dart';
import 'package:passai/presentation/pages/detalhes_viagem/detalhes_viagem_page.dart';
import 'package:passai/presentation/pages/detalhes_viagem/widgets/detalhes_viagem_resolver_page.dart';
import 'package:passai/presentation/pages/home/home_page.dart';
import 'package:passai/presentation/pages/horarios/horarios_page.dart';
import 'package:passai/presentation/pages/resultados/resultados_page.dart';
import 'package:passai/presentation/pages/resultados/widgets/resultados_resolver_page.dart';
import 'package:passai/presentation/widgets/empty_state_scaffold.dart';

/// Configuração centralizada do GoRouter do Passaí com suporte a Web Deep Linking e recarregamento F5
final appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: AppRoutes.horarios,
      builder: (context, state) {
        final extra = state.extra;
        if (extra is HorariosArgs) {
          return HorariosPage(
            rota: extra.rota,
            initialSentido: extra.initialSentido,
          );
        } else if (extra is Rota) {
          return HorariosPage(rota: extra);
        }
        return const EmptyStateScaffold(
          icon: Icons.alt_route_rounded,
          title: 'Selecione uma rota para consultar',
          subtitle: 'Inicie sua consulta selecionando a origem e destino.',
        );
      },
    ),
    GoRoute(
      path: AppRoutes.resultados,
      builder: (context, state) {
        final extra = state.extra;
        if (extra is ResultadosArgs) {
          return ResultadosPage(args: extra);
        }

        // Suporte a Deep Linking e F5 na Web via query parameters
        final origem = state.uri.queryParameters['origem'];
        final destino = state.uri.queryParameters['destino'];
        final rotaIdStr = state.uri.queryParameters['rotaId'];
        final sentidoStr = state.uri.queryParameters['sentido'];

        if ((origem != null && destino != null) || rotaIdStr != null) {
          return ResultadosResolverPage(
            origem: origem,
            destino: destino,
            rotaId: int.tryParse(rotaIdStr ?? ''),
            sentidoStr: sentidoStr,
          );
        }

        return const EmptyStateScaffold(
          icon: Icons.search_off_rounded,
          title: 'Nenhuma busca ativa',
          subtitle:
              'Selecione a origem e o destino na página inicial para consultar os horários.',
        );
      },
    ),
    GoRoute(
      path: AppRoutes.detalhesViagem,
      builder: (context, state) {
        final extra = state.extra;
        if (extra is DetalhesViagemArgs) {
          return DetalhesViagemPage(args: extra);
        }

        // Suporte a recarregamento F5 na Web
        final rotaIdStr = state.uri.queryParameters['rotaId'];
        final sentidoStr = state.uri.queryParameters['sentido'];
        final hora = state.uri.queryParameters['hora'];

        if (rotaIdStr != null) {
          final rotaId = int.tryParse(rotaIdStr);
          if (rotaId != null) {
            return DetalhesViagemResolverPage(
              rotaId: rotaId,
              sentidoStr: sentidoStr ?? 'IDA',
              hora: hora,
            );
          }
        }

        return const EmptyStateScaffold(
          icon: Icons.route_rounded,
          title: 'Viagem não encontrada',
          subtitle: 'Selecione uma viagem a partir da tela de resultados.',
        );
      },
    ),
  ],
);
