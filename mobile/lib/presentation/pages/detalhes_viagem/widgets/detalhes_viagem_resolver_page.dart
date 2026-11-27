import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:passai/core/theme/app_colors.dart';
import 'package:passai/core/utils/duracao_estimativa.dart';
import 'package:passai/core/utils/itinerario_helper.dart';
import 'package:passai/domain/entities/detalhes_viagem.dart';
import 'package:passai/presentation/pages/detalhes_viagem/detalhes_viagem_page.dart';
import 'package:passai/presentation/providers/rotas_provider.dart';
import 'package:passai/presentation/widgets/empty_state_scaffold.dart';

/// Resolve detalhes da viagem ao recarregar a página (F5) na Web ou via link direto
class DetalhesViagemResolverPage extends ConsumerWidget {
  const DetalhesViagemResolverPage({
    super.key,
    required this.rotaId,
    required this.sentidoStr,
    this.hora,
  });

  final int rotaId;
  final String sentidoStr;
  final String? hora;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rotasAsync = ref.watch(todasAsRotasProvider);

    return rotasAsync.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      error: (_, __) => const EmptyStateScaffold(
        icon: Icons.error_outline,
        title: 'Erro ao carregar viagem',
        subtitle: 'Verifique sua conexão e tente novamente.',
      ),
      data: (rotas) {
        final rota = rotas.where((r) => r.id == rotaId).firstOrNull;
        if (rota == null) {
          return const EmptyStateScaffold(
            icon: Icons.route_rounded,
            title: 'Viagem não encontrada',
            subtitle: 'A rota selecionada não está disponível.',
          );
        }

        final isIda = sentidoStr.toUpperCase() != 'VOLTA';
        final origem = isIda ? rota.origem : rota.destino;
        final destino = isIda ? rota.destino : rota.origem;
        final precoStr = rota.tarifa != null
            ? 'R\$ ${rota.tarifa!.toStringAsFixed(2).replaceAll('.', ',')}'
            : 'Consulte';

        final itinerarioFallback = ItinerarioHelper.criarItinerarioFallback(
          origem: origem,
          destino: destino,
          horarioSaida: hora,
          rotaId: rota.id,
          seccionamentos: rota.seccionamentos,
        );

        final duracaoStr = DuracaoEstimativa.estimar(rota.distanciaKm) ?? 'A consultar';
        final distanciaStr = rota.distanciaKm != null
            ? '${rota.distanciaKm} km'
            : 'A consultar';

        final detalhes = DetalhesViagem(
          codigo: rota.linha,
          preco: precoStr,
          rota: '$origem x $destino',
          origem: origem,
          destino: destino,
          itinerario: itinerarioFallback,
          horaSaida: hora,
          duracao: duracaoStr,
          distancia: distanciaStr,
          tipoLinha: 'Transporte Intermunicipal',
          diasOperacao: rota.diasOperacao,
          seccionamentos: rota.seccionamentos,
          via: rota.via,
        );

        return DetalhesViagemPage(
          args: DetalhesViagemArgs(
            detalhes: detalhes,
            rotaId: rota.id,
            sentido: isIda ? 'IDA' : 'VOLTA',
          ),
        );
      },
    );
  }
}
