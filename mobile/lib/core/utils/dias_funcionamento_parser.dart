/// Utilitário puro para interpretação dos padrões de [dias_funcionamento]
/// vindo do banco de dados.
///
/// Centraliza a lógica que antes vivia dentro da entidade [Horario],
/// tornando-a testável isoladamente e fácil de estender com novos padrões.
class DiasFuncionamentoParser {
  DiasFuncionamentoParser._();

  /// Retorna `true` se um horário com [diasFuncionamento] opera na [data].
  ///
  /// Correspondência de [DateTime.weekday]:
  ///   1 = Segunda, 2 = Terça, 3 = Quarta, 4 = Quinta,
  ///   5 = Sexta, 6 = Sábado, 7 = Domingo
  static bool opera(String diasFuncionamento, DateTime data) {
    final r = diasFuncionamento.toLowerCase().trim();
    final weekday = data.weekday;

    // ── Padrões contínuos ────────────────────────────────────────────────────

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

    // ── Padrões compostos (ordem importa: mais específico antes) ─────────────

    // "Quarta, Sexta e Sábado" → 3, 5 e 6
    if (r.contains('quarta, sexta e sábado') ||
        r.contains('quarta, sexta e sabado')) {
      return weekday == 3 || weekday == 5 || weekday == 6;
    }
    // "Quarta e Sexta" → 3 e 5
    if (r.contains('quarta e sexta')) {
      return weekday == 3 || weekday == 5;
    }

    // "Sábado e Domingo" / "Fins de Semana" → 6 e 7
    if (r.contains('sábado e domingo') ||
        r.contains('sabado e domingo') ||
        r.contains('sábados e domingos') ||
        r.contains('sabados e domingos') ||
        r.contains('fim de semana') ||
        r.contains('finais de semana')) {
      return weekday == 6 || weekday == 7;
    }

    // ── Dias isolados ────────────────────────────────────────────────────────

    if (r == 'segunda' || r.contains('segunda-feira')) {
      return weekday == 1;
    }
    if (r == 'terça' || r == 'terca' || r.contains('terça-feira')) {
      return weekday == 2;
    }
    if (r == 'quarta' || r.contains('quarta-feira')) {
      return weekday == 3;
    }
    if (r == 'quinta' || r.contains('quinta-feira')) {
      return weekday == 4;
    }
    if (r == 'sexta' || r.contains('sexta-feira')) {
      return weekday == 5;
    }
    if (r == 'sábado' || r == 'sabado' || r.contains('sábado')) {
      return weekday == 6;
    }
    if (r == 'domingo' || r.contains('domingo')) {
      return weekday == 7;
    }

    // Padrão desconhecido: opera por padrão (fail-open para não omitir horários)
    return true;
  }
}
