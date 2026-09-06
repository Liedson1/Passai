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

  /// Verifica se este horário opera na data fornecida (RN10)
  /// [DateTime.weekday]: 1 = Segunda, ..., 7 = Domingo
  bool operaNoDia(DateTime data) {
    final r = diasFuncionamento.toLowerCase();
    final weekday = data.weekday;

    if (r.contains('diariamente') || r.contains('segunda a domingo')) {
      return true;
    }
    if (r.contains('segunda a sábado') || r.contains('segunda a sabado')) {
      return weekday >= 1 && weekday <= 6;
    }
    if (r.contains('segunda a sexta')) {
      return weekday >= 1 && weekday <= 5;
    }
    if (r.contains('terça a domingo') || r.contains('terca a domingo')) {
      return weekday >= 2 && weekday <= 7;
    }
    if (r.contains('terça a sexta') || r.contains('terca a sexta')) {
      return weekday >= 2 && weekday <= 5;
    }
    if (r.contains('quarta, sexta e sábado') || r.contains('quarta, sexta e sabado')) {
      return weekday == 1 || weekday == 2 || weekday == 3 || weekday == 5 || weekday == 6;
    }
    if (r.contains('quarta e sexta')) {
      return weekday == 1 || weekday == 2 || weekday == 3 || weekday == 5;
    }
    if (r.contains('segunda-feira') || r == 'segunda') {
      return weekday == 1;
    }
    if (r.contains('quinta-feira') || r == 'quinta') {
      return weekday == 4;
    }
    if (r.contains('sábado') || r.contains('sabado')) {
      return weekday == 6;
    }
    if (r.contains('domingo')) {
      return weekday == 7;
    }
    return true;
  }
}
