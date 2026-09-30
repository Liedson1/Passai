import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:passai/core/theme/app_colors.dart';
import 'package:passai/domain/entities/parada_itinerario.dart';

/// Widget de mapa interativo do itinerário da viagem.
///
/// Exibe a rota entre as paradas com marcadores temáticos e polyline
/// na paleta oficial do Passaí (terracota + azul operacional).
///
/// Regras de UX (conforme estudo de viabilidade):
/// - Altura fixa e contida (220–320px) para não dominar o scroll.
/// - Gestos restritos: apenas pinchZoom — não captura o scroll vertical do celular.
/// - Fallback silencioso: se menos de 2 paradas tiverem coordenadas, o widget
///   retorna [SizedBox.shrink()] sem lançar nenhum erro.
class ItinerarioMapaWidget extends StatelessWidget {
  const ItinerarioMapaWidget({
    super.key,
    required this.paradas,
    this.altura = 240,
  });

  /// Lista ordenada de paradas do itinerário (origem → destino)
  final List<ParadaItinerario> paradas;

  /// Altura em pixels do componente do mapa
  final double altura;

  @override
  Widget build(BuildContext context) {
    // Filtra apenas paradas com coordenadas cadastradas
    final pontosComCoordenadas = paradas
        .where((p) => p.temCoordenadas)
        .toList();

    // Sem dados suficientes: fallback gracioso — nenhum erro, nenhum mapa
    if (pontosComCoordenadas.length < 2) return const SizedBox.shrink();

    final pontos = pontosComCoordenadas
        .map((p) => LatLng(p.latitude!, p.longitude!))
        .toList();

    final bounds = LatLngBounds.fromPoints(pontos);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MapaContainer(pontos: pontos, bounds: bounds, altura: altura),
        const SizedBox(height: 8),
        _LegendaMapa(
          totalParadas: pontosComCoordenadas.length,
          totalItinerario: paradas.length,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Container do mapa (ClipRRect + FlutterMap)
// ---------------------------------------------------------------------------
class _MapaContainer extends StatelessWidget {
  const _MapaContainer({
    required this.pontos,
    required this.bounds,
    required this.altura,
  });

  final List<LatLng> pontos;
  final LatLngBounds bounds;
  final double altura;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: altura,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: FlutterMap(
          options: MapOptions(
            // Centraliza e enquadra todos os pontos da rota com padding
            initialCameraFit: CameraFit.bounds(
              bounds: bounds,
              padding: const EdgeInsets.all(36),
            ),
            // Apenas pinch-to-zoom: evita capturar o scroll vertical
            // do celular quando o passageiro rola a página (RN de UX)
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.pinchZoom | InteractiveFlag.doubleTapZoom,
            ),
          ),
          children: [
            // Tiles do CartoDB Voyager — gratuito, sem API key e com CORS
            // habilitado para Flutter Web (OSM bloqueia CORS no browser).
            TileLayer(
              urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
              subdomains: const ['a', 'b', 'c', 'd'],
              userAgentPackageName: 'app.passai.alagoas',
              maxZoom: 19,
            ),

            // Polyline conectando as paradas
            PolylineLayer(
              polylines: [
                Polyline(
                  points: pontos,
                  strokeWidth: 4.0,
                  color: AppColors.primary,
                ),
              ],
            ),

            // Marcadores de cada parada
            MarkerLayer(
              markers: _buildMarcadores(pontos),
            ),
          ],
        ),
      ),
    );
  }

  /// Constrói os marcadores: pino terracota na origem, círculos nas
  /// intermediárias e pino azul no destino — conforme a paleta do Passaí.
  List<Marker> _buildMarcadores(List<LatLng> pontos) {
    final marcadores = <Marker>[];

    for (int i = 0; i < pontos.length; i++) {
      final isFirst = i == 0;
      final isLast = i == pontos.length - 1;

      if (isFirst) {
        // Ponto de Partida — pino terracota (AppColors.primary)
        marcadores.add(
          Marker(
            point: pontos[i],
            width: 34,
            height: 34,
            child: const Icon(
              Icons.location_on,
              color: AppColors.primary,
              size: 32,
            ),
          ),
        );
      } else if (isLast) {
        // Ponto de Chegada — pino azul operacional (AppColors.secondary)
        marcadores.add(
          Marker(
            point: pontos[i],
            width: 34,
            height: 34,
            child: const Icon(
              Icons.location_on,
              color: AppColors.secondary,
              size: 32,
            ),
          ),
        );
      } else {
        // Paradas intermediárias — círculo branco com borda terracota
        marcadores.add(
          Marker(
            point: pontos[i],
            width: 14,
            height: 14,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary,
                  width: 2.5,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x30000000),
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }

    return marcadores;
  }
}

// ---------------------------------------------------------------------------
// Legenda discreta abaixo do mapa
// ---------------------------------------------------------------------------
class _LegendaMapa extends StatelessWidget {
  const _LegendaMapa({
    required this.totalParadas,
    required this.totalItinerario,
  });

  final int totalParadas;
  final int totalItinerario;

  @override
  Widget build(BuildContext context) {
    // Exibe aviso discreto quando nem todas as paradas têm coordenadas
    final temParadasSemMapa = totalParadas < totalItinerario;

    return Row(
      children: [
        const Icon(Icons.map_outlined, size: 13, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        const Text(
          '© CartoDB | OpenStreetMap',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
        if (temParadasSemMapa) ...[
          const SizedBox(width: 8),
          const Icon(Icons.info_outline, size: 12, color: AppColors.textSecondary),
          const SizedBox(width: 3),
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
