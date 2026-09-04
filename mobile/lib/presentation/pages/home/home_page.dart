import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:passai/core/theme/app_colors.dart';
import 'package:passai/core/theme/app_text_styles.dart';
import 'package:passai/core/constants/app_constants.dart';
import 'package:passai/domain/entities/horario.dart';
import 'package:passai/presentation/pages/horarios/horarios_page.dart';
import 'package:passai/presentation/providers/rotas_provider.dart';
import 'package:passai/presentation/widgets/popular_route_card.dart';

/// Tela principal do Passaí — consulta de horários de vans
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref.invalidate(cidadesProvider);
          ref.invalidate(todasAsRotasProvider);
          try {
            await Future.wait([
              ref.read(cidadesProvider.future),
              ref.read(todasAsRotasProvider.future),
            ]);
          } catch (_) {}
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _HeroBanner(),
              _BodyContent(),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Hero banner
// ---------------------------------------------------------------------------
class _HeroBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final now = DateTime.now();
    final hora = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    return Container(
      width: double.infinity,
      color: AppColors.primary,
      padding: EdgeInsets.fromLTRB(24, statusBarHeight + 12, 24, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status bar real
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                hora,
                style: AppTextStyles.bodySemibold(
                  fontSize: 14,
                  color: AppColors.textOnPrimary,
                ),
              ),
              const Row(
                children: [
                  Icon(Icons.signal_cellular_alt, color: AppColors.textOnPrimary, size: 16),
                  SizedBox(width: 4),
                  Icon(Icons.wifi, color: AppColors.textOnPrimary, size: 16),
                  SizedBox(width: 4),
                  Icon(Icons.battery_full, color: AppColors.textOnPrimary, size: 16),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Logo + pill ALAGOAS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.directions_bus, color: AppColors.textOnPrimary, size: 26),
                  const SizedBox(width: 8),
                  Text(
                    AppConstants.appName,
                    style: AppTextStyles.headingXL(color: AppColors.textOnPrimary),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.heroOverlay,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.textOnPrimary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      AppConstants.state,
                      style: AppTextStyles.bodyBold(
                        fontSize: 12,
                        color: AppColors.textOnPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            AppConstants.tagline,
            style: AppTextStyles.headingLG(color: AppColors.textOnPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            AppConstants.taglineSubtitle,
            style: AppTextStyles.bodyRegular(
              fontSize: 14,
              color: AppColors.heroSubtitle,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Conteúdo do corpo
// ---------------------------------------------------------------------------
class _BodyContent extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SearchCard(),
          const SizedBox(height: 16),
          _TimeCard(),
          const SizedBox(height: 24),
          _RotasPopularesSection(),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Card de busca com dropdowns dinâmicos
// ---------------------------------------------------------------------------
class _SearchCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cidadesAsync = ref.watch(cidadesProvider);
    final origem = ref.watch(origemSelecionadaProvider);
    final destino = ref.watch(destinoSelecionadoProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: AppColors.border),
      ),
      child: cidadesAsync.when(
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        ),
        error: (_, __) => Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Erro ao carregar cidades. Verifique a conexão.',
            style: AppTextStyles.bodyRegular(
              fontSize: 14,
              color: AppColors.primary,
            ),
          ),
        ),
        data: (cidades) => Column(
          children: [
            // Dropdown Origem
            _CidadeDropdown(
              label: 'ORIGEM',
              icon: Icons.circle,
              iconColor: AppColors.primary,
              value: origem,
              cidades: cidades,
              onChanged: (v) =>
                  ref.read(origemSelecionadaProvider.notifier).state = v,
            ),

            // Swap button
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  const Expanded(child: Divider(color: AppColors.border)),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      final origemAtual = ref.read(origemSelecionadaProvider);
                      final destinoAtual = ref.read(destinoSelecionadoProvider);
                      ref.read(origemSelecionadaProvider.notifier).state = destinoAtual;
                      ref.read(destinoSelecionadoProvider.notifier).state = origemAtual;
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.swap_vert,
                        color: AppColors.textOnPrimary,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(child: Divider(color: AppColors.border)),
                ],
              ),
            ),

            // Dropdown Destino
            _CidadeDropdown(
              label: 'DESTINO',
              icon: Icons.location_on,
              iconColor: AppColors.secondary,
              value: destino,
              cidades: cidades,
              onChanged: (v) =>
                  ref.read(destinoSelecionadoProvider.notifier).state = v,
            ),

            const SizedBox(height: 12),

            // Botão Buscar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: (origem != null && destino != null)
                    ? () => _buscar(context, ref, origem, destino)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.border,
                  foregroundColor: AppColors.textOnPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.button),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.search, size: 18),
                label: Text(
                  'Buscar Vans',
                  style: AppTextStyles.bodyBold(
                    fontSize: 15,
                    color: AppColors.textOnPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _buscar(
    BuildContext context,
    WidgetRef ref,
    String origem,
    String destino,
  ) async {
    if (origem.trim().toLowerCase() == destino.trim().toLowerCase()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A origem e o destino devem ser cidades diferentes.'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final resultados = await ref
        .read(buscarRotasUsecaseProvider)
        .buscarComSentido(origem: origem, destino: destino);

    if (!context.mounted) return;

    if (resultados.isNotEmpty) {
      final match = resultados.first;
      context.push(
        AppRoutes.horarios,
        extra: HorariosArgs(
          rota: match.rota,
          initialSentido: match.sentido,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Nenhuma van direta cadastrada entre $origem e $destino.',
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

// ---------------------------------------------------------------------------
// Dropdown de cidade
// ---------------------------------------------------------------------------
class _CidadeDropdown extends StatelessWidget {
  const _CidadeDropdown({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.cidades,
    required this.onChanged,
  });

  final String label;
  final IconData icon;
  final Color iconColor;
  final String? value;
  final List<String> cidades;
  final void Function(String?) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadii.input),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                hint: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: AppTextStyles.bodyRegular(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      'Selecione...',
                      style: AppTextStyles.bodyMedium(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                selectedItemBuilder: (context) => cidades
                    .map(
                      (c) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            label,
                            style: AppTextStyles.bodyRegular(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            c,
                            style: AppTextStyles.bodySemibold(
                              fontSize: 15,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
                items: cidades
                    .map(
                      (c) => DropdownMenuItem(
                        value: c,
                        child: Text(
                          c,
                          style: AppTextStyles.bodyRegular(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Card de data e hora real
// ---------------------------------------------------------------------------
class _TimeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final diasSemana = ['Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado', 'Domingo'];
    final meses = [
      'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro',
    ];
    final diaSemana = diasSemana[now.weekday - 1];
    final mes = meses[now.month - 1];
    final hora = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.secondaryLight,
        borderRadius: BorderRadius.circular(AppRadii.input),
      ),
      child: Row(
        children: [
          const Icon(Icons.access_time, color: AppColors.secondary, size: 18),
          const SizedBox(width: 8),
          Text(
            'Hoje • $diaSemana, ${now.day} de $mes • $hora',
            style: AppTextStyles.bodySemibold(
              fontSize: 13,
              color: AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Seção de rotas populares — carregadas do Supabase
// ---------------------------------------------------------------------------
class _RotasPopularesSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todasRotasAsync = ref.watch(todasAsRotasProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rotas Disponíveis',
          style: AppTextStyles.headingMD(color: AppColors.textPrimary),
        ),
        const SizedBox(height: 12),
        todasRotasAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          ),
          error: (_, __) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Não foi possível carregar as rotas disponíveis.',
              style: AppTextStyles.bodyRegular(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          data: (rotas) {
            if (rotas.isEmpty) {
              return Text(
                'Nenhuma rota disponível no momento.',
                style: AppTextStyles.bodyRegular(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              );
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: rotas.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final rota = rotas[index];
                return PopularRouteCard(
                  key: ValueKey(rota.id),
                  route: PopularRoute(
                    from: rota.origem,
                    to: rota.destino,
                    nextTime: '—',
                    price: rota.tarifa != null
                        ? 'R\$ ${rota.tarifa!.toStringAsFixed(2).replaceAll('.', ',')}'
                        : 'Consultar',
                  ),
                  onTap: () => context.push(
                    AppRoutes.horarios,
                    extra: HorariosArgs(
                      rota: rota,
                      initialSentido: Sentido.ida,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
