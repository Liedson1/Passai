import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:passai/core/constants/app_constants.dart';
import 'package:passai/core/theme/app_colors.dart';
import 'package:passai/domain/entities/horario.dart';
import 'package:passai/domain/entities/detalhes_viagem.dart';
import 'package:passai/domain/entities/parada_itinerario.dart';
import 'package:passai/presentation/pages/detalhes_viagem/detalhes_viagem_page.dart';
import 'package:passai/presentation/pages/resultados/resultados_page.dart';
import 'package:passai/presentation/providers/resultados_provider.dart';
import 'package:passai/presentation/widgets/web/web_footer.dart';
import 'package:passai/presentation/widgets/web/web_navbar.dart';

/// Visualização Web Desktop para a página de Resultados de Viagem (fiel ao mockup)
class ResultadosDesktopView extends ConsumerWidget {
  const ResultadosDesktopView({super.key, required this.args});

  final ResultadosArgs args;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataSelecionada = ref.watch(dataSelecionadaProvider);
    final filtro = ref.watch(filtroPeriodoProvider);
    final dias = gerarDiasSeletor(dataSelecionada);

    final params = ResultadosParams(
      rotaId: args.rota.id,
      sentido: args.sentido,
      data: dataSelecionada,
    );
    final horariosAsync = ref.watch(resultadosHorariosProvider(params));

    final rota = args.rota;
    final sentido = args.sentido;
    final origemExibida = sentido == Sentido.ida ? rota.origem : rota.destino;
    final destinoExibido = sentido == Sentido.ida ? rota.destino : rota.origem;

