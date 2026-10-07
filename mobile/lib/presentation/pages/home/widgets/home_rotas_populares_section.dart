import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:passai/core/constants/app_constants.dart';
import 'package:passai/core/constants/popular_routes.dart';
import 'package:passai/core/theme/app_colors.dart';
import 'package:passai/core/theme/app_text_styles.dart';
import 'package:passai/core/utils/duracao_estimativa.dart';
import 'package:passai/core/utils/itinerario_helper.dart';
import 'package:passai/domain/entities/detalhes_viagem.dart';
import 'package:passai/domain/entities/horario.dart';
import 'package:passai/domain/entities/rota.dart';
import 'package:passai/presentation/pages/detalhes_viagem/detalhes_viagem_page.dart';
import 'package:passai/presentation/pages/resultados/resultados_page.dart';
import 'package:passai/presentation/providers/rotas_provider.dart';
import 'package:passai/presentation/widgets/popular_route_card.dart';

/// Seção de rotas populares em destaque na HomePage
class HomeRotasPopularesSection extends ConsumerWidget {
  const HomeRotasPopularesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todasRotas = ref.watch(todasAsRotasProvider).valueOrNull ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Rotas Populares',
              style: AppTextStyles.headingMD(color: AppColors.textPrimary),
            ),
            Text(
              '${rotasPopularesDestaque.length} principais',
              style: AppTextStyles.bodyMedium(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Column(
          children: [
            for (int index = 0; index < rotasPopularesDestaque.length; index++) ...[
              if (index > 0) const SizedBox(height: 10),
              () {
                final config = rotasPopularesDestaque[index];

                // Procura a rota no banco de dados tanto na ida quanto na volta
                Rota rota;
                Sentido sentido;

                final rotaDireta = todasRotas.where((r) {
                  return r.origem.toLowerCase().contains(config.origem.toLowerCase()) &&
                      r.destino.toLowerCase().contains(config.destino.toLowerCase());
                }).firstOrNull;

                if (rotaDireta != null) {
                  rota = rotaDireta;
                  sentido = Sentido.ida;
                } else {
                  final rotaReversa = todasRotas.where((r) {
                    return r.origem.toLowerCase().contains(config.destino.toLowerCase()) &&
                        r.destino.toLowerCase().contains(config.origem.toLowerCase());
                  }).firstOrNull;

                  if (rotaReversa != null) {
                    rota = rotaReversa;
                    sentido = Sentido.volta;
                  } else {
                    rota = Rota(
                      id: config.fallbackId,
                      linha: '${config.origem} - ${config.destino}',
                      origem: config.origem,
                      destino: config.destino,
                      diasOperacao: 'Diariamente',
                      tarifa: config.precoPadrao,
                    );
                    sentido = Sentido.ida;
                  }
                }

                final tarifa = rota.tarifa ?? config.precoPadrao;
                final precoStr = 'R\$ ${tarifa.toStringAsFixed(2).replaceAll('.', ',')}';

                return PopularRouteCard(
                  key: ValueKey('${config.origem}-${config.destino}'),
                  route: PopularRoute(
                    from: config.origem,
                    to: config.destino,
                    via: config.via,
                    nextTime: config.horarioSaida,
                    price: precoStr,
                    subtitle: config.descricao,
                  ),
                  onTap: () => context.push(
                    '${AppRoutes.resultados}?origem=${Uri.encodeComponent(config.origem)}&destino=${Uri.encodeComponent(config.destino)}&sentido=${sentido.name}',
                    extra: ResultadosArgs(
                      rota: rota,
                      sentido: sentido,
                    ),
                  ),
                  onVerDetalhes: () => _navegarParaDetalhes(
                    context: context,
                    config: config,
                    rota: rota,
                    sentido: sentido,
                    precoStr: precoStr,
                  ),
                );
              }(),
            ],
          ],
        ),
      ],
    );
  }

  void _navegarParaDetalhes({
    required BuildContext context,
    required PopularRouteConfig config,
    required Rota rota,
    required Sentido sentido,
    required String precoStr,
  }) {
    final itinerarioFallback = ItinerarioHelper.criarItinerarioFallback(
      origem: config.origem,
      destino: config.destino,
      horarioSaida: config.horarioSaida,
      rotaId: rota.id,
      seccionamentos: rota.seccionamentos,
      paradasIntermediarias: config.paradasIntermediarias,
    );

    final duracaoStr = rota.distanciaKm != null
        ? DuracaoEstimativa.estimar(rota.distanciaKm) ?? '1h 45min'
        : '1h 45min';
    final distanciaStr = rota.distanciaKm != null
        ? '${rota.distanciaKm} km'
        : '85 km';

    final detalhes = DetalhesViagem(
      codigo: rota.linha,
      preco: precoStr,
      rota: '${config.origem} x ${config.destino}',
      origem: config.origem,
      destino: config.destino,
      itinerario: itinerarioFallback,
      horaSaida: config.horarioSaida,
      duracao: duracaoStr,
      distancia: distanciaStr,
      tipoLinha: 'Transporte Intermunicipal',
      diasOperacao: rota.diasOperacao,
      seccionamentos: rota.seccionamentos,
      via: config.via != null
          ? (config.via!.toLowerCase().startsWith('via')
              ? config.via!
              : 'Via ${config.via!}')
          : null,
    );

    context.push(
      '${AppRoutes.detalhesViagem}?rotaId=${rota.id}&sentido=${sentido == Sentido.ida ? 'IDA' : 'VOLTA'}',
      extra: DetalhesViagemArgs(
        detalhes: detalhes,
        rotaId: rota.id,
        sentido: sentido == Sentido.ida ? 'IDA' : 'VOLTA',
      ),
    );
  }
}
