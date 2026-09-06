import 'package:passai/data/models/alteracao_model.dart';
import 'package:passai/domain/entities/horario.dart';

/// Modelo de dados para [Horario], mapeando resposta JSON do Supabase.
class HorarioModel {
  const HorarioModel({
    required this.id,
    required this.hora,
    required this.sentido,
    this.alteracao,
    this.preco,
    this.duracao,
    this.paradas,
    this.nomeRota,
    this.diasFuncionamento = 'Diariamente (Segunda a Domingo)',
  });

  final int id;
  final String hora;
  final String sentido;
  final String diasFuncionamento;
  final AlteracaoModel? alteracao;
  final double? preco;
  final String? duracao;
  final String? paradas;
  final String? nomeRota;

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
    final diasFunc = json['dias_funcionamento'] as String? ?? 'Diariamente (Segunda a Domingo)';

    final rotaMap = json['rotas'] as Map<String, dynamic>?;
    String? nomeRota = json['nome_rota'] as String?;
    double? preco = (json['preco'] as num?)?.toDouble();
    String? duracao = json['duracao'] as String?;
    String? paradas = json['paradas'] as String?;

    if (rotaMap != null) {
      final origMap = rotaMap['origem'] as Map<String, dynamic>?;
      final destMap = rotaMap['destino'] as Map<String, dynamic>?;
      final orig = origMap?['nome'] as String? ?? '';
      final dest = destMap?['nome'] as String? ?? '';
      final sentido = json['sentido'] as String? ?? 'IDA';
      final linhaStr = rotaMap['linha'] as String? ?? '';
      final matchVia = RegExp(r'\(\s*(via\s+[^)]+)\)', caseSensitive: false).firstMatch(linhaStr);
      final viaStr = matchVia != null ? ' (${matchVia.group(1)!.trim()})' : '';
      if (orig.isNotEmpty && dest.isNotEmpty) {
        final base = sentido == 'IDA' ? '$orig x $dest' : '$dest x $orig';
        nomeRota ??= '$base$viaStr';
      }
      preco ??= (rotaMap['tarifa'] as num?)?.toDouble();
      final dist = (rotaMap['distancia_km'] as num?)?.toInt();
      if (dist != null && duracao == null) {
        duracao = '${(dist * 0.9).round()} min';
      }
      final secc = rotaMap['seccionamentos'] as String?;
      if (secc != null && secc.trim().isNotEmpty) {
        paradas ??= 'Com paradas';
      } else {
        paradas ??= 'Direto';
      }
    }

    return HorarioModel(
      id: json['id'] as int,
      hora: alteracaoModel?.horaNova ?? horaRaw,
      sentido: json['sentido'] as String? ?? 'IDA',
      diasFuncionamento: diasFunc,
      alteracao: alteracaoModel,
      preco: preco,
      duracao: duracao,
      paradas: paradas,
      nomeRota: nomeRota,
    );
  }

  /// Converte para entidade de domínio
  Horario toEntity() {
    return Horario(
      id: id,
      hora: hora,
      sentido: sentido == 'IDA' ? Sentido.ida : Sentido.volta,
      diasFuncionamento: diasFuncionamento,
      alteracao: alteracao?.toEntity(),
      preco: preco,
      duracao: duracao,
      paradas: paradas,
      nomeRota: nomeRota,
    );
  }

  HorarioModel copyWith({
    int? id,
    String? hora,
    String? sentido,
    String? diasFuncionamento,
    AlteracaoModel? alteracao,
    double? preco,
    String? duracao,
    String? paradas,
    String? nomeRota,
  }) {
    return HorarioModel(
      id: id ?? this.id,
      hora: hora ?? this.hora,
      sentido: sentido ?? this.sentido,
      diasFuncionamento: diasFuncionamento ?? this.diasFuncionamento,
      alteracao: alteracao ?? this.alteracao,
      preco: preco ?? this.preco,
      duracao: duracao ?? this.duracao,
      paradas: paradas ?? this.paradas,
      nomeRota: nomeRota ?? this.nomeRota,
    );
  }
}

