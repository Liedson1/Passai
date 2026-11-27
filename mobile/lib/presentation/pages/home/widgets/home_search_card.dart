import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:passai/core/constants/app_constants.dart';
import 'package:passai/core/errors/exceptions.dart';
import 'package:passai/core/theme/app_colors.dart';
import 'package:passai/core/theme/app_text_styles.dart';
import 'package:passai/presentation/pages/resultados/resultados_page.dart';
import 'package:passai/presentation/providers/rotas_provider.dart';

/// Card de busca com autocomplete de cidade para a HomePage
class HomeSearchCard extends ConsumerStatefulWidget {
  const HomeSearchCard({super.key});

  @override
  ConsumerState<HomeSearchCard> createState() => _HomeSearchCardState();
}

class _HomeSearchCardState extends ConsumerState<HomeSearchCard> {
  bool _isSearching = false;
  String? _errorMessage;
  IconData? _errorIcon;

  void _clearError() {
    if (_errorMessage != null) {
      setState(() {
        _errorMessage = null;
        _errorIcon = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final origem = ref.watch(origemSelecionadaProvider);
    final destino = ref.watch(destinoSelecionadoProvider);
    final cidadesOrigem = ref.watch(cidadesConectadasProvider(destino));
    final cidadesDestino = ref.watch(cidadesConectadasProvider(origem));

    final canSearch = origem != null &&
        origem.trim().isNotEmpty &&
        destino != null &&
        destino.trim().isNotEmpty &&
        !_isSearching;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Autocomplete Origem
          _CidadeAutocomplete(
            key: const Key('autocomplete_origem'),
            label: 'ORIGEM',
            icon: Icons.location_on,
            iconColor: AppColors.primary,
            valorInicial: origem,
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

          // Botão de swap
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                const Expanded(child: Divider(color: AppColors.border)),
                const SizedBox(width: 8),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _clearError();
                      final o = ref.read(origemSelecionadaProvider);
                      final d = ref.read(destinoSelecionadoProvider);
                      ref.read(origemSelecionadaProvider.notifier).state = d;
                      ref.read(destinoSelecionadoProvider.notifier).state = o;
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
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
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(child: Divider(color: AppColors.border)),
              ],
            ),
          ),

          // Autocomplete Destino
          _CidadeAutocomplete(
            key: const Key('autocomplete_destino'),
            label: 'DESTINO',
            icon: Icons.location_on,
            iconColor: AppColors.secondary,
            valorInicial: destino,
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

          const SizedBox(height: 16),

          // Botão Buscar Vans
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: canSearch
                  ? () {
                      HapticFeedback.mediumImpact();
                      _buscar(context, origem.trim(), destino.trim());
                    }
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
              icon: _isSearching
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.textOnPrimary,
                      ),
                    )
                  : const Icon(Icons.search, size: 18),
              label: Text(
                _isSearching ? 'Buscando...' : 'Buscar Vans',
                style: AppTextStyles.bodyBold(
                  fontSize: 15,
                  color: AppColors.textOnPrimary,
                ),
              ),
            ),
          ),

          // Banner de erro inline (substitui SnackBars)
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            _InlineAlertBanner(
              message: _errorMessage!,
              icon: _errorIcon ?? Icons.info_outline,
              onClose: _clearError,
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _buscar(
    BuildContext context,
    String origem,
    String destino,
  ) async {
    _clearError();

    if (origem.trim().toLowerCase() == destino.trim().toLowerCase()) {
      setState(() {
        _errorMessage = 'A origem e o destino devem ser cidades diferentes.';
        _errorIcon = Icons.info_outline;
      });
      return;
    }

    setState(() => _isSearching = true);

    try {
      final resultados = await ref
          .read(buscarRotasUsecaseProvider)
          .buscarComSentido(origem: origem, destino: destino);

      if (!mounted || !context.mounted) return;

      if (resultados.isNotEmpty) {
        final match = resultados.first;
        context.push(
          '${AppRoutes.resultados}?origem=${Uri.encodeComponent(origem)}&destino=${Uri.encodeComponent(destino)}&sentido=${match.sentido.name}',
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
}

// ---------------------------------------------------------------------------
// Banner de alerta inline (substitui SnackBars em formulários)
// ---------------------------------------------------------------------------
class _InlineAlertBanner extends StatelessWidget {
  const _InlineAlertBanner({
    required this.message,
    this.icon = Icons.info_outline,
    required this.onClose,
  });

  final String message;
  final IconData icon;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(AppRadii.input),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodyMedium(
                fontSize: 13,
                color: AppColors.primaryDark,
              ),
            ),
          ),
          GestureDetector(
            onTap: onClose,
            child: const Padding(
              padding: EdgeInsets.all(4.0),
              child: Icon(
                Icons.close,
                color: AppColors.primary,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Campo de autocomplete de cidade — busca rápida e digitação direta
// ---------------------------------------------------------------------------
class _CidadeAutocomplete extends ConsumerStatefulWidget {
  const _CidadeAutocomplete({
    super.key,
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.valorInicial,
    required this.cidades,
    required this.onSelecionada,
    required this.onLimpa,
  });

  final String label;
  final IconData icon;
  final Color iconColor;
  final String? valorInicial;
  final List<String> cidades;
  final void Function(String) onSelecionada;
  final VoidCallback onLimpa;

  @override
  ConsumerState<_CidadeAutocomplete> createState() =>
      _CidadeAutocompleteState();
}

class _CidadeAutocompleteState extends ConsumerState<_CidadeAutocomplete> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.valorInicial ?? '');
    _focusNode = FocusNode();
    _focusNode.addListener(_aoMudarFoco);
  }

  @override
  void didUpdateWidget(_CidadeAutocomplete oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.valorInicial != oldWidget.valorInicial &&
        widget.valorInicial != _controller.text) {
      _controller.text = widget.valorInicial ?? '';
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_aoMudarFoco);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _aoMudarFoco() {
    if (!_focusNode.hasFocus) {
      _confirmarSelecao();
    }
  }

  String? _encontrarMelhorMatch(String texto, List<String> todas) {
    final tNorm = _removerAcentos(texto);
    if (tNorm.isEmpty) return null;

    // 1. Correspondência exata
    for (final c in todas) {
      if (_removerAcentos(c) == tNorm) return c;
    }
    // 2. Prefixo (ex: "Delmiro" -> "Delmiro Gouveia")
    for (final c in todas) {
      if (_removerAcentos(c).startsWith(tNorm)) return c;
    }
    // 3. Substring (ex: "Branca" -> "Água Branca")
    for (final c in todas) {
      if (_removerAcentos(c).contains(tNorm)) return c;
    }
    return null;
  }

  void _confirmarSelecao() {
    final trimmed = _controller.text.trim();
    if (trimmed.isEmpty) return;

    final todas = ref.read(cidadesProvider).valueOrNull ?? widget.cidades;
    final match = _encontrarMelhorMatch(trimmed, todas);
    if (match != null) {
      if (_controller.text != match) {
        _controller.text = match;
      }
      widget.onSelecionada(match);
    }
  }

  static String _removerAcentos(String str) {
    return str
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[àáâãäå]'), 'a')
        .replaceAll(RegExp(r'[èéêë]'), 'e')
        .replaceAll(RegExp(r'[ìíîï]'), 'i')
        .replaceAll(RegExp(r'[òóôõö]'), 'o')
        .replaceAll(RegExp(r'[ùúûü]'), 'u')
        .replaceAll(RegExp(r'[ç]'), 'c');
  }

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<String>(
      textEditingController: _controller,
      focusNode: _focusNode,
      optionsBuilder: (textEditingValue) {
        final termo = textEditingValue.text.trim();
        if (termo.isEmpty) {
          return widget.cidades;
        }

        final tNorm = _removerAcentos(termo);
        final matches = widget.cidades.where((c) {
          return _removerAcentos(c).contains(tNorm);
        }).toList();

        // Se o que está digitado coincidir exatamente com uma única opção já selecionada,
        // fecha o dropdown flutuante
        if (matches.length == 1 && _removerAcentos(matches.first) == tNorm) {
          return const Iterable<String>.empty();
        }

        return matches;
      },
      onSelected: (cidade) {
        HapticFeedback.selectionClick();
        _controller.text = cidade;
        widget.onSelecionada(cidade);
        _focusNode.unfocus();
      },
      fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
        return Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: BoxDecoration(
            color: AppColors.inputBackground,
            borderRadius: BorderRadius.circular(AppRadii.input),
          ),
          child: Row(
            children: [
              Icon(widget.icon, color: widget.iconColor, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.label,
                      style: AppTextStyles.bodyRegular(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    TextField(
                      controller: controller,
                      focusNode: focusNode,
                      onSubmitted: (_) {
                        _confirmarSelecao();
                        focusNode.unfocus();
                        onSubmitted();
                      },
                      onChanged: (text) {
                        final trimmed = text.trim();
                        if (trimmed.isEmpty) {
                          widget.onLimpa();
                        } else {
                          final todas = ref.read(cidadesProvider).valueOrNull ?? widget.cidades;
                          final tNorm = _removerAcentos(trimmed);
                          final exactMatch = todas.firstWhere(
                            (c) => _removerAcentos(c) == tNorm,
                            orElse: () => '',
                          );
                          // Só propaga para o Riverpod se corresponder ao nome completo de uma cidade válida
                          if (exactMatch.isNotEmpty &&
                              exactMatch != widget.valorInicial) {
                            widget.onSelecionada(exactMatch);
                          }
                        }
                      },
                      style: AppTextStyles.bodySemibold(
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        hintText: 'Digite ou selecione a cidade...',
                        hintStyle: AppTextStyles.bodyMedium(
                          fontSize: 15,
                          color: AppColors.textSecondary,
                        ),
                        border: InputBorder.none,
                        filled: false,
                      ),
                    ),
                  ],
                ),
              ),
              // Ícone para limpar o campo
              if (controller.text.isNotEmpty)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    controller.clear();
                    widget.onLimpa();
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(6.0),
                    child: Icon(
                      Icons.close,
                      color: AppColors.textSecondary,
                      size: 18,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        if (options.isEmpty) {
          return const SizedBox.shrink();
        }

        final screenWidth = MediaQuery.of(context).size.width;
        final cardWidth = (screenWidth - 72).clamp(200.0, 600.0);

        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 6,
            shadowColor: AppColors.textPrimary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppRadii.input),
            color: AppColors.surface,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: cardWidth,
                maxHeight: 220,
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadii.input),
                  border: Border.all(color: AppColors.border),
                ),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: options.length,
                  separatorBuilder: (_, __) => const Divider(
                    height: 1,
                    color: AppColors.border,
                    indent: 14,
                    endIndent: 14,
                  ),
                  itemBuilder: (context, index) {
                    final cidade = options.elementAt(index);
                    return InkWell(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        onSelected(cidade);
                      },
                      borderRadius: BorderRadius.circular(AppRadii.input),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              widget.icon,
                              color: widget.iconColor,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                cidade,
                                style: AppTextStyles.bodyMedium(
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: AppColors.textSecondary,
                              size: 12,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
