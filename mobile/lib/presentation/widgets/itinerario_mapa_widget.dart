import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:passai/core/constants/app_constants.dart';
import 'package:passai/core/constants/coordenadas_cidades.dart';
import 'package:passai/core/services/osrm_routing_service.dart';
import 'package:passai/core/theme/app_colors.dart';
import 'package:passai/domain/entities/parada_itinerario.dart';
import 'package:passai/presentation/widgets/mapa/card_parada_detalhe.dart';
import 'package:passai/presentation/widgets/mapa/controles_mapa.dart';
import 'package:passai/presentation/widgets/mapa/legenda_mapa.dart';
import 'package:passai/presentation/widgets/mapa/marcadores_builder.dart';

/// Widget de mapa interativo para o itinerário da rota
class ItinerarioMapaWidget extends StatefulWidget {
  const ItinerarioMapaWidget({
    super.key,
    required this.paradas,
    this.altura = 240,
  });

  final List<ParadaItinerario> paradas;
  final double altura;

  /// Decodifica polylines de forma aritmeticamente segura delegando para o serviço OSRM
  static List<LatLng> decodePolyline(String encoded) =>
      OsrmRoutingService.decodePolyline(encoded);

  @override
  State<ItinerarioMapaWidget> createState() => _ItinerarioMapaWidgetState();
}

class _ItinerarioMapaWidgetState extends State<ItinerarioMapaWidget> {
  late final MapController _mapController;
  late final ValueNotifier<double> _rotacaoNotifier;

  List<LatLng> _rotaOsrm = [];
  bool _carregandoRota = true;
  ParadaItinerario? _paradaSelecionada;

  List<Marker>? _marcadoresCache;
  ParadaItinerario? _ultimaSelecao;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _rotacaoNotifier = ValueNotifier<double>(0.0);
    _buscarRotaOsrm();
  }

  @override
  void dispose() {
    _rotacaoNotifier.dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ItinerarioMapaWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.paradas != widget.paradas) {
      _marcadoresCache = null;
      _buscarRotaOsrm();
    }
  }

  LatLng? _resolverCoordenada(ParadaItinerario parada) {
    if (parada.temCoordenadas) {
      return LatLng(parada.latitude!, parada.longitude!);
    }
    final coordsCidade = CoordenadasCidades.obter(parada.parada);
    if (coordsCidade != null) {
      return LatLng(coordsCidade.latitude, coordsCidade.longitude);
    }
    return null;
  }

  Future<void> _buscarRotaOsrm() async {
    final pontosBase = widget.paradas
        .map(_resolverCoordenada)
        .whereType<LatLng>()
        .toList();

    if (pontosBase.length < 2) {
      if (mounted) setState(() => _carregandoRota = false);
      return;
    }

    final rota = await OsrmRoutingService.buscarRotaCompleta(pontosBase);
    if (mounted) {
      setState(() {
        _rotaOsrm = rota;
        _carregandoRota = false;
      });
    }
  }

  void _selecionarParada(ParadaItinerario parada) {
    setState(() {
      if (_paradaSelecionada == parada) {
        _paradaSelecionada = null;
      } else {
        _paradaSelecionada = parada;
        final coord = _resolverCoordenada(parada);
        if (coord != null) {
          _mapController.move(coord, 14.5);
        }
      }
      _marcadoresCache = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final paradasMapeadas = <ParadaMapeada>[];
    for (final p in widget.paradas) {
      final coord = _resolverCoordenada(p);
      if (coord != null) {
        paradasMapeadas.add(ParadaMapeada(parada: p, coordenada: coord));
      }
    }

    if (paradasMapeadas.length < 2) return const SizedBox.shrink();

    final pontosBase = paradasMapeadas.map((m) => m.coordenada).toList();
    final bounds = LatLngBounds.fromPoints(pontosBase);
    final pontosPolyline = _rotaOsrm.isNotEmpty ? _rotaOsrm : pontosBase;

    final hasCartoKey = AppConstants.cartoApiKey.isNotEmpty;
    final tileUrl = hasCartoKey
        ? 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png?key=${AppConstants.cartoApiKey}'
        : 'https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png';

    if (_marcadoresCache == null || _ultimaSelecao != _paradaSelecionada) {
      _marcadoresCache = MarcadoresBuilder.build(
        paradasMapeadas: paradasMapeadas,
        paradaSelecionada: _paradaSelecionada,
        onSelecionar: _selecionarParada,
      );
      _ultimaSelecao = _paradaSelecionada;
    }

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
                  mapController: _mapController,
                  options: MapOptions(
                    initialCameraFit: CameraFit.bounds(
                      bounds: bounds,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 36,
                      ),
                      maxZoom: 14.5,
                    ),
                    minZoom: 6.0,
                    maxZoom: 17.5,
                    onPositionChanged: (camera, hasGesture) {
                      _rotacaoNotifier.value = camera.rotation;
                    },
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all,
                      scrollWheelVelocity: 0.005,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: tileUrl,
                      subdomains: hasCartoKey
                          ? const ['a', 'b', 'c', 'd']
                          : const ['a', 'b', 'c'],
                      userAgentPackageName: 'app.passai.alagoas',
                      maxNativeZoom: 18,
                      maxZoom: 18.0,
                      keepBuffer: 5,
                      panBuffer: 1,
                    ),
                    if (pontosPolyline.length >= 2)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: pontosPolyline,
                            strokeWidth: 6.5,
                            color: Colors.white.withValues(alpha: 0.95),
                          ),
                          Polyline(
                            points: pontosPolyline,
                            strokeWidth: 4.5,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    MarkerLayer(
                      rotate: true,
                      markers: _marcadoresCache!,
                    ),
                  ],
                ),
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: ControlesMapa(
                    rotacaoNotifier: _rotacaoNotifier,
                    onResetRotation: () => _mapController.rotate(0.0),
                    onZoomIn: () {
                      final currentZoom = _mapController.camera.zoom;
                      _mapController.move(
                        _mapController.camera.center,
                        (currentZoom + 1).clamp(6.0, 17.5),
                      );
                    },
                    onZoomOut: () {
                      final currentZoom = _mapController.camera.zoom;
                      _mapController.move(
                        _mapController.camera.center,
                        (currentZoom - 1).clamp(6.0, 17.5),
                      );
                    },
                    onResetBounds: () {
                      _mapController.rotate(0.0);
                      _mapController.fitCamera(
                        CameraFit.bounds(
                          bounds: bounds,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 36,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (_carregandoRota)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: RepaintBoundary(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x1A000000),
                              blurRadius: 4,
                            ),
                          ],
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
                              'Traçando rota...',
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
                  ),
                if (_paradaSelecionada != null)
                  Positioned(
                    left: 10,
                    bottom: 10,
                    right: 56,
                    child: RepaintBoundary(
                      child: CardParadaDetalhe(
                        parada: _paradaSelecionada!,
                        onFechar: () => setState(() {
                          _paradaSelecionada = null;
                          _marcadoresCache = null;
                        }),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        LegendaMapa(
          totalParadas: paradasMapeadas.length,
          totalItinerario: widget.paradas.length,
        ),
      ],
    );
  }
}
