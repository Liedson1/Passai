/// Entidade de domínio: Alteração de horário de uma van
class Alteracao {
  const Alteracao({
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
}
