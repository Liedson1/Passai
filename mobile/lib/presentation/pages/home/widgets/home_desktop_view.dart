import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:passai/core/constants/app_constants.dart';
import 'package:passai/core/constants/popular_routes.dart';
import 'package:passai/core/errors/exceptions.dart';
import 'package:passai/core/theme/app_colors.dart';
import 'package:passai/domain/entities/detalhes_viagem.dart';
import 'package:passai/domain/entities/horario.dart';
import 'package:passai/domain/entities/parada_itinerario.dart';
import 'package:passai/domain/entities/rota.dart';
import 'package:passai/presentation/pages/detalhes_viagem/detalhes_viagem_page.dart';
import 'package:passai/presentation/pages/resultados/resultados_page.dart';
import 'package:passai/presentation/providers/rotas_provider.dart';
import 'package:passai/presentation/widgets/web/web_footer.dart';
import 'package:passai/presentation/widgets/web/web_navbar.dart';
import 'why_passai_section.dart';

/// Visualização Web Desktop completa da Home (reprodução fiel ao mockup)
class HomeDesktopView extends ConsumerStatefulWidget {
  const HomeDesktopView({super.key});

  @override
  ConsumerState<HomeDesktopView> createState() => _HomeDesktopViewState();
}

class _HomeDesktopViewState extends ConsumerState<HomeDesktopView> {
  String? _errorMessage;
  IconData _errorIcon = Icons.info_outline;
  bool _isSearching = false;

  void _clearError() {
    if (_errorMessage != null) {
      setState(() => _errorMessage = null);
    }
  }

