import 'package:passai/domain/entities/parada_itinerario.dart';

/// Modelo de dados para [ParadaItinerario], mapeando resposta JSON do Supabase.
/// A query deve incluir o JOIN com `cidades` para trazer latitude e longitude.
class ParadaRotaModel {
  const ParadaRotaModel({
    required this.id,
    required this.rotaId,
    required this.sentido,
    required this.ordem,
    required this.cidade,
    this.descricao,
    this.latitude,
    this.longitude,
  });

  final int id;
  final int rotaId;
  final String sentido;
  final int ordem;
  final String cidade;
  final String? descricao;

  /// Latitude da cidade (via JOIN com a tabela `cidades`)
  final double? latitude;

  /// Longitude da cidade (via JOIN com a tabela `cidades`)
  final double? longitude;

  factory ParadaRotaModel.fromJson(Map<String, dynamic> json) {
    // Supabase retorna o JOIN como objeto aninhado: { ..., cidade_info: { latitude, longitude } }
    // ou diretamente no nível raiz quando selecionado com alias flat
    final cidadeInfo = json['cidade_info'] as Map<String, dynamic>?;

    return ParadaRotaModel(
      id: json['id'] as int,
      rotaId: json['rota_id'] as int,
      sentido: json['sentido'] as String,
      ordem: json['ordem'] as int,
      cidade: json['cidade'] as String,
      descricao: json['descricao'] as String?,
      latitude: (cidadeInfo?['latitude'] as num?)?.toDouble() ??
          (json['latitude'] as num?)?.toDouble(),
      longitude: (cidadeInfo?['longitude'] as num?)?.toDouble() ??
          (json['longitude'] as num?)?.toDouble(),
    );
  }

  /// Converte para entidade de domínio
  ParadaItinerario toEntity() {
    return ParadaItinerario(
      parada: cidade,
      horario: '',   // horário preenchido pela camada de apresentação
      descricao: descricao,
      latitude: latitude,
      longitude: longitude,
    );
  }
}

