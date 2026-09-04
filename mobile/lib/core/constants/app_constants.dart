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
      'Consulte horários de vans intermunicipais no Sertão';
}

/// Nomes das rotas do GoRouter — use sempre estas constantes para navegar
class AppRoutes {
  AppRoutes._();

  static const String home = '/';
  static const String horarios = '/horarios';
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
}
