import 'package:passai/data/models/alteracao_model.dart';
import 'package:passai/domain/entities/horario.dart';

/// Modelo de dados para [Horario], mapeando resposta JSON do Supabase.
class HorarioModel {
  const HorarioModel({
    required this.id,
    required this.hora,
    required this.sentido,
    this.alteracao,
  });

  final int id;
  final String hora;
  final String sentido;
  final AlteracaoModel? alteracao;

  factory HorarioModel.fromJson(Map<String, dynamic> json) {
    // Horário exibido: hora_nova se houver alteração ativa, senão hora original
    final alteracaoJson = json['alteracoes_horario'] as List?;
    AlteracaoModel? alteracaoModel;

    if (alteracaoJson != null && alteracaoJson.isNotEmpty) {
      final ativas = alteracaoJson
          .whereType<Map<String, dynamic>>()
          .where((a) => a['ativa'] != false)
          .toList();
      if (ativas.isNotEmpty) {
        alteracaoModel = AlteracaoModel.fromJson(ativas.first);
      }
    }

    final rawHora = json['hora'] as String? ?? '';
    final horaRaw = rawHora.length >= 5 ? rawHora.substring(0, 5) : rawHora;

    return HorarioModel(
      id: json['id'] as int,
      hora: alteracaoModel?.horaNova ?? horaRaw,
      sentido: json['sentido'] as String? ?? 'IDA',
      alteracao: alteracaoModel,
    );
  }

  /// Converte para entidade de domínio
  Horario toEntity() {
    return Horario(
      id: id,
      hora: hora,
      sentido: sentido == 'IDA' ? Sentido.ida : Sentido.volta,
      alteracao: alteracao?.toEntity(),
    );
  }
}
