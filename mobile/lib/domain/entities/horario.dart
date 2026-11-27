import 'package:passai/core/utils/dias_funcionamento_parser.dart';

import 'alteracao.dart';

/// Sentido da viagem
enum Sentido { ida, volta }

/// Entidade de domínio: Horário de uma van em uma rota
class Horario {
  const Horario({
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

  /// Horário exibido ao passageiro — pode ser diferente do original se houver alteração
  final String hora;
  final Sentido sentido;

  /// Dias em que este horário opera (ex: "Segunda a Sexta", "Diariamente", etc.)
  final String diasFuncionamento;

  /// Presente quando este horário foi alterado hoje (RN03, RN05)
  final Alteracao? alteracao;

  /// Tarifa específica deste horário (pode diferir da tarifa geral da rota)
  final double? preco;

  /// Duração estimada da viagem (ex: "45 min", "1h 10m")
  final String? duracao;

  /// Tipo de trajeto: "Direto" ou "N paradas"
  final String? paradas;

  /// Nome descritivo da rota/variante (ex: "Delmiro Gouveia x Piranhas (via Casado)")
  final String? nomeRota;

  /// Indica se o horário foi alterado hoje (RN06)
  bool get alterado => alteracao != null;

  /// Indica se a viagem é direta (sem paradas intermediárias)
  bool get isDireto => paradas == null || paradas == 'Direto';

  /// Verifica se este horário opera na data fornecida (RN10).
  /// Delega a lógica de parsing para [DiasFuncionamentoParser].
  bool operaNoDia(DateTime data) {
    return DiasFuncionamentoParser.opera(diasFuncionamento, data);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Horario &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          hora == other.hora &&
          sentido == other.sentido &&
          diasFuncionamento == other.diasFuncionamento &&
          alteracao == other.alteracao &&
          preco == other.preco &&
          duracao == other.duracao &&
          paradas == other.paradas &&
          nomeRota == other.nomeRota;

  @override
  int get hashCode => Object.hash(
        id,
        hora,
        sentido,
        diasFuncionamento,
        alteracao,
        preco,
        duracao,
        paradas,
        nomeRota,
      );
}
