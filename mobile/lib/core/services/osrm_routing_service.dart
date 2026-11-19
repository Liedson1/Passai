import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

/// Serviço desacoplado responsável por consultar rotas reais de direção via OSRM,
/// contornar gaps conhecidos na malha viária de Alagoas e decodificar geometrias geográficas.
class OsrmRoutingService {
  OsrmRoutingService._();

  static const String _osrmBaseUrl = 'https://router.project-osrm.org/route/v1/driving';

  // Cache em memória para evitar requisições idênticas repetidas
  static final Map<String, List<LatLng>> _rotaCache = {};

  /// Corredor real da van saindo do Ponto das Vans em Arapiraca rumo ao Sertão pela AL-220
  static const List<LatLng> corredorSaidaArapiracaSertao = [
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

  /// Corredor real da van chegando a Arapiraca vindo do Sertão pela AL-220
  static const List<LatLng> corredorChegadaArapiracaSertao = [
    LatLng(-9.727847, -36.669550),   // Semáforo da Igrejinha na AL-220
    LatLng(-9.728688, -36.669295),   // Avenida Benjamin Freire de Amorim
    LatLng(-9.731144, -36.668585),   // Avenida Benjamin Freire de Amorim
    LatLng(-9.734559, -36.667609),   // Avenida Benjamin Freire de Amorim
    LatLng(-9.737329, -36.666835),   // Avenida Benjamin Freire de Amorim
    LatLng(-9.738971, -36.666371),   // Avenida Benjamin Freire de Amorim
    LatLng(-9.739618, -36.666194),   // Avenida Benjamin Freire de Amorim
    LatLng(-9.740782, -36.665867),   // Avenida Benjamin Freire
    LatLng(-9.741552, -36.665629),   // Avenida Benjamin Freire
    LatLng(-9.741764, -36.665582),   // Início da Rua Maurício Pereira
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

  /// Corredor viário real contínuo pela Rua do Comércio e transposição do canteiro AL-220 Oeste em Jaramataia
  static const List<LatLng> corredorJaramataiaOeste = [
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

  static bool isArapiraca(LatLng p) =>
      (p.latitude - (-9.75)).abs() < 0.05 && (p.longitude - (-36.66)).abs() < 0.05;

  static bool isOlhoDagua(LatLng p) =>
      (p.latitude - (-9.53)).abs() < 0.05 && (p.longitude - (-37.29)).abs() < 0.05;

  /// Detecta se a rota inclui travessia de Jaramataia no sentido Oeste
  static int indiceJaramataiaWestbound(List<LatLng> pontos) {
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

  /// Requisita o traçado OSRM para uma sequência de pontos geográficos usando GeoJSON
  static Future<List<LatLng>?> requisitarOsrm(List<LatLng> pontos) async {
    if (pontos.length < 2) return pontos;
    final coords = pontos.map((p) => '${p.longitude},${p.latitude}').join(';');
    final uri = Uri.parse('$_osrmBaseUrl/$coords?overview=full&geometries=geojson');

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
            return decodePolyline(geometry);
          }
        }
      }
    } catch (_) {}
    return null;
  }

  /// Busca a rota completa contornando trechos críticos da malha estadual
  static Future<List<LatLng>> buscarRotaCompleta(List<LatLng> pontosBase) async {
    if (pontosBase.length < 2) return pontosBase;

    final cacheKey = pontosBase.map((p) => '${p.latitude.toStringAsFixed(4)},${p.longitude.toStringAsFixed(4)}').join(';');
    if (_rotaCache.containsKey(cacheKey)) {
      return _rotaCache[cacheKey]!;
    }

    try {
      final idxJaramataia = indiceJaramataiaWestbound(pontosBase);
      final isPartidaArapiracaSertao =
          isArapiraca(pontosBase.first) && pontosBase[1].longitude < -36.7;
      final isChegadaArapiracaSertao =
          isArapiraca(pontosBase.last) && pontosBase[pontosBase.length - 2].longitude < -36.7;

      List<LatLng>? resultado;

      if (idxJaramataia >= 0) {
        List<LatLng> seg1 = [];
        if (idxJaramataia > 0) {
          if (isPartidaArapiracaSertao) {
            final pts1Highway = [
              corredorSaidaArapiracaSertao.last,
              ...pontosBase.sublist(1, idxJaramataia + 1),
            ];
            final segHighway = await requisitarOsrm(pts1Highway) ?? pts1Highway;
            seg1 = [...corredorSaidaArapiracaSertao, ...segHighway.sublist(1)];
          } else {
            final pts1Brutos = pontosBase.sublist(0, idxJaramataia + 1);
            seg1 = await requisitarOsrm(pts1Brutos) ?? pts1Brutos;
          }
        } else {
          seg1 = [pontosBase.first];
        }

        final pts2 = [
          const LatLng(-9.65106, -37.01500),
          ...pontosBase.sublist(idxJaramataia + 1),
        ];
        final seg2 = await requisitarOsrm(pts2) ?? pts2;

        resultado = [
          ...seg1,
          ...corredorJaramataiaOeste.sublist(1),
          ...(seg2.length > 1 ? seg2.sublist(1) : seg2),
        ];
      } else {
        if (isChegadaArapiracaSertao) {
          final ptsHighway = [
            ...pontosBase.sublist(0, pontosBase.length - 1),
            corredorChegadaArapiracaSertao.first,
          ];
          final segHighway = await requisitarOsrm(ptsHighway) ?? ptsHighway;
          resultado = [...segHighway, ...corredorChegadaArapiracaSertao.sublist(1)];
        } else if (isPartidaArapiracaSertao) {
          final ptsHighway = [
            corredorSaidaArapiracaSertao.last,
            ...pontosBase.sublist(1),
          ];
          final segHighway = await requisitarOsrm(ptsHighway) ?? ptsHighway;
          resultado = [...corredorSaidaArapiracaSertao, ...segHighway.sublist(1)];
        } else {
          resultado = await requisitarOsrm(pontosBase);
        }
      }

      if (resultado != null && resultado.isNotEmpty) {
        _rotaCache[cacheKey] = resultado;
        return resultado;
      }
    } catch (_) {}

    return pontosBase;
  }

  /// Decodifica polylines de forma aritmeticamente segura no Dart e Dart2JS (Web)
  static List<LatLng> decodePolyline(String encoded) {
    final points = <LatLng>[];
    int index = 0;
    final len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b;
      int shift = 0;
      int result = 0;
      do {
        if (index >= len) break;
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      final dlat = ((result & 1) != 0 ? -((result >> 1) + 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        if (index >= len) break;
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      final dlng = ((result & 1) != 0 ? -((result >> 1) + 1) : (result >> 1));
      lng += dlng;

      final latitude = lat / 1E5;
      final longitude = lng / 1E5;

      if (latitude.abs() <= 90.0 && longitude.abs() <= 180.0) {
        points.add(LatLng(latitude, longitude));
      }
    }

    return points;
  }
}
