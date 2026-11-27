import 'package:flutter/material.dart';
import 'package:passai/core/theme/app_colors.dart';

/// Legenda discreta com créditos dos provedores e contagem de paradas mapeadas
class LegendaMapa extends StatelessWidget {
  const LegendaMapa({
    super.key,
    required this.totalParadas,
    required this.totalItinerario,
  });

  final int totalParadas;
  final int totalItinerario;

  @override
  Widget build(BuildContext context) {
    final temParadasSemMapa = totalParadas < totalItinerario;

    return Row(
      children: [
        const Icon(Icons.map_outlined, size: 13, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        const Text(
          '© CartoDB Voyager | OpenStreetMap | OSRM',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
        if (temParadasSemMapa) ...[
          const SizedBox(width: 8),
          const Text('·', style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(width: 8),
          Text(
            '$totalParadas de $totalItinerario paradas no mapa',
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}
