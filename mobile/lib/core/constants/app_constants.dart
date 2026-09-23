/// Tokens de dimensão e raio do Passaí
class AppRadii {
  AppRadii._();

  static const double card = 16;
  static const double input = 12;
  static const double badge = 8;
  static const double pill = 100;
  static const double button = 16;
}

/// Constantes da aplicação
class AppConstants {
  AppConstants._();

  static const String appName = 'Passaí';
  static const String state = 'ALAGOAS';
  static const String tagline = 'Para onde você vai hoje?';
  static const String taglineSubtitle =
      'Consulte horários de vans intermunicipais em Alagoas';

  /// IDs de rotas ativas no banco mas sem horários cadastrados.
  /// Usados para excluí-las das listagens públicas até o cadastro ser concluído.
  static const Set<int> rotasSemHorarioIds = {100};
}

/// Nomes das rotas do GoRouter — use sempre estas constantes para navegar
class AppRoutes {
  AppRoutes._();

  static const String home = '/';
  static const String horarios = '/horarios';
  static const String resultados = '/resultados';
  static const String detalhesViagem = '/detalhes-viagem';

  // Rotas de autenticação — reservadas para uso futuro (não expostas no router)
  // static const String signIn = '/sign-in';
  // static const String signUp = '/sign-up';
}
