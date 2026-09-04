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
  });

  final int id;

  /// Horário exibido ao passageiro — pode ser diferente do original se houver alteração
  final String hora;
  final Sentido sentido;

  /// Presente quando este horário foi alterado hoje (RN03, RN05)
  final Alteracao? alteracao;

  /// Indica se o horário foi alterado hoje (RN06)
  bool get alterado => alteracao != null;
}
