import 'horario.dart';

/// Agrupamento dos resultados de busca para uma rota + data.
/// Encapsula todos os dados necessários para a tela de resultados.
class ResultadoBusca {
  const ResultadoBusca({
    required this.origem,
    required this.destino,
    required this.dataSelecionada,
    required this.horarios,
    this.linha,
  });

  /// Cidade de origem da rota
  final String origem;

  /// Cidade de destino da rota
  final String destino;

  /// Data selecionada pelo passageiro
  final DateTime dataSelecionada;

  /// Horários disponíveis para esta rota e data
  final List<Horario> horarios;

  /// Código da linha (ex: "42")
  final String? linha;
}
