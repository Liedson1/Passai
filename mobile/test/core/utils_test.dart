import 'package:flutter_test/flutter_test.dart';
import 'package:passai/core/utils/duracao_estimativa.dart';
import 'package:passai/core/utils/filtro_periodo_utils.dart';
import 'package:passai/core/utils/itinerario_helper.dart';
import 'package:passai/core/utils/text_normalizer.dart';
import 'package:passai/domain/entities/horario.dart';

void main() {
  group('DuracaoEstimativa Tests', () {
    test('Retorna null quando distanciaKm for nulo', () {
      expect(DuracaoEstimativa.estimar(null), isNull);
    });

    test('Retorna formato em minutos quando duracao for menor que 60 min', () {
      expect(DuracaoEstimativa.estimar(45), '45 min');
      expect(DuracaoEstimativa.estimar(15), '15 min');
    });

    test('Retorna formato horas exatas quando duracao for multiplo de 60', () {
      expect(DuracaoEstimativa.estimar(60), '1h');
      expect(DuracaoEstimativa.estimar(120), '2h');
    });

    test('Retorna formato horas e minutos quando duracao exceder 60 min', () {
      expect(DuracaoEstimativa.estimar(90), '1h 30min');
      expect(DuracaoEstimativa.estimar(125), '2h 5min');
    });
  });

  group('TextNormalizer Tests', () {
    test('Remove acentos e caracteres especiais', () {
      expect(TextNormalizer.normalizar('ÁGUA BRANCA'), 'agua branca');
      expect(TextNormalizer.normalizar('Maceió'), 'maceio');
      expect(TextNormalizer.normalizar('Pão de Açúcar'), 'pao de acucar');
      expect(TextNormalizer.normalizar('São José da Tapera'), 'sao jose da tapera');
    });

    test('Remove apostrofos e crases', () {
      expect(TextNormalizer.normalizar("Olho d'Água do Casado"), 'olho dagua do casado');
      expect(TextNormalizer.normalizar("Olho d`Água"), 'olho dagua');
    });

    test('Remove espacos extras e faz trim', () {
      expect(TextNormalizer.normalizar('  Delmiro   Gouveia  '), 'delmiro gouveia');
    });
  });

  group('FiltroPeriodoUtils Tests', () {
    final horarios = [
      const Horario(id: 1, hora: '06:30', sentido: Sentido.ida),
      const Horario(id: 2, hora: '11:45', sentido: Sentido.ida),
      const Horario(id: 3, hora: '12:00', sentido: Sentido.ida),
      const Horario(id: 4, hora: '15:20', sentido: Sentido.ida),
      const Horario(id: 5, hora: '18:00', sentido: Sentido.ida),
      const Horario(id: 6, hora: '21:15', sentido: Sentido.ida),
    ];

    test('Filtro todos retorna a lista completa', () {
      final res = FiltroPeriodoUtils.filtrar(horarios, FiltroPeriodo.todos);
      expect(res.length, 6);
    });

    test('Filtro manha retorna apenas horarios antes de 12:00', () {
      final res = FiltroPeriodoUtils.filtrar(horarios, FiltroPeriodo.manha);
      expect(res.map((h) => h.hora).toList(), ['06:30', '11:45']);
    });

    test('Filtro tarde retorna apenas horarios entre 12:00 e 17:59', () {
      final res = FiltroPeriodoUtils.filtrar(horarios, FiltroPeriodo.tarde);
      expect(res.map((h) => h.hora).toList(), ['12:00', '15:20']);
    });

    test('Filtro noite retorna apenas horarios a partir de 18:00', () {
      final res = FiltroPeriodoUtils.filtrar(horarios, FiltroPeriodo.noite);
      expect(res.map((h) => h.hora).toList(), ['18:00', '21:15']);
    });

    test('Horario com formato inesperado nao quebra o filtro', () {
      final malformados = [
        const Horario(id: 99, hora: 'invalido', sentido: Sentido.ida),
      ];
      final res = FiltroPeriodoUtils.filtrar(malformados, FiltroPeriodo.manha);
      expect(res.length, 1);
    });
  });

  group('ItinerarioHelper Tests', () {
    test('Cria itinerario de IDA com paradas intermediarias (Olho d\'Agua -> Jacare -> Jaramataia -> Arapiraca)', () {
      final itinerario = ItinerarioHelper.criarItinerarioFallback(
        origem: "Olho d'Água das Flores",
        destino: 'Arapiraca',
        rotaId: 54,
      );

      expect(itinerario.length, 4);
      expect(itinerario[0].parada, "Olho d'Água das Flores");
      expect(itinerario[0].tipo, 'origem');
      expect(itinerario[0].temCoordenadas, isTrue);

      expect(itinerario[1].parada, 'Jacaré dos Homens');
      expect(itinerario[1].tipo, 'intermediaria');
      expect(itinerario[1].temCoordenadas, isTrue);

      expect(itinerario[2].parada, 'Jaramataia');
      expect(itinerario[2].tipo, 'intermediaria');
      expect(itinerario[2].temCoordenadas, isTrue);

      expect(itinerario[3].parada, 'Arapiraca');
      expect(itinerario[3].tipo, 'destino');
      expect(itinerario[3].temCoordenadas, isTrue);
    });

    test('Cria itinerario de VOLTA com paradas intermediarias (Arapiraca -> Jaramataia -> Jacare -> Olho d\'Agua)', () {
      final itinerario = ItinerarioHelper.criarItinerarioFallback(
        origem: 'Arapiraca',
        destino: "Olho d'Água das Flores",
        rotaId: 54,
      );

      expect(itinerario.length, 4);
      expect(itinerario[0].parada, 'Arapiraca');
      expect(itinerario[0].tipo, 'origem');
      expect(itinerario[0].latitude, equals(-9.7495158));
      expect(itinerario[0].longitude, equals(-36.6666349));

      expect(itinerario[1].parada, 'Jaramataia');
      expect(itinerario[1].tipo, 'intermediaria');

      expect(itinerario[2].parada, 'Jacaré dos Homens');
      expect(itinerario[2].tipo, 'intermediaria');

      expect(itinerario[3].parada, "Olho d'Água das Flores");
      expect(itinerario[3].tipo, 'destino');
    });
  });
}