    final precoPadraoStr = rota.tarifa != null
        ? 'R\$ ${rota.tarifa!.toStringAsFixed(2).replaceAll('.', ',')}'
        : 'R\$ 15,00';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: [
            // 1. Barra de Navegação Superior
            const RepaintBoundary(child: WebNavbar()),

            // 2. Sub-header com Botão Voltar e Título da Rota
            Container(
              width: double.infinity,
              color: AppColors.background,
              padding: const EdgeInsets.only(top: 32, bottom: 20, left: 24, right: 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1040),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Linha com "Voltar para a busca" e título da seção
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () => context.go(AppRoutes.home),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.arrow_back_rounded,
                                      color: AppColors.textPrimary,
                                      size: 18,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Voltar para a busca',
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
                            const Text(
                              'Resultados de Viagem',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Nome da Rota em Destaque
                        Row(
                          children: [
                            Text(
                              origemExibida,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Icon(
                                Icons.arrow_forward_rounded,
                                color: AppColors.primary,
                                size: 22,
                              ),
                            ),
                            Text(
                              destinoExibido,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            if (args.rota.via != null) ...[
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppColors.primary.withValues(alpha: 0.25),
                                  ),
                                ),
                                child: Text(
                                  args.rota.via!,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 3. Conteúdo Principal em 2 Colunas (Sidebar à esquerda, Lista à direita)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1040),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sidebar Esquerda: Seletor do Dia e Filtros
                      SizedBox(
                        width: 280,
                        child: Column(
                          children: [
                            // Card "Selecione o Dia"
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Selecione o Dia',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  ...dias.map((diaItem) {
                                    final mesNome = DateFormat("MMMM", "pt_BR")
                                        .format(diaItem.data);
                                    final label =
                                        '${diaItem.diaSemana}  ${diaItem.dia} de $mesNome';
                                    final isSelected = diaItem.selecionado;

                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: GestureDetector(
                                          onTap: () {
                                            ref
                                                .read(dataSelecionadaProvider.notifier)
                                                .state = diaItem.data;
                                          },
                                          child: AnimatedContainer(
                                            duration: const Duration(milliseconds: 150),
                                            width: double.infinity,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 14,
                                              vertical: 11,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? AppColors.primary
                                                  : const Color(0xFFF5F0E8),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              label,
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: isSelected
                                                    ? FontWeight.bold
                                                    : FontWeight.w500,
                                                color: isSelected
                                                    ? Colors.white
                                                    : AppColors.textPrimary,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Card "Filtros"
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Filtros',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _DesktopFilterButton(
                                    label: 'Todos os horários',
                                    icon: Icons.filter_list_rounded,
                                    isSelected: filtro == FiltroPeriodo.todos,
                                    onTap: () => ref
                                        .read(filtroPeriodoProvider.notifier)
                                        .state = FiltroPeriodo.todos,
                                  ),
                                  const SizedBox(height: 6),
                                  _DesktopFilterButton(
                                    label: 'Manhã (05h - 12h)',
                                    icon: Icons.wb_sunny_outlined,
                                    isSelected: filtro == FiltroPeriodo.manha,
                                    onTap: () => ref
                                        .read(filtroPeriodoProvider.notifier)
                                        .state = FiltroPeriodo.manha,
                                  ),
                                  const SizedBox(height: 6),
                                  _DesktopFilterButton(
                                    label: 'Tarde (12h - 18h)',
                                    icon: Icons.wb_twilight,
                                    isSelected: filtro == FiltroPeriodo.tarde,
                                    onTap: () => ref
                                        .read(filtroPeriodoProvider.notifier)
                                        .state = FiltroPeriodo.tarde,
                                  ),
                                  const SizedBox(height: 6),
                                  _DesktopFilterButton(
                                    label: 'Noite (18h - 23h)',
                                    icon: Icons.nightlight_outlined,
                                    isSelected: filtro == FiltroPeriodo.noite,
                                    onTap: () => ref
                                        .read(filtroPeriodoProvider.notifier)
                                        .state = FiltroPeriodo.noite,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 24),

                      // Coluna Direita: Lista de Viagens / Horários
                      Expanded(
                        child: horariosAsync.when(
                          loading: () => const Center(
                            child: Padding(
                              padding: EdgeInsets.all(48.0),
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          error: (err, _) => Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.wifi_off_rounded,
                                  color: AppColors.primary,
                                  size: 40,
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Não foi possível carregar os horários.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                FilledButton(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                  ),
                                  onPressed: () => ref.invalidate(
                                    resultadosHorariosProvider(params),
                                  ),
                                  child: const Text('Tentar novamente'),
                                ),
                              ],
                            ),
                          ),
                          data: (horarios) {
                            final filtrados = FiltroPeriodoUtils.filtrar(horarios, filtro);

                            if (filtrados.isEmpty) {
                              return Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(48),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: const Column(
                                  children: [
                                    Icon(
                                      Icons.directions_bus_outlined,
                                      size: 48,
                                      color: AppColors.textSecondary,
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'Nenhuma van para os filtros selecionados.',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Tente selecionar outro dia ou remover os filtros de período.',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            return Column(
                              children: filtrados.map((horario) {
                                return Padding(
                                  key: ValueKey(horario.id),
                                  padding: const EdgeInsets.only(bottom: 14),
                                  child: RepaintBoundary(
                                    child: _DesktopViagemCard(
                                      horario: horario,
                                      origem: origemExibida,
                                      destino: destinoExibido,
                                      precoStr: precoPadraoStr,
                                      rotaId: rota.id,
                                      sentido: sentido == Sentido.ida ? 'IDA' : 'VOLTA',
                                    ),
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 64),

            // 4. Rodapé Escuro Institucional
            const RepaintBoundary(child: WebFooter()),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Card de Viagem Desktop com Horário, Preço, Paradas e Ação
// ---------------------------------------------------------------------------
class _DesktopViagemCard extends StatelessWidget {
  const _DesktopViagemCard({
    required this.horario,
    required this.origem,
    required this.destino,
    required this.precoStr,
    required this.rotaId,
    required this.sentido,
  });

  final Horario horario;
  final String origem;
  final String destino;
  final String precoStr;
  final int rotaId;
  final String sentido;

  @override
  Widget build(BuildContext context) {
    final bool alterado = horario.alterado;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: alterado ? AppColors.warning : AppColors.border,
          width: alterado ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Linha Superior: Horário + Preço
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.access_time_filled,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    horario.hora,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (alterado) ...[
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warningLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Horário alterado (era ${horario.alteracao?.horaOriginal ?? '—'})',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              Text(
                horario.preco != null
                    ? 'R\$ ${horario.preco!.toStringAsFixed(2).replaceAll('.', ',')}'
                    : precoStr,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Nome do Trecho
          Text(
            horario.nomeRota ?? '$origem x $destino',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 12),

          // Informações de Duração e Paradas + Botão Ver Rota
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.timelapse_rounded,
                    size: 15,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    horario.duracao ?? '45 min',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    horario.paradas ?? 'Direto',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),

              // Botão Ver no Mapa / Detalhes
              OutlinedButton.icon(
                onPressed: () {
                  final precoFormatado = horario.preco != null
                      ? 'R\$ ${horario.preco!.toStringAsFixed(2).replaceAll('.', ',')}'
                      : precoStr;

                  // Itinerário estático mínimo (partida + chegada)
                  // A tela de detalhes buscará as paradas reais do Supabase
                  // usando rotaId e sentido
                  final itinerarioFallback = [
                    ParadaItinerario(
                      parada: origem,
                      horario: horario.hora,
                      descricao: 'Partida',
                    ),
                    ParadaItinerario(
                      parada: destino,
                      horario: '',
                      descricao: 'Chegada',
                    ),
                  ];

                  final duracaoStr = horario.duracao ?? '1h 45m';
                  const distanciaStr = '85 km';

                  final detalhes = DetalhesViagem(
                    codigo: horario.nomeRota ?? '$origem x $destino',
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
                    alterado: horario.alterado,
                    alteracaoMotivo: horario.alteracao?.motivo,
                  );

                  context.push(
                    AppRoutes.detalhesViagem,
                    extra: DetalhesViagemArgs(
                      detalhes: detalhes,
                      rotaId: rotaId,
                      sentido: sentido,
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.alt_route_rounded, size: 14),
                label: const Text(
                  'Ver Itinerário',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
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
// Botão de Filtro de Período Desktop
// ---------------------------------------------------------------------------
class _DesktopFilterButton extends StatelessWidget {
  const _DesktopFilterButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : const Color(0xFFF9F6F0),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.textPrimary,
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
