import 'package:flutter/material.dart';
import 'package:passai/core/theme/app_colors.dart';
import 'package:passai/domain/entities/parada_itinerario.dart';

/// Card flutuante com detalhes da parada selecionada no mapa
class CardParadaDetalhe extends StatelessWidget {
  const CardParadaDetalhe({
    super.key,
    required this.parada,
    required this.onFechar,
  });

  final ParadaItinerario parada;
  final VoidCallback onFechar;

  @override
  Widget build(BuildContext context) {
    final isOrigem = parada.tipo == 'origem';
    final isDestino = parada.tipo == 'destino';

    final corTipo = isOrigem
        ? const Color(0xFF16A34A)
        : isDestino
            ? AppColors.secondary
            : AppColors.primary;

    final labelTipo = isOrigem
        ? 'Ponto de Partida'
        : isDestino
            ? 'Destino Final'
            : 'Parada Intermediária';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: corTipo.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isOrigem
                  ? Icons.trip_origin_rounded
                  : isDestino
                      ? Icons.flag_rounded
                      : Icons.location_on_rounded,
              size: 16,
              color: corTipo,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        parada.parada,
                        style: const TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (parada.horario.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.inputBackground,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          parada.horario,
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  parada.descricao != null && parada.descricao!.isNotEmpty
                      ? parada.descricao!
                      : labelTipo,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          InkWell(
            onTap: onFechar,
            borderRadius: BorderRadius.circular(12),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(
                Icons.close_rounded,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
