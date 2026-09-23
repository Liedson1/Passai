import 'parada_itinerario.dart';

/// Entidade de domínio: Detalhes completos de uma viagem específica.
/// Contém as informações exibidas na tela de Detalhes da Viagem,
/// incluindo código da linha, preço, rota, via e itinerário completo.
class DetalhesViagem {
  const DetalhesViagem({
    required this.codigo,
    required this.preco,
    required this.rota,
    required this.itinerario,
    this.via,
    this.horaSaida,
    this.tipoLinha,
  });

  /// Código identificador da linha (ex: "AL-042")
  final String codigo;

  /// Tarifa da viagem (ex: "R$ 18,00")
  final String preco;

  /// Nome da rota exibido (ex: "Delmiro Gouveia x Piranhas")
  final String rota;

  /// Paradas do itinerário em ordem cronológica
  final List<ParadaItinerario> itinerario;

  /// Trajeto intermediário, quando houver (ex: "Via Água Branca e Olho d'Água do Casado")
  final String? via;

  /// Horário de saída formatado (ex: "13:30")
  final String? horaSaida;

  /// Tipo da linha (ex: "Linha Intermunicipal")
  final String? tipoLinha;

  /// Primeira parada do itinerário (partida)
  ParadaItinerario? get partida =>
      itinerario.isNotEmpty ? itinerario.first : null;

  /// Última parada do itinerário (chegada)
  ParadaItinerario? get chegada =>
      itinerario.length > 1 ? itinerario.last : null;
}
