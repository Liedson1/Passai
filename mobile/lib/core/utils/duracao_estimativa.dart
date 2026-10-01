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

  /// Estima a duração da viagem a partir da distância em km.
  ///
  /// Retorna string formatada (ex: "64 min", "1h 30min") ou `null`
  /// se a distância não estiver disponível.
  static String? estimar(int? distanciaKm) {
    if (distanciaKm == null) return null;
    final minutos = (distanciaKm * _fatorKmParaMinutos).round();
    if (minutos >= 60) {
      final horas = minutos ~/ 60;
      final mins = minutos % 60;
      return mins > 0 ? '${horas}h ${mins}min' : '${horas}h';
    }
    return '$minutos min';
  }
}
