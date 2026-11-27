/// Utilitário centralizado de normalização de texto para o Passaí.
///
/// Normaliza strings removendo acentos, apóstrofos, espaços extras
/// e convertendo para minúsculas. Usado em buscas, comparações e
/// lookup de coordenadas — eliminando duplicação de código.
class TextNormalizer {
  TextNormalizer._();

  /// Normaliza [texto] para comparação resiliente:
  /// - Remove acentos (à → a, ç → c)
  /// - Remove apóstrofos e crases
  /// - Colapsa espaços múltiplos
  /// - Converte para minúsculas
  static String normalizar(String texto) {
    return texto
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[àáâãäå]'), 'a')
        .replaceAll(RegExp(r'[èéêë]'), 'e')
        .replaceAll(RegExp(r'[ìíîï]'), 'i')
        .replaceAll(RegExp(r'[òóôõö]'), 'o')
        .replaceAll(RegExp(r'[ùúûü]'), 'u')
        .replaceAll(RegExp(r'[ç]'), 'c')
        .replaceAll(RegExp(r"['`]"), '')
        .replaceAll(RegExp(r'\s+'), ' ');
  }
}
