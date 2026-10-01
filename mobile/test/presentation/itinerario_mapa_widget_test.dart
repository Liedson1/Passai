import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passai/core/constants/coordenadas_cidades.dart';
import 'package:passai/domain/entities/parada_itinerario.dart';
import 'package:passai/presentation/widgets/itinerario_mapa_widget.dart';

// 1x1 transparent PNG bytes
final Uint8List _transparentPng = Uint8List.fromList([
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
  0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
  0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
]);

class _MockHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _FakeHttpClient();
  }
}

class _FakeHttpClient implements HttpClient {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _FakeHttpClientRequest();

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async => _FakeHttpClientRequest();
}

class _FakeHttpClientRequest implements HttpClientRequest {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #close || invocation.memberName == #done) {
      return Future.value(_FakeHttpClientResponse());
    }
    if (invocation.memberName == #flush || invocation.memberName == #addStream) {
      return Future<void>.value();
    }
    return null;
  }

  @override
  HttpHeaders get headers => _FakeHttpHeaders();

  @override
  Future<HttpClientResponse> close() async => _FakeHttpClientResponse();

  @override
  Future<HttpClientResponse> get done async => _FakeHttpClientResponse();
}

class _FakeHttpHeaders implements HttpHeaders {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;

  @override
  ContentType? get contentType => ContentType.parse('image/png');
}

class _FakeHttpClientResponse extends Stream<List<int>> implements HttpClientResponse {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;

  @override
  bool get isRedirect => false;

  @override
  bool get persistentConnection => false;

  @override
  int get statusCode => HttpStatus.ok;

  @override
  int get contentLength => _transparentPng.length;

  @override
  String get reasonPhrase => 'OK';

  @override
  List<RedirectInfo> get redirects => const [];

  @override
  List<Cookie> get cookies => const [];

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  HttpHeaders get headers => _FakeHttpHeaders();

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.fromIterable([_transparentPng]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}

void main() {
  setUpAll(() {
    HttpOverrides.global = _MockHttpOverrides();
  });

  tearDownAll(() {
    HttpOverrides.global = null;
  });

  group('ItinerarioMapaWidget Tests', () {
    const paradasComCoordenadas = [
      ParadaItinerario(
        parada: 'Arapiraca',
        horario: '06:00',
        descricao: 'Terminal Rodoviário',
        tipo: 'origem',
        latitude: -9.7547,
        longitude: -36.6617,
      ),
      ParadaItinerario(
        parada: 'Batalha',
        horario: '06:50',
        descricao: 'Praça Central',
        tipo: 'intermediaria',
        latitude: -9.8469,
        longitude: -36.9536,
      ),
      ParadaItinerario(
        parada: 'Delmiro Gouveia',
        horario: '08:30',
        descricao: 'Terminal de Chegada',
        tipo: 'destino',
        latitude: -9.3878,
        longitude: -37.9997,
      ),
    ];

    testWidgets('Deve renderizar os marcadores com os nomes das cidades', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ItinerarioMapaWidget(paradas: paradasComCoordenadas),
          ),
        ),
      );

      await tester.pump();

      // Nomes das cidades devem estar presentes nos marcadores
      expect(find.text('Arapiraca'), findsOneWidget);
      expect(find.text('Batalha'), findsOneWidget);
      expect(find.text('Delmiro Gouveia'), findsOneWidget);

      // Controles de zoom (+, -) e recentralizar
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);
      expect(find.byIcon(Icons.remove_rounded), findsOneWidget);
      expect(find.byIcon(Icons.crop_free_rounded), findsOneWidget);
    });

    testWidgets('Deve exibir card de detalhes ao tocar no marcador de uma cidade', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ItinerarioMapaWidget(paradas: paradasComCoordenadas),
          ),
        ),
      );

      await tester.pump();

      // Toca no marcador da cidade de Arapiraca
      await tester.tap(find.text('Arapiraca'));
      await tester.pump();

      // Card de detalhe deve aparecer com a descrição
      expect(find.text('Terminal Rodoviário'), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);

      // Fecha o card
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pump();

      expect(find.text('Terminal Rodoviário'), findsNothing);
    });

    testWidgets('Retorna SizedBox.shrink se menos de 2 paradas tiverem coordenadas', (tester) async {
      const paradasSemCoordenadas = [
        ParadaItinerario(
          parada: 'Localidade Sem Mapa A',
          horario: '06:00',
        ),
        ParadaItinerario(
          parada: 'Localidade Sem Mapa B',
          horario: '08:24',
        ),
      ];

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ItinerarioMapaWidget(paradas: paradasSemCoordenadas),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(ItinerarioMapaWidget), findsOneWidget);
      expect(find.text('Localidade Sem Mapa A'), findsNothing);
      expect(find.byIcon(Icons.add_rounded), findsNothing);
    });

    test('CoordenadasCidades deve retornar coordenadas oficiais precisas para as cidades de Alagoas', () {
      final batalha = CoordenadasCidades.obter('Batalha');
      expect(batalha, isNotNull);
      expect(batalha!.latitude, closeTo(-9.6734, 0.05));
      expect(batalha.longitude, closeTo(-37.1265, 0.05));

      final olivenca = CoordenadasCidades.obter('Olivença');
      expect(olivenca, isNotNull);
      expect(olivenca!.latitude, closeTo(-9.5191, 0.05));
      expect(olivenca.longitude, closeTo(-37.1893, 0.05));

      final ouroBranco = CoordenadasCidades.obter('Ouro Branco');
      expect(ouroBranco, isNotNull);
      expect(ouroBranco!.latitude, closeTo(-9.1623, 0.05));
      expect(ouroBranco.longitude, closeTo(-37.3583, 0.05));

      final arapiraca = CoordenadasCidades.obter('Arapiraca');
      expect(arapiraca, isNotNull);
      expect(arapiraca!.latitude, equals(-9.7495158));
      expect(arapiraca.longitude, equals(-36.6666349));

      final olhoDagua = CoordenadasCidades.obter("Olho d'Água das Flores");
      expect(olhoDagua, isNotNull);
      expect(olhoDagua!.latitude, equals(-9.536204));
      expect(olhoDagua.longitude, equals(-37.293985));

      final jaramataia = CoordenadasCidades.obter('Jaramataia');
      expect(jaramataia, isNotNull);
      expect(jaramataia!.latitude, equals(-9.65769));
      expect(jaramataia.longitude, equals(-37.00450));
    });

    testWidgets('Deve renderizar rota no sentido oeste passando por Jaramataia', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      const paradasVolta = [
        ParadaItinerario(
          parada: 'Arapiraca',
          horario: '14:00',
          descricao: 'Após o Campo do ASA',
          tipo: 'origem',
        ),
        ParadaItinerario(
          parada: 'Jaramataia',
          horario: '14:45',
          descricao: 'Rua do Comércio',
          tipo: 'intermediaria',
        ),
        ParadaItinerario(
          parada: 'Jacaré dos Homens',
          horario: '15:10',
          descricao: 'Rua Monsenhor Freitas Machado',
          tipo: 'intermediaria',
        ),
        ParadaItinerario(
          parada: "Olho d'Água das Flores",
          horario: '15:35',
          descricao: 'Igreja Matriz',
          tipo: 'destino',
        ),
      ];

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ItinerarioMapaWidget(paradas: paradasVolta),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Arapiraca'), findsOneWidget);
      expect(find.text('Jaramataia'), findsOneWidget);
      expect(find.text('Jacaré dos Homens'), findsOneWidget);
      expect(find.text("Olho d'Água das Flores"), findsOneWidget);
    });
  });
}
