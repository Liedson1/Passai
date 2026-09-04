import 'package:passai/domain/entities/alteracao.dart';

/// Modelo de dados da camada de dados para [Alteracao].
/// Mapeia a resposta JSON do Supabase para a entidade de domínio.
class AlteracaoModel {
  const AlteracaoModel({
    required this.id,
    required this.horaOriginal,
    required this.horaNova,
    this.vanOriginal,
    this.vanSubstituta,
    this.motivo,
  });

  final int id;
  final String horaOriginal;
  final String horaNova;
  final String? vanOriginal;
  final String? vanSubstituta;
  final String? motivo;

  factory AlteracaoModel.fromJson(Map<String, dynamic> json) {
    final rawOrig = json['hora_original'] as String? ?? '';
    final rawNova = json['hora_nova'] as String? ?? '';

    return AlteracaoModel(
      id: json['id'] as int,
      horaOriginal: rawOrig.length >= 5 ? rawOrig.substring(0, 5) : rawOrig,
      horaNova: rawNova.length >= 5 ? rawNova.substring(0, 5) : rawNova,
      vanOriginal: json['van_original'] as String?,
      vanSubstituta: json['van_substituta'] as String?,
      motivo: json['motivo'] as String?,
    );
  }

  /// Converte para entidade de domínio
  Alteracao toEntity() {
    return Alteracao(
      id: id,
      horaOriginal: horaOriginal,
      horaNova: horaNova,
      vanOriginal: vanOriginal,
      vanSubstituta: vanSubstituta,
      motivo: motivo,
    );
  }
}
