/// Entidade de domínio: Parada dentro do itinerário de uma viagem
class ParadaItinerario {
  const ParadaItinerario({
    required this.parada,
    required this.horario,
    this.descricao,
  });

  /// Nome da parada (ex: "Delmiro Gouveia (Rodoviária)")
  final String parada;

  /// Horário previsto na parada (ex: "13:30") — vazio quando não disponível
  final String horario;

  /// Informação adicional sobre a parada (ex: "Partida plataforma 2")
  final String? descricao;

  /// Cria uma cópia com campos sobrescritos
  ParadaItinerario copyWith({
    String? parada,
    String? horario,
    String? descricao,
  }) {
    return ParadaItinerario(
      parada: parada ?? this.parada,
      horario: horario ?? this.horario,
      descricao: descricao ?? this.descricao,
    );
  }
}
