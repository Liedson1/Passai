import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:passai/core/theme/app_colors.dart';
import 'package:passai/core/theme/app_text_styles.dart';
import 'package:passai/core/constants/app_constants.dart';
import 'package:passai/domain/entities/horario.dart';
import 'package:passai/domain/entities/rota.dart';
import 'package:passai/presentation/providers/horarios_provider.dart';
import 'package:passai/presentation/widgets/horario_tile.dart';

/// Argumentos para a tela de horários
class HorariosArgs {
  const HorariosArgs({
    required this.rota,
    this.initialSentido = Sentido.ida,
  });

  final Rota rota;
  final Sentido initialSentido;
}

/// Tela de horários de uma rota específica.
/// Recebe [rota] e [initialSentido] e exibe os horários por sentido (IDA/VOLTA).
class HorariosPage extends ConsumerStatefulWidget {
  const HorariosPage({
    super.key,
    required this.rota,
    this.initialSentido = Sentido.ida,
  });

  final Rota rota;
  final Sentido initialSentido;

  @override
  ConsumerState<HorariosPage> createState() => _HorariosPageState();
}

class _HorariosPageState extends ConsumerState<HorariosPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sentidoSelecionadoProvider.notifier).state = widget.initialSentido;
    });
  }

  @override
  Widget build(BuildContext context) {
    final sentido = ref.watch(sentidoSelecionadoProvider);
    final params = HorariosParams(rotaId: widget.rota.id, sentido: sentido);
    final horariosAsync = ref.watch(horariosProvider(params));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref.invalidate(horariosProvider(params));
          try {
            await ref.read(horariosProvider(params).future);
          } catch (_) {}
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _AppBar(rota: widget.rota, sentido: sentido),
            SliverToBoxAdapter(
              child: _SentidoSelector(sentido: sentido),
            ),
            horariosAsync.when(
              loading: () => const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
              error: (err, _) => SliverFillRemaining(
                child: _ErrorState(
                  message: err.toString(),
                  onRetry: () => ref.invalidate(horariosProvider(params)),
                ),
              ),
              data: (horarios) => horarios.isEmpty
                  ? const SliverFillRemaining(child: _EmptyState())
                  : _HorariosList(horarios: horarios),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// AppBar customizada com info da rota
// ---------------------------------------------------------------------------
class _AppBar extends StatelessWidget {
  const _AppBar({required this.rota, required this.sentido});

  final Rota rota;
  final Sentido sentido;

  @override
  Widget build(BuildContext context) {
    final origemExibida = sentido == Sentido.ida ? rota.origem : rota.destino;
    final destinoExibido = sentido == Sentido.ida ? rota.destino : rota.origem;

    return SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      backgroundColor: AppColors.primary,
      iconTheme: const IconThemeData(color: AppColors.textOnPrimary),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: AppColors.primary,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Linha badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.heroOverlay,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
                child: Text(
                  'Linha ${rota.linha}',
                  style: AppTextStyles.bodyBold(
                    fontSize: 12,
                    color: AppColors.textOnPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Origem → Destino dinâmico conforme sentido
              Row(
                children: [
                  Flexible(
                    child: Text(
                      origemExibida,
                      style: AppTextStyles.headingLG(
                        color: AppColors.textOnPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(
                      Icons.arrow_forward,
                      color: AppColors.textOnPrimary,
                      size: 18,
                    ),
                  ),
                  Flexible(
                    child: Text(
                      destinoExibido,
                      style: AppTextStyles.headingLG(
                        color: AppColors.textOnPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (rota.tarifa != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Tarifa: R\$ ${rota.tarifa!.toStringAsFixed(2).replaceAll('.', ',')}',
                  style: AppTextStyles.bodyRegular(
                    fontSize: 13,
                    color: AppColors.heroSubtitle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Seletor de sentido (IDA / VOLTA)
// ---------------------------------------------------------------------------
class _SentidoSelector extends ConsumerWidget {
  const _SentidoSelector({required this.sentido});

  final Sentido sentido;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: _SentidoButton(
              label: 'IDA',
              isSelected: sentido == Sentido.ida,
              onTap: () => ref
                  .read(sentidoSelecionadoProvider.notifier)
                  .state = Sentido.ida,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _SentidoButton(
              label: 'VOLTA',
              isSelected: sentido == Sentido.volta,
              onTap: () => ref
                  .read(sentidoSelecionadoProvider.notifier)
                  .state = Sentido.volta,
            ),
          ),
        ],
      ),
    );
  }
}

class _SentidoButton extends StatelessWidget {
  const _SentidoButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.button),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.bodyBold(
              fontSize: 14,
              color: isSelected ? AppColors.textOnPrimary : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Lista de horários
// ---------------------------------------------------------------------------
class _HorariosList extends StatelessWidget {
  const _HorariosList({required this.horarios});

  final List<Horario> horarios;

  @override
  Widget build(BuildContext context) {
    // Conta horários alterados para o banner informativo
    final numAlterados = horarios.where((h) => h.alterado).length;

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          // Banner de aviso quando há alterações no dia
          if (numAlterados > 0)
            _AlteracaoBanner(quantidade: numAlterados),

          const SizedBox(height: 12),

          ...List.generate(horarios.length, (index) {
            return Padding(
              key: ValueKey(horarios[index].id),
              padding: const EdgeInsets.only(bottom: 10),
              child: HorarioTile(horario: horarios[index]),
            );
          }),
        ]),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Banner de alerta quando há alterações no dia (RN06)
// ---------------------------------------------------------------------------
class _AlteracaoBanner extends StatelessWidget {
  const _AlteracaoBanner({required this.quantidade});

  final int quantidade;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(AppRadii.input),
        border: Border.all(color: const Color(0x80FFD700)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Color(0xFF856404), size: 20),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              '$quantidade horário${quantidade > 1 ? 's' : ''} foi alterado hoje. '
              'Os itens marcados em vermelho indicam a mudança.',
              style: AppTextStyles.bodyRegular(
                fontSize: 13,
                color: const Color(0xFF856404),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Estado vazio
// ---------------------------------------------------------------------------
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.directions_bus_outlined, size: 60, color: AppColors.border),
          const SizedBox(height: 16),
          Text(
            'Nenhum horário disponível',
            style: AppTextStyles.headingMD(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            'para este sentido no momento.',
            style: AppTextStyles.bodyRegular(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Estado de erro
// ---------------------------------------------------------------------------
class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 60, color: AppColors.primary),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar horários',
              style: AppTextStyles.headingMD(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyRegular(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.button),
                  ),
                ),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Tentar novamente'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
