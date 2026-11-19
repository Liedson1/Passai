import 'package:flutter/material.dart';
import 'package:passai/core/theme/app_colors.dart';

/// Card de Rota Desktop (Horizontal com Origem ➔ Destino e Badge de Preço)
class DesktopRouteCard extends StatefulWidget {
  const DesktopRouteCard({
    super.key,
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
  State<DesktopRouteCard> createState() => _DesktopRouteCardState();
}

class _DesktopRouteCardState extends State<DesktopRouteCard> {
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
            color: AppColors.surface,
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.alt_route_rounded, size: 15),
                    label: const Text(
                      'Ver Itinerário',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Botão Ver Horários
                  ElevatedButton.icon(
                    onPressed: widget.onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onDark,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.schedule_rounded, size: 15),
                    label: const Text(
                      'Ver Horários',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
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
