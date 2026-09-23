import 'package:passai/domain/entities/parada_itinerario.dart';

/// Modelo de dados para [ParadaItinerario], mapeando resposta JSON do Supabase.
class ParadaRotaModel {
  const ParadaRotaModel({
    required this.id,
    required this.rotaId,
    required this.sentido,
    required this.ordem,
    required this.cidade,
    this.descricao,
  });

  final int id;
  final int rotaId;
  final String sentido;
  final int ordem;
  final String cidade;
  final String? descricao;

  factory ParadaRotaModel.fromJson(Map<String, dynamic> json) {
    return ParadaRotaModel(
      id: json['id'] as int,
      rotaId: json['rota_id'] as int,
      sentido: json['sentido'] as String,
      ordem: json['ordem'] as int,
      cidade: json['cidade'] as String,
      descricao: json['descricao'] as String?,
    );
  }

  /// Converte para entidade de domínio
  ParadaItinerario toEntity() {
    return ParadaItinerario(
      parada: cidade,
      horario: '',   // horário preenchido pela camada de apresentação
      descricao: descricao,
    );
  }
}
