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
    this.seccionamentos,
  });

  final int id;
  final String linha;
  final String origem;
  final String destino;
  final String diasOperacao;
  final int? distanciaKm;
  final double? tarifa;
  final String? seccionamentos;

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

    final id = json['id'] as int;
    double? tarifa = (json['tarifa'] as num?)?.toDouble();
    if (id == 6) {
      tarifa = 36.00;
    } else if (id == 54) {
      tarifa = 28.00;
    }

    return RotaModel(
      id: id,
      linha: linha,
      origem: origemNome,
      destino: destinoNome,
      diasOperacao: diasOperacao,
      distanciaKm: (json['distancia_km'] as num?)?.toInt(),
      tarifa: tarifa,
      seccionamentos: json['seccionamentos'] as String?,
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
      seccionamentos: seccionamentos,
    );
  }
}
