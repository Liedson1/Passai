import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:passai/core/constants/app_constants.dart';
import 'package:passai/core/constants/coordenadas_cidades.dart';
import 'package:passai/core/theme/app_colors.dart';
import 'package:passai/domain/entities/parada_itinerario.dart';

/// Helper interno com dados de uma parada e sua coordenada canônica validada
class _ParadaMapeada {
  const _ParadaMapeada({
    required this.parada,
    required this.coordenada,
  });

  final ParadaItinerario parada;
  final LatLng coordenada;
}

/// Widget de mapa interativo do itinerário da viagem.
///
/// Exibe a rota entre as paradas seguindo as estradas reais,
/// obtidas via OSRM (Open Source Routing Machine).
/// Utiliza os tiles do CartoDB Voyager autenticados com chave de API.
///
/// Recursos de usabilidade e precisão:
/// - Coordenadas canônicas oficiais (IBGE / OSM) para fixação milimétrica dos pinos.
/// - Rotação completa do mapa habilitada (gesto de dois dedos) com bússola de retorno ao Norte.
/// - Controles estilo Google Maps: Zoom (+/-), Recentralizar Rota e Bússola.
/// - Marcadores destacados com nome da cidade e card interativo ao tocar.
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

  /// Decodifica encoded polyline (algoritmo padrão Google / OSRM).
  ///
  /// NOTA CRÍTICA WEB/DART2JS:
  /// No compilador Dart2JS (Web), o operador bitwise not `~` é compilado para `(~x) >>> 0`,
  /// o que converte números negativos em inteiros de 32 bits sem sinal (~4,29 bilhões).
  /// Para garantir 100% de paridade e precisão matemática idêntica no Mobile (Dart VM)
  /// e na Web (JavaScript), utilizamos a equivalência aritmética `~x == -((x) + 1)`,
  /// prevenindo qualquer overflow ou corrupção de coordenadas.
  @visibleForTesting
  static List<LatLng> decodePolyline(String encoded) {
    final result = <LatLng>[];
    int index = 0;
    int lat = 0, lng = 0;

    while (index < encoded.length) {
      int b, shift = 0, r = 0;
      do {
        if (index >= encoded.length) return result;
        b = encoded.codeUnitAt(index++) - 63;
        r |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final deltaLat = (r & 1) != 0 ? -((r >> 1) + 1) : (r >> 1);
      lat += deltaLat;

      shift = 0;
      r = 0;
      do {
        if (index >= encoded.length) return result;
        b = encoded.codeUnitAt(index++) - 63;
        r |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final deltaLng = (r & 1) != 0 ? -((r >> 1) + 1) : (r >> 1);
      lng += deltaLng;

      final latDec = lat / 1e5;
      final lngDec = lng / 1e5;
      if (latDec.abs() <= 90 && lngDec.abs() <= 180) {
        result.add(LatLng(latDec, lngDec));
      }
    }
    return result;
  }
}

class _ItinerarioMapaWidgetState extends State<ItinerarioMapaWidget> {
  final MapController _mapController = MapController();

  /// Pontos do traçado OSRM (segue estradas reais)
  List<LatLng> _rotaOsrm = [];

  /// Estado de carregamento da rota OSRM
  bool _carregandoRota = true;

  /// Parada selecionada pelo usuário ao tocar no marcador
  ParadaItinerario? _paradaSelecionada;

  /// Rotação isolada via ValueNotifier — atualizar esse valor NÃO reconstrói o mapa inteiro.
  /// Apenas o ValueListenableBuilder da bússola reage, eliminando jank nos gestos.
  final ValueNotifier<double> _rotacaoNotifier = ValueNotifier<double>(0.0);

  /// Cache de marcadores — só recalculado quando paradas ou seleção mudam
  List<Marker>? _marcadoresCache;
  ParadaItinerario? _ultimaSelecao;

  @override
  void initState() {
    super.initState();
    _buscarRotaOsrm();
  }

  @override
  void didUpdateWidget(covariant ItinerarioMapaWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.paradas != widget.paradas) {
      _marcadoresCache = null; // Invalida cache ao trocar de rota
      _buscarRotaOsrm();
    }
  }

  @override
  void dispose() {
    _rotacaoNotifier.dispose();
    super.dispose();
  }

  /// Resolve a coordenada mais precisa para a parada (canônica oficial ou vinda do model)
  LatLng? _resolverCoordenada(ParadaItinerario p) {
    return CoordenadasCidades.obter(p.parada) ??
        (p.temCoordenadas ? LatLng(p.latitude!, p.longitude!) : null);
  }

  /// Verifica se um ponto geográfico corresponde a Arapiraca (Ponto das Vans / Rua Santos Dumont).
  bool _isArapiraca(LatLng p) {
    return (p.latitude - (-9.7495158)).abs() < 0.02 &&
        (p.longitude - (-36.6666349)).abs() < 0.02;
  }

  /// Corredor real da van saindo de Arapiraca rumo ao Sertão:
  /// 1. Sai por trás do ponto na Rua Santos Dumont e sobe a Rua Marechal Floriano Peixoto
  ///    passando em frente ao Quintela e por trás da Drogasil.
  /// 2. Entra na Rua Antônio Rochery de Lima, vira na Rua Horácio Alexandre dos Santos
  ///    passando em frente à Escola Alternativa e pela Rua Aurilia Vieira Pereira.
  /// 3. Vira à esquerda na Avenida Benjamin Freire de Amorim e segue até a Igrejinha.
  /// 4. Perto da Igrejinha, pega a alça suave à direita entrando na AL-220 sentido leste.
  /// 5. Segue na AL-220 pista leste até a alça de retorno no canteiro central (-9.729528, -36.663551).
  /// 6. Faz o retorno para a AL-220 pista oeste e segue direto e reto rumo ao Sertão.
  static const List<LatLng> _corredorSaidaArapiracaSertao = [
    LatLng(-9.7495158, -36.6666349), // Ponto das Vans (Rua Santos Dumont)
    LatLng(-9.749591, -36.668950),   // Rua Santos Dumont (por trás do ponto)
    LatLng(-9.749069, -36.668776),   // Esquina Santos Dumont x Floriano Peixoto
    LatLng(-9.748137, -36.668455),   // Marechal Floriano Peixoto
    LatLng(-9.747547, -36.668263),   // Marechal Floriano Peixoto (em frente ao Quintela)
    LatLng(-9.746453, -36.667894),   // Cruzamento Ventura de Farias x Floriano Peixoto
    LatLng(-9.745532, -36.667598),   // Marechal Floriano Peixoto (por trás da Drogasil)
    LatLng(-9.744452, -36.667244),   // Marechal Floriano Peixoto (por trás da Drogasil)
    LatLng(-9.744030, -36.667088),   // Marechal Floriano Peixoto
    LatLng(-9.743641, -36.666944),   // Esquina Floriano Peixoto x Antônio Rochery
    LatLng(-9.743000, -36.666698),   // Rua Antônio Rochery de Lima
    LatLng(-9.742396, -36.666479),   // Rua Antônio Rochery de Lima
    LatLng(-9.741788, -36.666243),   // Esquina Antônio Rochery x Horácio Alexandre dos Santos
    LatLng(-9.741208, -36.666730),   // Rua Horácio Alexandre dos Santos
    LatLng(-9.740778, -36.667089),   // Rua Horácio Alexandre dos Santos
    LatLng(-9.740344, -36.667454),   // Em frente à Escola Alternativa
    LatLng(-9.739902, -36.667256),   // Rua Aurilia Vieira Pereira
    LatLng(-9.739618, -36.666194),   // Pega a Avenida Benjamin Freire para a esquerda
    LatLng(-9.738971, -36.666371),   // Avenida Benjamin Freire de Amorim
    LatLng(-9.737329, -36.666835),   // Avenida Benjamin Freire de Amorim
    LatLng(-9.734559, -36.667609),   // Avenida Benjamin Freire de Amorim
    LatLng(-9.731144, -36.668585),   // Avenida Benjamin Freire de Amorim
    LatLng(-9.728688, -36.669295),   // Avenida Benjamin Freire de Amorim
    LatLng(-9.728027, -36.669495),   // Aproximação da Igrejinha
    LatLng(-9.727847, -36.669550),   // Semáforo da Igrejinha
    LatLng(-9.727777, -36.669565),   // Alça suave de acesso à direita para AL-220
    LatLng(-9.727698, -36.669557),   // Curva da alça de acesso
    LatLng(-9.727650, -36.669546),
    LatLng(-9.727595, -36.669497),
    LatLng(-9.727567, -36.669419),   // Entrada suave na AL-220 pista leste
    LatLng(-9.727711, -36.669021),   // AL-220 pista leste
    LatLng(-9.728696, -36.666149),   // AL-220 pista leste
    LatLng(-9.728796, -36.665855),   // AL-220 pista leste
    LatLng(-9.728960, -36.665364),   // AL-220 pista leste
    LatLng(-9.729156, -36.664798),   // AL-220 pista leste
    LatLng(-9.729552, -36.663655),   // AL-220 pista leste (aproximação do retorno)
    LatLng(-9.729533, -36.663626),   // Curva de retorno no canteiro central (-9.729528, -36.663551)
    LatLng(-9.729489, -36.663595),   // Alça de retorno entre as pistas da AL-220
    LatLng(-9.729421, -36.663597),   // Ingressa na AL-220 pista oeste
    LatLng(-9.729192, -36.664281),   // AL-220 pista oeste (seguindo reto rumo ao Sertão)
    LatLng(-9.729065, -36.664683),   // AL-220 pista oeste
    LatLng(-9.728852, -36.665354),   // AL-220 pista oeste
    LatLng(-9.728684, -36.665859),   // AL-220 pista oeste
    LatLng(-9.727957, -36.667976),   // AL-220 pista oeste
    LatLng(-9.727771, -36.668510),   // AL-220 pista oeste
    LatLng(-9.727589, -36.668999),   // AL-220 pista oeste
    LatLng(-9.727560, -36.669077),   // Viaduto do Semáforo da Igrejinha (pista oeste)
    LatLng(-9.727512, -36.669204),   // AL-220 pista oeste
    LatLng(-9.727338, -36.669665),   // AL-220 pista oeste
    LatLng(-9.727294, -36.669773),   // AL-220 pista oeste
    LatLng(-9.727275, -36.669820),   // AL-220 pista oeste
    LatLng(-9.726130, -36.673083),   // AL-220 pista oeste
    LatLng(-9.725904, -36.673745),   // AL-220 pista oeste
    LatLng(-9.725303, -36.675542),   // AL-220 pista oeste
    LatLng(-9.724152, -36.678997),   // AL-220 pista oeste
    LatLng(-9.723721, -36.680359),   // AL-220 pista oeste contínua e reta rumo ao Sertão
  ];

  /// Corredor real da van chegando a Arapiraca vindo do Sertão pela AL-220:
  /// Segue direto na rodovia AL-220 até o Semáforo da Igrejinha (sem desvios),
  /// vira à direita no semáforo e desce direto pela Avenida Benjamin Freire de Amorim.
  /// Ao chegar perto da Alternativa, NÃO desvia para a Floriano Peixoto:
  /// continua direto na avenida seguindo a linha do trem (Rua Maurício Pereira / Praça Lions)
  /// até o cruzamento com a Rua Santos Dumont, virando no Ponto das Vans.
  static const List<LatLng> _corredorChegadaArapiracaSertao = [
    LatLng(-9.727847, -36.669550),   // Semáforo da Igrejinha na AL-220 (pega a direita na avenida)
    LatLng(-9.728688, -36.669295),   // Avenida Benjamin Freire de Amorim
    LatLng(-9.731144, -36.668585),   // Avenida Benjamin Freire de Amorim
    LatLng(-9.734559, -36.667609),   // Avenida Benjamin Freire de Amorim
    LatLng(-9.737329, -36.666835),   // Avenida Benjamin Freire de Amorim
    LatLng(-9.738971, -36.666371),   // Avenida Benjamin Freire de Amorim
    LatLng(-9.739618, -36.666194),   // Avenida Benjamin Freire de Amorim
    LatLng(-9.740782, -36.665867),   // Avenida Benjamin Freire (passando perto da Alternativa)
    LatLng(-9.741552, -36.665629),   // Avenida Benjamin Freire
    LatLng(-9.741764, -36.665582),   // Início da Rua Maurício Pereira (Avenida da Linha do Trem)
    LatLng(-9.742339, -36.665648),   // Rua Maurício Pereira (seguindo a linha do trem)
    LatLng(-9.742914, -36.665705),   // Rua Maurício Pereira
    LatLng(-9.743522, -36.665755),   // Rua Maurício Pereira
    LatLng(-9.744104, -36.665804),   // Rua Maurício Pereira
    LatLng(-9.745650, -36.665931),   // Rua Maurício Pereira
    LatLng(-9.746019, -36.665958),   // Rua Maurício Pereira (Praça Lions)
    LatLng(-9.746932, -36.666030),   // Rua Maurício Pereira
    LatLng(-9.748614, -36.666177),   // Rua Maurício Pereira
    LatLng(-9.749678, -36.666271),   // Esquina Maurício Pereira x Rua Santos Dumont
    LatLng(-9.7495158, -36.6666349), // Ponto das Vans (Rua Santos Dumont / Baixão)
  ];

  /// Detecta se a rota inclui travessia de Jaramataia no sentido Oeste (ex: Arapiraca -> Olho d'Água).
  /// No OpenStreetMap, a saída oeste de Jaramataia não possui elo atravessando o canteiro central
  /// da AL-220 (pista sentido Sertão). Sem contornar isso, o motor OSRM obriga a van a fazer
  /// uma volta de retorno desnecessária de 3,2 km até o trevo leste.
  int _indiceJaramataiaWestbound(List<LatLng> pontos) {
    for (int i = 0; i < pontos.length - 1; i++) {
      final p = pontos[i];
      final isJaramataia = (p.latitude - (-9.65769)).abs() < 0.01 &&
          (p.longitude - (-37.00450)).abs() < 0.01;
      if (isJaramataia && pontos[i + 1].longitude < -37.01) {
        return i;
      }
    }
    return -1;
  }

  /// Requisita o traçado OSRM para uma sequência de pontos geográficos.
  ///
  /// Utiliza `geometries=geojson` para obter coordenadas puras em formato numérico
  /// [longitude, latitude], eliminando qualquer risco de perda de precisão ou erro
  /// de decodificação bitwise entre as plataformas Mobile e Web.
  Future<List<LatLng>?> _requisitarOsrm(List<LatLng> pontos) async {
    if (pontos.length < 2) return pontos;
    final coords = pontos.map((p) => '${p.longitude},${p.latitude}').join(';');
    final uri = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/$coords'
      '?overview=full&geometries=geojson',
    );
    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final routes = data['routes'] as List?;
        if (routes != null && routes.isNotEmpty) {
          final firstRoute = routes.first as Map<String, dynamic>;
          final geometry = firstRoute['geometry'];
          if (geometry is Map && geometry['coordinates'] is List) {
            final coordsList = geometry['coordinates'] as List;
            final pts = <LatLng>[];
            for (final c in coordsList) {
              if (c is List && c.length >= 2) {
                final lon = (c[0] as num).toDouble();
                final lat = (c[1] as num).toDouble();
                if (lat.abs() <= 90 && lon.abs() <= 180) {
                  pts.add(LatLng(lat, lon));
                }
              }
            }
            if (pts.isNotEmpty) return pts;
          } else if (geometry is String) {
            return ItinerarioMapaWidget.decodePolyline(geometry);
          }
        }
      }
    } catch (_) {}
    return null;
  }

  /// Busca o traçado real da rota via OSRM — gratuito, sem API key.
  /// Em caso de falha, usa linha reta entre os pontos como fallback.
  Future<void> _buscarRotaOsrm() async {
    final pontosBase = widget.paradas
        .map(_resolverCoordenada)
        .whereType<LatLng>()
        .toList();

    if (pontosBase.length < 2) {
      if (mounted) setState(() => _carregandoRota = false);
      return;
    }

    try {
      final idxJaramataia = _indiceJaramataiaWestbound(pontosBase);
      final isPartidaArapiracaSertao =
          _isArapiraca(pontosBase.first) && pontosBase[1].longitude < -36.7;
      final isChegadaArapiracaSertao =
          _isArapiraca(pontosBase.last) && pontosBase[pontosBase.length - 2].longitude < -36.7;

      if (idxJaramataia >= 0) {
        // Rota no sentido oeste passando por Jaramataia:
        // Contorna o gap no OpenStreetMap da transposição do canteiro da AL-220 no acesso oeste.
        List<LatLng> seg1 = [];
        if (idxJaramataia > 0) {
          if (isPartidaArapiracaSertao) {
            final pts1Highway = [
              _corredorSaidaArapiracaSertao.last,
              ...pontosBase.sublist(1, idxJaramataia + 1),
            ];
            final segHighway = await _requisitarOsrm(pts1Highway) ?? pts1Highway;
            seg1 = [..._corredorSaidaArapiracaSertao, ...segHighway.sublist(1)];
          } else {
            final pts1Brutos = pontosBase.sublist(0, idxJaramataia + 1);
            seg1 = await _requisitarOsrm(pts1Brutos) ?? pts1Brutos;
          }
        } else {
          seg1 = [pontosBase.first];
        }

        // Corredor viário real contínuo pela Rua do Comércio e transposição do canteiro AL-220 Oeste
        const corredorJaramataiaOeste = [
          LatLng(-9.65769, -37.00450), // Rua do Comércio (centro)
          LatLng(-9.65752, -37.00505),
          LatLng(-9.65741, -37.00545),
          LatLng(-9.65705, -37.00663),
          LatLng(-9.65685, -37.00698),
          LatLng(-9.65661, -37.00731),
          LatLng(-9.65631, -37.00754),
          LatLng(-9.65576, -37.00782),
          LatLng(-9.65487, -37.00819),
          LatLng(-9.65091, -37.01000), // Acesso Oeste Jaramataia
          LatLng(-9.65057, -37.01008), // Transposição do canteiro da AL-220
          LatLng(-9.65106, -37.01500), // AL-220 Oeste (sentido Batalha / Jacaré)
        ];

        final pts2 = [
          const LatLng(-9.65106, -37.01500),
          ...pontosBase.sublist(idxJaramataia + 1),
        ];
        final seg2 = await _requisitarOsrm(pts2) ?? pts2;

        if (mounted) {
          setState(() {
            _rotaOsrm = [
              ...seg1,
              ...corredorJaramataiaOeste.sublist(1),
              ...(seg2.length > 1 ? seg2.sublist(1) : seg2),
            ];
            _carregandoRota = false;
          });
          return;
        }
      } else {
        // Sentido leste ou rotas gerais
        List<LatLng>? rota;
        if (isChegadaArapiracaSertao) {
          final ptsHighway = [
            ...pontosBase.sublist(0, pontosBase.length - 1),
            _corredorChegadaArapiracaSertao.first,
          ];
          final segHighway = await _requisitarOsrm(ptsHighway) ?? ptsHighway;
          rota = [...segHighway, ..._corredorChegadaArapiracaSertao.sublist(1)];
        } else if (isPartidaArapiracaSertao) {
          final ptsHighway = [
            _corredorSaidaArapiracaSertao.last,
            ...pontosBase.sublist(1),
          ];
          final segHighway = await _requisitarOsrm(ptsHighway) ?? ptsHighway;
          rota = [..._corredorSaidaArapiracaSertao, ...segHighway.sublist(1)];
        } else {
          rota = await _requisitarOsrm(pontosBase);
        }

        if (rota != null && mounted) {
          final nonNullRota = rota;
          setState(() {
            _rotaOsrm = nonNullRota;
            _carregandoRota = false;
          });
          return;
        }
      }
    } catch (_) {
      // Fallback silencioso: usa linha reta se OSRM falhar
    }

    // Fallback: linha reta entre os pontos originais com coordenadas
    if (mounted) {
      setState(() {
        _rotaOsrm = pontosBase;
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
          // Centraliza a câmera diretamente no ponto selecionado com zoom nítido e equilibrado
          _mapController.move(coord, 14.5);
        }
      }
      _marcadoresCache = null; // Invalida cache ao mudar seleção
    });
  }

  @override
  Widget build(BuildContext context) {
    // Mapeia cada parada para sua coordenada canônica exata
    final paradasMapeadas = <_ParadaMapeada>[];
    for (final p in widget.paradas) {
      final coord = _resolverCoordenada(p);
      if (coord != null) {
        paradasMapeadas.add(_ParadaMapeada(parada: p, coordenada: coord));
      }
    }

    // Sem dados suficientes — fallback silencioso
    if (paradasMapeadas.length < 2) return const SizedBox.shrink();

    final pontosBase = paradasMapeadas.map((m) => m.coordenada).toList();
    final bounds = LatLngBounds.fromPoints(pontosBase);

    // Usa traçado OSRM quando disponível, senão os pontos diretos
    final pontosPolyline = _rotaOsrm.isNotEmpty ? _rotaOsrm : pontosBase;

    final hasCartoKey = AppConstants.cartoApiKey.isNotEmpty;
    // Quando houver CARTO_API_KEY, utiliza CartoDB Voyager autenticado.
    // Sem chave, utiliza OpenStreetMap Humanitarian (HOT), com CORS aberto nativo para Web e sem marca d'água "API KEY REQUIRED".
    final tileUrl = hasCartoKey
        ? 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png?key=${AppConstants.cartoApiKey}'
        : 'https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png';

    // Reutiliza marcadores cacheados se a seleção não mudou
    if (_marcadoresCache == null || _ultimaSelecao != _paradaSelecionada) {
      _marcadoresCache = _buildMarcadores(paradasMapeadas);
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
                    // Teto de zoom calibrado para máxima nitidez: evita interpolação/embaçamento
                    maxZoom: 17.5,
                    onPositionChanged: (camera, hasGesture) {
                      // Atualiza ValueNotifier — NÃO chama setState, zero rebuild no mapa
                      _rotacaoNotifier.value = camera.rotation;
                    },
                    // Zoom via scroll wheel e touchpad habilitados com sensibilidade suave
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

                    // Polylines no estilo Google Maps (casing de contraste + linha principal)
                    if (pontosPolyline.length >= 2)
                      PolylineLayer(
                        polylines: [
                          // Borda externa / Casing para contraste sobre o mapa
                          Polyline(
                            points: pontosPolyline,
                            strokeWidth: 6.5,
                            color: Colors.white.withValues(alpha: 0.95),
                          ),
                          // Linha principal do trajeto
                          Polyline(
                            points: pontosPolyline,
                            strokeWidth: 4.5,
                            color: AppColors.primary,
                          ),
                        ],
                      ),

                    // Marcadores das paradas — rotate: true mantém os nomes sempre na vertical
                    MarkerLayer(
                      rotate: true,
                      markers: _marcadoresCache!,
                    ),
                  ],
                ),

                // Controles de zoom, enquadramento e bússola estilo Google Maps
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: _ControlesMapa(
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

                // Indicador de cálculo da rota OSRM
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

                // Card flutuante de detalhes da parada selecionada
                if (_paradaSelecionada != null)
                  Positioned(
                    left: 10,
                    bottom: 10,
                    right: 56, // espaço para não sobrepor os botões de zoom
                    child: RepaintBoundary(
                      child: _CardParadaDetalhe(
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
        _LegendaMapa(
          totalParadas: paradasMapeadas.length,
          totalItinerario: widget.paradas.length,
        ),
      ],
    );
  }

  /// Constrói marcadores com ancoragem milimétrica exata sobre as coordenadas da cidade
  List<Marker> _buildMarcadores(List<_ParadaMapeada> paradasMapeadas) {
    final marcadores = <Marker>[];

    for (int i = 0; i < paradasMapeadas.length; i++) {
      final item = paradasMapeadas[i];
      final parada = item.parada;
      final coord = item.coordenada;
      final isFirst = i == 0;
      final isLast = i == paradasMapeadas.length - 1;
      final isSelected = _paradaSelecionada == parada;

      if (isFirst || isLast) {
        final corPino = isFirst ? AppColors.primary : AppColors.secondary;
        final corDot = isFirst ? const Color(0xFF16A34A) : AppColors.secondary;

        // No flutter_map, Alignment.bottomCenter posiciona o fundo do widget (ponta do pino) sobre Marker.point.
        // O _PinoTeardropPainter desenha a ponta inferior no pixel (w/2, h), garantindo exatidão zero-offset.
        marcadores.add(
          Marker(
            point: coord,
            width: 120,
            height: 60,
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _selecionarParada(parada),
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
                    painter: _PinoTeardropPainter(
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
        // Paradas intermediárias:
        // 1. Círculo com Alignment.center (o centro do círculo cai 100% exato sobre a rodovia/cidade)
        marcadores.add(
          Marker(
            point: coord,
            width: isSelected ? 18 : 14,
            height: isSelected ? 18 : 14,
            alignment: Alignment.center,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _selecionarParada(parada),
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

        // 2. Chip com nome da cidade flutuando logo acima do círculo
        marcadores.add(
          Marker(
            point: coord,
            width: 90,
            height: 24,
            // Alignment.topCenter posiciona o chip acima da coordenada com espaçamento seguro
            alignment: const Alignment(0.0, -1.9),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _selecionarParada(parada),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 1.5,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryLight : Colors.white.withValues(alpha: 0.95),
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

// ---------------------------------------------------------------------------
// Painter customizado que desenha o pino em formato de gota/agulha
// garantindo que a ponta inferior termine exatamente no pixel (w/2, h)
// ---------------------------------------------------------------------------
class _PinoTeardropPainter extends CustomPainter {
  const _PinoTeardropPainter({
    required this.cor,
    required this.corBorda,
  });

  final Color cor;
  final Color corBorda;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final r = w / 2;

    // Sombra suave sob a ponta do pino (web-safe, sem shader MaskFilter)
    final shadowPaint = Paint()
      ..color = const Color(0x33000000)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w / 2, h - 0.5), width: 8, height: 3),
      shadowPaint,
    );

    // Caminho da agulha em gota com ponta inferior exata
    final path = ui.Path();
    path.moveTo(w / 2, h); // Ponta inferior exata
    path.cubicTo(
      w * 0.15, h * 0.55,
      0, r * 1.1,
      0, r,
    );
    path.arcToPoint(
      Offset(w, r),
      radius: Radius.circular(r),
      clockwise: true,
    );
    path.cubicTo(
      w, r * 1.1,
      w * 0.85, h * 0.55,
      w / 2, h, // Fecha exatamente na ponta inferior
    );
    path.close();

    // Preenchimento
    final paintFill = Paint()
      ..color = cor
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, paintFill);

    // Borda branca de acabamento
    final paintStroke = Paint()
      ..color = corBorda
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, paintStroke);

    // Miolo central branco
    final paintDot = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w / 2, r), r * 0.38, paintDot);
  }

  @override
  bool shouldRepaint(covariant _PinoTeardropPainter oldDelegate) =>
      oldDelegate.cor != cor || oldDelegate.corBorda != corBorda;
}

// ---------------------------------------------------------------------------
// Card flutuante com detalhes da parada selecionada
// ---------------------------------------------------------------------------
class _CardParadaDetalhe extends StatelessWidget {
  const _CardParadaDetalhe({
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

// ---------------------------------------------------------------------------
// Controles flutuantes de Zoom, Recentralizar e Bússola estilo Google Maps
// ---------------------------------------------------------------------------
class _ControlesMapa extends StatelessWidget {
  const _ControlesMapa({
    required this.rotacaoNotifier,
    required this.onResetRotation,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onResetBounds,
  });

  final ValueNotifier<double> rotacaoNotifier;
  final VoidCallback onResetRotation;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onResetBounds;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Bússola estilo Google Maps — reage isoladamente via ValueListenableBuilder
        ValueListenableBuilder<double>(
          valueListenable: rotacaoNotifier,
          builder: (context, rotacao, _) {
            final estaRotacionado = rotacao.abs() > 1.5;
            if (!estaRotacionado) return const SizedBox.shrink();

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border, width: 1.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x2A000000),
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: InkWell(
                      onTap: onResetRotation,
                      borderRadius: BorderRadius.circular(8),
                      child: Tooltip(
                        message: 'Redefinir orientação para o Norte',
                        child: SizedBox(
                          width: 36,
                          height: 36,
                          child: Center(
                            child: Transform.rotate(
                              angle: -rotacao * math.pi / 180,
                              child: const Icon(
                                Icons.explore_rounded,
                                size: 22,
                                color: Color(0xFFDC2626), // Vermelho bússola Norte
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        // Botão para recentralizar / enquadrar a rota inteira
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border, width: 1.0),
            boxShadow: const [
              BoxShadow(
                color: Color(0x2A000000),
                blurRadius: 4,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: InkWell(
                onTap: onResetBounds,
                borderRadius: BorderRadius.circular(8),
                child: const Tooltip(
                  message: 'Enquadrar rota',
                  child: SizedBox(
                    width: 36,
                    height: 36,
                    child: Icon(
                      Icons.crop_free_rounded,
                      size: 20,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Agrupamento Zoom (+ e -) estilo Google Maps
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border, width: 1.0),
            boxShadow: const [
              BoxShadow(
                color: Color(0x2A000000),
                blurRadius: 4,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: InkWell(
                    onTap: onZoomIn,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                    child: const Tooltip(
                      message: 'Aproximar',
                      child: SizedBox(
                        width: 36,
                        height: 34,
                        child: Icon(
                          Icons.add_rounded,
                          size: 20,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 26,
                  height: 1.0,
                  color: AppColors.border,
                ),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: InkWell(
                    onTap: onZoomOut,
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
                    child: const Tooltip(
                      message: 'Afastar',
                      child: SizedBox(
                        width: 36,
                        height: 34,
                        child: Icon(
                          Icons.remove_rounded,
                          size: 20,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
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
