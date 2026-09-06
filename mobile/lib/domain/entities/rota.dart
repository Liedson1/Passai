

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

  /// Retorna a via da rota se especificada na linha (ex: "via Litoral", "via Taquarana"), ou null.
  String? get via {
    final match = RegExp(r'\(\s*(via\s+[^)]+)\)', caseSensitive: false).firstMatch(linha);
    if (match != null) {
      final text = match.group(1)?.trim();
      if (text != null && text.isNotEmpty) {
        final parts = text.split(RegExp(r'\s+'));
        if (parts.length >= 2) {
          final prefixo = parts.first.toLowerCase();
          final resto = parts.sublist(1).map((p) {
            if (['de', 'da', 'do', 'das', 'dos'].contains(p.toLowerCase())) {
              return p.toLowerCase();
            }
            return p.isNotEmpty ? p[0].toUpperCase() + p.substring(1).toLowerCase() : '';
          }).join(' ');
          return '$prefixo $resto';
        }
        return text;
      }
    }
    return null;
  }
}

