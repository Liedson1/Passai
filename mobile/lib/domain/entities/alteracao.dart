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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Alteracao &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          horaOriginal == other.horaOriginal &&
          horaNova == other.horaNova &&
          vanOriginal == other.vanOriginal &&
          vanSubstituta == other.vanSubstituta &&
          motivo == other.motivo;

  @override
  int get hashCode => Object.hash(
        id,
        horaOriginal,
        horaNova,
        vanOriginal,
        vanSubstituta,
        motivo,
      );
}
