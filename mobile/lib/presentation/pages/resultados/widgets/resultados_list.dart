import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:passai/core/constants/app_constants.dart';
import 'package:passai/core/theme/app_colors.dart';
import 'package:passai/core/theme/app_text_styles.dart';
import 'package:passai/core/utils/duracao_estimativa.dart';
import 'package:passai/core/utils/itinerario_helper.dart';
import 'package:passai/domain/entities/detalhes_viagem.dart';
import 'package:passai/domain/entities/horario.dart';
import 'package:passai/domain/entities/rota.dart';
import 'package:passai/presentation/pages/detalhes_viagem/detalhes_viagem_page.dart';
import 'package:passai/presentation/widgets/resultado_card.dart';
import 'resultados_states.dart';

/// Lista de horários encontrados na tela de resultados
class ResultadosList extends StatelessWidget {
  const ResultadosList({
    super.key,
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
                    ResultadosAlteracaoBanner(quantidade: numAlterados),
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
                  onVerDetalhes: () => _navegarParaDetalhes(
                    context: context,
                    horario: horario,
                  ),
                ),
              ),
            );
          },
          childCount: horarios.length + 1,
        ),
      ),
    );
  }

  void _navegarParaDetalhes({
    required BuildContext context,
    required Horario horario,
  }) {
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

    final duracaoStr = DuracaoEstimativa.padronizar(horario.duracao) ??
        (rota.distanciaKm != null
            ? DuracaoEstimativa.estimar(rota.distanciaKm) ?? 'A consultar'
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
      veiculoNumero:
          horario.alteracao?.vanSubstituta ?? horario.alteracao?.vanOriginal,
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
  }
}
