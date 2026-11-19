import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:passai/core/theme/app_colors.dart';
import 'package:passai/domain/entities/parada_itinerario.dart';
import 'package:passai/presentation/widgets/mapa/pino_teardrop_painter.dart';

/// Parada com coordenada resolvida
class ParadaMapeada {
  const ParadaMapeada({required this.parada, required this.coordenada});

  final ParadaItinerario parada;
  final LatLng coordenada;
}

/// Construtor de marcadores com ancoragem milimétrica exata para flutter_map
class MarcadoresBuilder {
  MarcadoresBuilder._();

  static List<Marker> build({
    required List<ParadaMapeada> paradasMapeadas,
    required ParadaItinerario? paradaSelecionada,
    required void Function(ParadaItinerario) onSelecionar,
  }) {
    final marcadores = <Marker>[];

    for (int i = 0; i < paradasMapeadas.length; i++) {
      final item = paradasMapeadas[i];
      final parada = item.parada;
      final coord = item.coordenada;
      final isFirst = i == 0;
      final isLast = i == paradasMapeadas.length - 1;
      final isSelected = paradaSelecionada == parada;

      if (isFirst || isLast) {
        final corPino = isFirst ? AppColors.primary : AppColors.secondary;
        final corDot = isFirst ? const Color(0xFF16A34A) : AppColors.secondary;

        marcadores.add(
          Marker(
            point: coord,
            width: 120,
            height: 60,
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onSelecionar(parada),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: isSelected ? AppColors.textPrimary : corPino,
                        width: isSelected ? 2.0 : 1.2,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x33000000),
                          blurRadius: 4,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: corDot,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            parada.parada,
                            style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 1),
                  CustomPaint(
                    size: Size(isSelected ? 26 : 22, isSelected ? 32 : 28),
                    painter: PinoTeardropPainter(
                      cor: corPino,
                      corBorda: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      } else {
        marcadores.add(
          Marker(
            point: coord,
            width: isSelected ? 18 : 14,
            height: isSelected ? 18 : 14,
            alignment: Alignment.center,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onSelecionar(parada),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppColors.primaryDark : AppColors.primary,
                    width: isSelected ? 3.0 : 2.2,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 3,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        marcadores.add(
          Marker(
            point: coord,
            width: 90,
            height: 24,
            alignment: const Alignment(0.0, -1.9),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onSelecionar(parada),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 1.5,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryLight
                        : Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                      width: isSelected ? 1.4 : 0.8,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x22000000),
                        blurRadius: 3,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Text(
                    parada.parada,
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 9,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: isSelected ? AppColors.primaryDark : AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }

    return marcadores;
  }
}
