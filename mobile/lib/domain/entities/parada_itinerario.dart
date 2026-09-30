/// Entidade de domínio: Parada dentro do itinerário de uma viagem
class ParadaItinerario {
  const ParadaItinerario({
    required this.parada,
    required this.horario,
    this.descricao,
    this.tipo,
    this.tags = const [],
    this.observacao,
    this.latitude,
    this.longitude,
  });

  /// Nome do local / cidade (ex: "Arapiraca", "Jaramataia")
  final String parada;

  /// Horário previsto na parada (ex: "05:15", "05:55")
  final String horario;

  /// Ponto de referência / descrição (ex: "Terminal Rodoviário • Ponto de Partida")
  final String? descricao;

  /// Tipo de parada no itinerário: 'origem', 'intermediaria', 'destino'
  final String? tipo;

  /// Tags ou características do ponto (ex: ["Plataforma 03", "Ponto coberto"])
  final List<String> tags;

  /// Observação de apoio (ex: "Embarque e desembarque rápido")
  final String? observacao;

  /// Latitude geográfica da cidade/parada (vinda da tabela `cidades`)
  final double? latitude;

  /// Longitude geográfica da cidade/parada (vinda da tabela `cidades`)
  final double? longitude;

  /// Indica se esta parada possui coordenadas geográficas cadastradas
  bool get temCoordenadas => latitude != null && longitude != null;

  /// Cria uma instância a partir de um Map JSON
  factory ParadaItinerario.fromJson(Map<String, dynamic> json) {
    return ParadaItinerario(
      parada: (json['parada'] ?? json['cidade'] ?? json['local'] ?? '') as String,
      horario: (json['horario'] ?? json['horarioPrevisto'] ?? '') as String,
      descricao: (json['descricao'] ?? json['ponto']) as String?,
      tipo: json['tipo'] as String?,
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      observacao: json['observacao'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  /// Converte a instância para um Map JSON
  Map<String, dynamic> toJson() => {
        'parada': parada,
        'horario': horario,
        if (descricao != null) 'descricao': descricao,
        if (tipo != null) 'tipo': tipo,
        'tags': tags,
        if (observacao != null) 'observacao': observacao,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      };

  /// Cria uma cópia com campos sobrescritos
  ParadaItinerario copyWith({
    String? parada,
    String? horario,
    String? descricao,
    String? tipo,
    List<String>? tags,
    String? observacao,
    double? latitude,
    double? longitude,
  }) {
    return ParadaItinerario(
      parada: parada ?? this.parada,
      horario: horario ?? this.horario,
      descricao: descricao ?? this.descricao,
      tipo: tipo ?? this.tipo,
      tags: tags ?? this.tags,
      observacao: observacao ?? this.observacao,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}

