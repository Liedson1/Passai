/// Utilitário centralizado para estimativa de duração de viagem.
///
/// Unifica a fórmula de estimativa que antes existia em dois locais
/// com valores diferentes (0.9 e 1.15), causando inconsistências.
class DuracaoEstimativa {
  DuracaoEstimativa._();

  /// Fator de conversão km → minutos.
  ///
  /// Baseado em velocidade média ~60 km/h para transporte intermunicipal
  /// em estradas do interior de Alagoas, resultando em ~1.0 min/km.
  static const double _fatorKmParaMinutos = 1.0;

  /// Formata uma quantidade de minutos no padrão da aplicação:
  /// - Até 59 minutos: "X min" (ex: "45 min", "59 min")
  /// - A partir de 60 minutos: "Xh" ou "Xh Ymin" (ex: "1h", "1h 15min", "2h 30min")
  static String? formatarMinutos(int? minutos) {
    if (minutos == null || minutos <= 0) return null;
    if (minutos >= 60) {
      final horas = minutos ~/ 60;
      final mins = minutos % 60;
      return mins > 0 ? '${horas}h ${mins}min' : '${horas}h';
    }
    return '$minutos min';
  }

  /// Estima a duração da viagem a partir da distância em km.
  ///
  /// Retorna string formatada (ex: "45 min", "1h 15min") ou `null`
  /// se a distância não estiver disponível.
  static String? estimar(int? distanciaKm) {
    if (distanciaKm == null) return null;
    final minutos = (distanciaKm * _fatorKmParaMinutos).round();
    return formatarMinutos(minutos);
  }

  /// Padroniza qualquer string de duração existente (ex: "74 min", "1h 45m", "85min").
  ///
  /// Garante que valores acima de 59 minutos sejam exibidos em horas e minutos ("1h 14min").
  static String? padronizar(String? duracaoStr) {
    if (duracaoStr == null || duracaoStr.trim().isEmpty) return null;
    final trimmed = duracaoStr.trim();
    if (trimmed.toLowerCase() == 'a consultar') return 'A consultar';

    // Se já é do tipo "1h 30min" ou "1h", garante formatação consistente
    final regex = RegExp(
      r'^(?:(\d+)\s*h(?:oras?)?)?\s*(?:(\d+)\s*m(?:in(?:utos?)?)?)?$',
      caseSensitive: false,
    );
    final match = regex.firstMatch(trimmed);
    if (match != null) {
      final horas = int.tryParse(match.group(1) ?? '') ?? 0;
      final mins = int.tryParse(match.group(2) ?? '') ?? 0;
      final totalMinutos = horas * 60 + mins;
      if (totalMinutos > 0) {
        return formatarMinutos(totalMinutos);
      }
    }

    // Se contiver apenas números (ex: "75")
    final apenasNumero = int.tryParse(trimmed);
    if (apenasNumero != null) {
      return formatarMinutos(apenasNumero);
    }

    return trimmed;
  }
}
