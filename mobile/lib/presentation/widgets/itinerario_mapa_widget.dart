import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:passai/core/theme/app_colors.dart';
import 'package:passai/domain/entities/parada_itinerario.dart';

/// Widget de mapa interativo do itinerário da viagem.
///
/// Exibe a rota entre as paradas seguindo as estradas reais,
/// obtidas via OSRM (Open Source Routing Machine — gratuito, sem API key).
///
/// Regras de UX (conforme estudo de viabilidade):
/// - Altura fixa e contida (220–320px) para não dominar o scroll.
/// - Gestos restritos: apenas pinchZoom — não captura o scroll vertical.
/// - Fallback gracioso: se menos de 2 paradas tiverem coordenadas ou
///   se o OSRM falhar, exibe linha reta como fallback.
class ItinerarioMapaWidget extends StatefulWidget {
  const ItinerarioMapaWidget({
    super.key,
    required this.paradas,
    this.altura = 240,
  });

  final List<ParadaItinerario> paradas;
  final double altura;

  @override
  State<ItinerarioMapaWidget> createState() => _ItinerarioMapaWidgetState();
}

class _ItinerarioMapaWidgetState extends State<ItinerarioMapaWidget> {
  /// Pontos do traçado OSRM (segue estradas reais)
  List<LatLng> _rotaOsrm = [];

  /// Estado de carregamento da rota OSRM
  bool _carregandoRota = true;

  @override
  void initState() {
    super.initState();
    _buscarRotaOsrm();
  }

  /// Busca o traçado real da rota via OSRM — gratuito, sem API key.
  /// Em caso de falha, usa linha reta entre os pontos como fallback.
  Future<void> _buscarRotaOsrm() async {
    final pontosBase = widget.paradas
        .where((p) => p.temCoordenadas)
        .map((p) => LatLng(p.latitude!, p.longitude!))
        .toList();

    if (pontosBase.length < 2) {
      if (mounted) setState(() => _carregandoRota = false);
      return;
    }

    try {
      // OSRM usa lon,lat (invertido em relação ao LatLng)
      final coords = pontosBase
          .map((p) => '${p.longitude},${p.latitude}')
          .join(';');

      final uri = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/$coords'
        '?overview=full&geometries=polyline',
      );

      final response = await http.get(uri).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final routes = data['routes'] as List?;
        if (routes != null && routes.isNotEmpty) {
          final geometry = (routes.first as Map)['geometry'] as String?;
          if (geometry != null) {
            final decoded = _decodePolyline(geometry);
            if (mounted) {
              setState(() {
                _rotaOsrm = decoded;
                _carregandoRota = false;
              });
              return;
            }
          }
        }
      }
    } catch (_) {
      // Fallback silencioso: usa linha reta se OSRM falhar
    }

    // Fallback: linha reta entre os pontos originais
    if (mounted) {
      setState(() {
        _rotaOsrm = widget.paradas
            .where((p) => p.temCoordenadas)
            .map((p) => LatLng(p.latitude!, p.longitude!))
            .toList();
        _carregandoRota = false;
      });
    }
  }

  /// Decodifica encoded polyline (algoritmo padrão Google / OSRM).
  List<LatLng> _decodePolyline(String encoded) {
    final result = <LatLng>[];
    int index = 0;
    int lat = 0, lng = 0;

    while (index < encoded.length) {
      int b, shift = 0, r = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        r |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      lat += (r & 1) != 0 ? ~(r >> 1) : r >> 1;

      shift = 0;
      r = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        r |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      lng += (r & 1) != 0 ? ~(r >> 1) : r >> 1;

      result.add(LatLng(lat / 1e5, lng / 1e5));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final pontosComCoordenadas = widget.paradas
        .where((p) => p.temCoordenadas)
        .toList();

    // Sem dados suficientes — fallback silencioso
    if (pontosComCoordenadas.length < 2) return const SizedBox.shrink();

    final pontosBase = pontosComCoordenadas
        .map((p) => LatLng(p.latitude!, p.longitude!))
        .toList();

    final bounds = LatLngBounds.fromPoints(pontosBase);

    // Usa traçado OSRM quando disponível, senão os pontos diretos
    final pontosPolyline = _rotaOsrm.isNotEmpty ? _rotaOsrm : pontosBase;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: widget.altura,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                FlutterMap(
                  options: MapOptions(
                    initialCameraFit: CameraFit.bounds(
                      bounds: bounds,
                      padding: const EdgeInsets.all(48),
                    ),
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.pinchZoom |
                          InteractiveFlag.doubleTapZoom,
                    ),
                  ),
                  children: [
                    // CartoDB Voyager — CORS habilitado para Flutter Web
                    TileLayer(
                      urlTemplate:
                          'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c', 'd'],
                      userAgentPackageName: 'app.passai.alagoas',
                      maxZoom: 19,
                    ),

                    // Polyline seguindo as estradas reais (via OSRM)
                    if (pontosPolyline.length >= 2)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: pontosPolyline,
                            strokeWidth: 4.5,
                            color: AppColors.primary,
                          ),
                        ],
                      ),

                    // Marcadores das paradas
                    MarkerLayer(
                      markers: _buildMarcadores(pontosBase),
                    ),
                  ],
                ),

                // Indicador de carregamento da rota OSRM
                if (_carregandoRota)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 10,
                            height: 10,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.5,
                              color: AppColors.primary,
                            ),
                          ),
                          SizedBox(width: 5),
                          Text(
                            'Calculando rota...',
                            style: TextStyle(
                              fontSize: 10,
                              fontFamily: 'Manrope',
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        _LegendaMapa(
          totalParadas: pontosComCoordenadas.length,
          totalItinerario: widget.paradas.length,
        ),
      ],
    );
  }

  List<Marker> _buildMarcadores(List<LatLng> pontos) {
    final marcadores = <Marker>[];

    for (int i = 0; i < pontos.length; i++) {
      final isFirst = i == 0;
      final isLast = i == pontos.length - 1;

      if (isFirst) {
        marcadores.add(Marker(
          point: pontos[i],
          width: 34,
          height: 34,
          child: const Icon(
            Icons.location_on,
            color: AppColors.primary,
            size: 32,
          ),
        ));
      } else if (isLast) {
        marcadores.add(Marker(
          point: pontos[i],
          width: 34,
          height: 34,
          child: const Icon(
            Icons.location_on,
            color: AppColors.secondary,
            size: 32,
          ),
        ));
      } else {
        // Parada intermediária — círculo preenchido menor
        marcadores.add(Marker(
          point: pontos[i],
          width: 18,
          height: 18,
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 2.5),
              boxShadow: const [
                BoxShadow(color: Color(0x33000000), blurRadius: 4),
              ],
            ),
          ),
        ));
      }
    }
    return marcadores;
  }
}

// ---------------------------------------------------------------------------
// Legenda discreta com créditos e contagem de paradas mapeadas
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
