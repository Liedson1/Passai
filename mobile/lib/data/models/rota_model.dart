import 'package:passai/domain/entities/rota.dart';

/// Modelo de dados para [Rota], mapeando resposta JSON do Supabase.
/// O join com a tabela cidades é feito na query do datasource.
class RotaModel {
  const RotaModel({
    required this.id,
    required this.linha,
    required this.origem,
    required this.destino,
    required this.diasOperacao,
    this.distanciaKm,
    this.tarifa,
  });

  final int id;
  final String linha;
  final String origem;
  final String destino;
  final String diasOperacao;
  final int? distanciaKm;
  final double? tarifa;

  factory RotaModel.fromJson(Map<String, dynamic> json) {
    final origemMap = json['origem'] ?? json['origem_cidade'];
    final origemNome = origemMap is Map<String, dynamic>
        ? (origemMap['nome'] as String? ?? '')
        : (origemMap?.toString() ?? '');

    final destinoMap = json['destino'] ?? json['destino_cidade'];
    final destinoNome = destinoMap is Map<String, dynamic>
        ? (destinoMap['nome'] as String? ?? '')
        : (destinoMap?.toString() ?? '');

    final linha = json['linha'] as String? ?? 'Linha ${json['id']}';
    final diasOperacao = json['dias_operacao'] as String? ?? 'Segunda a Domingo';

    return RotaModel(
      id: json['id'] as int,
      linha: linha,
      origem: origemNome,
      destino: destinoNome,
      diasOperacao: diasOperacao,
      distanciaKm: json['distancia_km'] as int?,
      tarifa: (json['tarifa'] as num?)?.toDouble(),
    );
  }

  /// Converte para entidade de domínio
  Rota toEntity() {
    return Rota(
      id: id,
      linha: linha,
      origem: origem,
      destino: destino,
      diasOperacao: diasOperacao,
      distanciaKm: distanciaKm,
      tarifa: tarifa,
    );
  }
}
