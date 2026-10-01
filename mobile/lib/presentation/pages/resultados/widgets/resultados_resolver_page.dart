import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:passai/core/theme/app_colors.dart';
import 'package:passai/domain/entities/horario.dart';
import 'package:passai/domain/entities/rota.dart';
import 'package:passai/domain/usecases/buscar_rotas.dart';
import 'package:passai/presentation/pages/resultados/resultados_page.dart';
import 'package:passai/presentation/providers/rotas_provider.dart';
import 'package:passai/presentation/widgets/empty_state_scaffold.dart';

/// Resolve a busca ao recarregar a página (F5) ou acessar via link compartilhado (Deep Link)
class ResultadosResolverPage extends ConsumerWidget {
  const ResultadosResolverPage({
    super.key,
    this.origem,
    this.destino,
    this.rotaId,
    this.sentidoStr,
  });

  final String? origem;
  final String? destino;
  final int? rotaId;
  final String? sentidoStr;

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
      error: (err, _) => Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.wifi_off_rounded, size: 48, color: AppColors.primary),
                const SizedBox(height: 16),
                const Text(
                  'Não foi possível carregar os horários.',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                  onPressed: () => ref.invalidate(todasAsRotasProvider),
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (rotas) {
        Rota? rotaEncontrada;
        Sentido sentido = sentidoStr?.toLowerCase() == 'volta'
            ? Sentido.volta
            : Sentido.ida;

        if (rotaId != null) {
          rotaEncontrada = rotas.where((r) => r.id == rotaId).firstOrNull;
        }

        if (rotaEncontrada == null && origem != null && destino != null) {
          final oNorm = BuscarRotas.normalizar(origem!);
          final dNorm = BuscarRotas.normalizar(destino!);

          rotaEncontrada = rotas.where((r) {
            return BuscarRotas.normalizar(r.origem) == oNorm &&
                BuscarRotas.normalizar(r.destino) == dNorm;
          }).firstOrNull;

          if (rotaEncontrada != null) {
            sentido = Sentido.ida;
          } else {
            rotaEncontrada = rotas.where((r) {
              return BuscarRotas.normalizar(r.origem) == dNorm &&
                  BuscarRotas.normalizar(r.destino) == oNorm;
            }).firstOrNull;
            if (rotaEncontrada != null) {
              sentido = Sentido.volta;
            }
          }
        }

        if (rotaEncontrada != null) {
          return ResultadosPage(
            args: ResultadosArgs(rota: rotaEncontrada, sentido: sentido),
          );
        }

        return EmptyStateScaffold(
          icon: Icons.directions_bus_outlined,
          title: 'Rota não encontrada',
          subtitle:
              'Não encontramos vans cadastradas entre ${origem ?? "origem"} e ${destino ?? "destino"}.',
        );
      },
    );
  }
}