  Future<void> _executarBusca(
    BuildContext context,
    String origem,
    String destino,
  ) async {
    if (origem.trim().isEmpty || destino.trim().isEmpty) return;

    if (origem.trim().toLowerCase() == destino.trim().toLowerCase()) {
      setState(() {
        _errorMessage = 'A origem e o destino devem ser cidades diferentes.';
        _errorIcon = Icons.swap_horiz;
      });
      return;
    }

    _clearError();
    setState(() => _isSearching = true);

    try {
      final buscarUsecase = ref.read(buscarRotasUsecaseProvider);
      final resultados = await buscarUsecase.buscarComSentido(
        origem: origem.trim(),
        destino: destino.trim(),
      );

      if (!mounted || !context.mounted) return;

      if (resultados.isNotEmpty) {
        final match = resultados.first;
        context.push(
          '${AppRoutes.resultados}?origem=${Uri.encodeComponent(origem.trim())}&destino=${Uri.encodeComponent(destino.trim())}&sentido=${match.sentido.name}',
          extra: ResultadosArgs(
            rota: match.rota,
            sentido: match.sentido,
          ),
        );
      } else {
        setState(() {
          _errorMessage =
              'Nenhuma van direta cadastrada entre $origem e $destino.';
          _errorIcon = Icons.directions_bus_outlined;
        });
      }
    } catch (e) {
      if (!mounted) return;
      final msg = e is NetworkException
          ? e.message
          : 'Sem conexão com a internet. O Passaí precisa de conexão para buscar horários.';
      setState(() {
        _errorMessage = msg;
        _errorIcon = Icons.wifi_off_rounded;
      });
    } finally {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final origem = ref.watch(origemSelecionadaProvider);
    final destino = ref.watch(destinoSelecionadoProvider);
    final cidadesOrigem = ref.watch(cidadesConectadasProvider(destino));
    final cidadesDestino = ref.watch(cidadesConectadasProvider(origem));
    final todasRotas = ref.watch(todasAsRotasProvider).valueOrNull ?? [];

    final canSearch = origem != null &&
        origem.isNotEmpty &&
        destino != null &&
        destino.isNotEmpty &&
        !_isSearching;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Barra de Navegação Superior
            const RepaintBoundary(child: WebNavbar()),

            // 2. Hero Section com Título Duo-Tone e Barra de Busca
            RepaintBoundary(
              child: Container(
                width: double.infinity,
                color: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 980),
                  child: Column(
                    children: [
                      // Título principal Duo-Tone (Branco + Dourado Solar)
                      RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            height: 1.2,
                          ),
                          children: [
                            TextSpan(
                              text: 'Para onde você ',
                              style: TextStyle(color: Colors.white),
                            ),
                            TextSpan(
                              text: 'vai hoje?',
                              style: TextStyle(color: AppColors.titleGold),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 620),
                        child: Text(
                          'Consulte de forma rápida e prática os horários e tarifas das vans intermunicipais em Alagoas.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white.withValues(alpha: 0.9),
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 36),

                      // Card Branco Flutuante de Busca Unificada
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.10),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Banner de Erro Inline se houver
                            if (_errorMessage != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLight,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColors.primary.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(_errorIcon, color: AppColors.primary, size: 20),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          _errorMessage!,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.primaryDark,
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: _clearError,
                                        child: const Icon(
                                          Icons.close,
                                          color: AppColors.primary,
                                          size: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                            // Linha 1: Origem + Botão Swap + Destino
                            Row(
                              children: [
                                // Origem
                                Expanded(
                                  child: _DesktopInputPill(
                                    label: 'ORIGEM',
                                    placeholder: 'De onde você vai sair?',
                                    valorAtual: origem,
                                    icon: Icons.location_on,
                                    iconColor: AppColors.primary,
                                    cidades: cidadesOrigem,
                                    onSelecionada: (v) {
                                      _clearError();
                                      ref.read(origemSelecionadaProvider.notifier).state = v;
                                    },
                                    onLimpa: () {
                                      _clearError();
                                      ref.read(origemSelecionadaProvider.notifier).state = null;
                                    },
                                  ),
                                ),

                                // Botão Swap Central
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: GestureDetector(
                                      onTap: () {
                                        _clearError();
                                        final o = ref.read(origemSelecionadaProvider);
                                        final d = ref.read(destinoSelecionadoProvider);
                                        ref.read(origemSelecionadaProvider.notifier).state = d;
                                        ref.read(destinoSelecionadoProvider.notifier).state = o;
                                      },
                                      child: Container(
                                        width: 38,
                                        height: 38,
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.primary.withValues(alpha: 0.25),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.swap_horiz_rounded,
                                          color: Colors.white,
                                          size: 22,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                // Destino
                                Expanded(
                                  child: _DesktopInputPill(
                                    label: 'DESTINO',
                                    placeholder: 'Selecione o destino...',
                                    valorAtual: destino,
                                    icon: Icons.location_on,
                                    iconColor: AppColors.secondary,
                                    cidades: cidadesDestino,
                                    onSelecionada: (v) {
                                      _clearError();
                                      ref.read(destinoSelecionadoProvider.notifier).state = v;
                                    },
                                    onLimpa: () {
                                      _clearError();
                                      ref.read(destinoSelecionadoProvider.notifier).state = null;
                                    },
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Linha 2: Botão Buscar Vans em baixo
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton.icon(
                                onPressed: canSearch
                                    ? () => _executarBusca(
                                          context,
                                          origem.trim(),
                                          destino.trim(),
                                        )
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor:
                                      AppColors.primary.withValues(alpha: 0.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  elevation: 0,
                                ),
                                icon: _isSearching
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.search_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                label: Text(
                                  _isSearching ? 'Buscando...' : 'Buscar Vans',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Selos de Confiança (Hero Trust Badges)
                      const Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 16,
                        runSpacing: 10,
                        children: [
                          HeroTrustBadge(
                            icon: Icons.check_circle_outline_rounded,
                            label: '100% gratuito e sem cadastro',
                          ),
                          HeroTrustBadge(
                            icon: Icons.update_rounded,
                            label: 'Horários do dia atualizados',
                          ),
                          HeroTrustBadge(
                            icon: Icons.payments_outlined,
                            label: 'Tarifas oficiais de Alagoas',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

            // 3. Seção Rotas Populares (Grade / Lista Desktop)
            RepaintBoundary(
              child: Container(
                width: double.infinity,
                color: AppColors.background,
                padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 980),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Rotas Populares',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Selecione uma das linhas mais buscadas em Alagoas para ver os próximos horários.',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Lista de Cards de Rotas Populares
                      ...rotasPopularesDestaque.map((destaque) {
                        // Localiza rota no banco considerando origem, destino e via se especificada
                        Rota? rotaEncontrada = todasRotas.where((r) {
                          final matchOrig = r.origem.toLowerCase().contains(destaque.origem.toLowerCase());
                          final matchDest = r.destino.toLowerCase().contains(destaque.destino.toLowerCase());
                          final matchVia = destaque.via == null || r.linha.toLowerCase().contains(destaque.via!.toLowerCase());
                          return matchOrig && matchDest && matchVia;
                        }).firstOrNull;

                        Sentido sentido = Sentido.ida;
                        if (rotaEncontrada == null) {
                          rotaEncontrada = todasRotas.where((r) {
                            final matchOrig = r.origem.toLowerCase().contains(destaque.destino.toLowerCase());
                            final matchDest = r.destino.toLowerCase().contains(destaque.origem.toLowerCase());
                            final matchVia = destaque.via == null || r.linha.toLowerCase().contains(destaque.via!.toLowerCase());
                            return matchOrig && matchDest && matchVia;
                          }).firstOrNull;
                          if (rotaEncontrada != null) {
                            sentido = Sentido.volta;
                          }
                        }

                        final rotaFinal = rotaEncontrada ??
                            Rota(
                              id: destaque.fallbackId,
                              linha: '${destaque.origem} - ${destaque.destino}${destaque.via != null ? ' (${destaque.via})' : ''}',
                              origem: destaque.origem,
                              destino: destaque.destino,
                              diasOperacao: 'Diariamente',
                              tarifa: destaque.precoPadrao,
                            );

                        final tarifa = rotaFinal.tarifa ?? destaque.precoPadrao;
                        final precoFormatado = 'R\$ ${tarifa.toStringAsFixed(2).replaceAll('.', ',')}';

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _DesktopRouteCard(
                            origem: destaque.origem,
                            destino: destaque.destino,
                            via: destaque.via,
                            preco: precoFormatado,
                            horarioSaida: destaque.horarioSaida,
                            onVerDetalhes: () {
                              final itinerarioFallback = [
                                ParadaItinerario(
                                  parada: destaque.origem,
                                  horario: destaque.horarioSaida,
                                  descricao: 'Partida',
                                ),
                                ParadaItinerario(
                                  parada: destaque.destino,
                                  horario: '',
                                  descricao: 'Chegada',
                                ),
                              ];

                              final duracaoStr = rotaFinal.distanciaKm != null
                                  ? '${(rotaFinal.distanciaKm! * 1.15).round()} min'
                                  : '1h 45m';
                              final distanciaStr = rotaFinal.distanciaKm != null
                                  ? '${rotaFinal.distanciaKm} km'
                                  : '85 km';

                              final detalhes = DetalhesViagem(
                                codigo: rotaFinal.linha,
                                preco: precoFormatado,
                                rota: '${destaque.origem} x ${destaque.destino}',
                                origem: destaque.origem,
                                destino: destaque.destino,
                                itinerario: itinerarioFallback,
                                horaSaida: destaque.horarioSaida,
                                duracao: duracaoStr,
                                distancia: distanciaStr,
                                tipoLinha: 'Transporte Intermunicipal',
                                diasOperacao: rotaFinal.diasOperacao,
                                seccionamentos: rotaFinal.seccionamentos,
                                via: destaque.via != null
                                    ? (destaque.via!.toLowerCase().startsWith('via')
                                        ? destaque.via!
                                        : 'Via ${destaque.via!}')
                                    : null,
                              );

                              context.push(
                                '${AppRoutes.detalhesViagem}?rotaId=${rotaFinal.id}&sentido=${sentido == Sentido.ida ? 'IDA' : 'VOLTA'}',
                                extra: DetalhesViagemArgs(
                                  detalhes: detalhes,
                                  rotaId: rotaFinal.id,
                                  sentido: sentido == Sentido.ida ? 'IDA' : 'VOLTA',
                                ),
                              );
                            },
                            onTap: () {
                              context.push(
                                '${AppRoutes.resultados}?origem=${Uri.encodeComponent(destaque.origem)}&destino=${Uri.encodeComponent(destaque.destino)}&sentido=${sentido.name}',
                                extra: ResultadosArgs(
                                  rota: rotaFinal,
                                  sentido: sentido,
                                ),
                              );
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),

            // 4. Seção Por Que o Passaí (Dores, Benefícios e Público-alvo)
            const RepaintBoundary(child: WhyPassaiSection(isDesktop: true)),

            // 5. Rodapé Escuro Institucional
            const RepaintBoundary(child: WebFooter()),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Card de Rota Desktop (Horizontal com Origem ➔ Destino e Badge de Preço)
// ---------------------------------------------------------------------------
class _DesktopRouteCard extends StatefulWidget {
  const _DesktopRouteCard({
    required this.origem,
    required this.destino,
    this.via,
    required this.preco,
    required this.horarioSaida,
    required this.onTap,
    required this.onVerDetalhes,
  });

  final String origem;
  final String destino;
  final String? via;
  final String preco;
  final String horarioSaida;
  final VoidCallback onTap;
  final VoidCallback onVerDetalhes;

  @override
  State<_DesktopRouteCard> createState() => _DesktopRouteCardState();
}

class _DesktopRouteCardState extends State<_DesktopRouteCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered ? AppColors.primary : AppColors.border,
              width: _isHovered ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? AppColors.primary.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.02),
                blurRadius: _isHovered ? 12 : 4,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Origem ➔ Destino e Horário
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.origem,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          color: AppColors.primary,
                          size: 18,
                        ),
                      ),
                      Text(
                        widget.via != null
                            ? '${widget.destino} (${widget.via})'
                            : widget.destino,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Próximo horário de saída: ${widget.horarioSaida}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),

              // Ações: Preço + Botão Ver Rota no Mapa + Botão Ver Horários
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Badge de Preço
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      widget.preco,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Botão Ver Rota no Mapa
                  OutlinedButton.icon(
                    onPressed: widget.onVerDetalhes,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.alt_route_rounded, size: 15),
                    label: const Text(
                      'Ver Itinerário',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Botão Ver Horários
                  ElevatedButton.icon(
                    onPressed: widget.onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.schedule_rounded, size: 15),
                    label: const Text(
                      'Ver Horários',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
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
}

// ---------------------------------------------------------------------------
// Campo em formato de Pílula Desktop com Autocomplete
// ---------------------------------------------------------------------------
class _DesktopInputPill extends StatefulWidget {
  const _DesktopInputPill({
    required this.label,
    required this.placeholder,
    required this.valorAtual,
    required this.icon,
    required this.iconColor,
    required this.cidades,
    required this.onSelecionada,
    required this.onLimpa,
  });

  final String label;
  final String placeholder;
  final String? valorAtual;
  final IconData icon;
  final Color iconColor;
  final List<String> cidades;
  final ValueChanged<String> onSelecionada;
  final VoidCallback onLimpa;

  @override
  State<_DesktopInputPill> createState() => _DesktopInputPillState();
}

class _DesktopInputPillState extends State<_DesktopInputPill> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.valorAtual ?? '');
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(_DesktopInputPill oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.valorAtual != oldWidget.valorAtual &&
        widget.valorAtual != _controller.text) {
      _controller.text = widget.valorAtual ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF3EFEA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(widget.icon, color: widget.iconColor, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: RawAutocomplete<String>(
              textEditingController: _controller,
              focusNode: _focusNode,
              optionsBuilder: (textEditingValue) {
                final termo = textEditingValue.text.trim().toLowerCase();
                if (termo.isEmpty) return widget.cidades;
                return widget.cidades.where(
                  (c) => c.toLowerCase().contains(termo),
                );
              },
              onSelected: (cidade) {
                widget.onSelecionada(cidade);
                _focusNode.unfocus();
              },
              fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.label,
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.8,
                      ),
                    ),
                    TextField(
                      controller: controller,
                      focusNode: focusNode,
                      onSubmitted: (_) {
                        final text = controller.text.trim();
                        if (text.isNotEmpty) {
                          final match = widget.cidades.firstWhere(
                            (c) => c.toLowerCase() == text.toLowerCase(),
                            orElse: () => '',
                          );
                          if (match.isNotEmpty) {
                            widget.onSelecionada(match);
                            focusNode.unfocus();
                          }
                        }
                        onFieldSubmitted();
                      },
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        hintText: widget.placeholder,
                        hintStyle: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary.withValues(alpha: 0.7),
                          fontWeight: FontWeight.normal,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ],
                );
              },
              optionsViewBuilder: (context, onSelected, options) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 10,
                    borderRadius: BorderRadius.circular(12),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxHeight: 220,
                        maxWidth: 320,
                      ),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        itemCount: options.length,
                        itemBuilder: (context, index) {
                          final option = options.elementAt(index);
                          return ListTile(
                            dense: true,
                            leading: Icon(
                              widget.icon,
                              color: widget.iconColor,
                              size: 18,
                            ),
                            title: Text(
                              option,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            onTap: () => onSelected(option),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_controller.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _controller.clear();
                widget.onLimpa();
              },
              child: const Icon(
                Icons.clear_rounded,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }
}
