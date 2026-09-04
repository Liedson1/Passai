

/// Entidade de domínio: Rota de van intermunicipal
class Rota {
  const Rota({
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
}
