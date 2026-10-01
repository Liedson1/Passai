import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/network/supabase_client.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/passai_scroll_behavior.dart';
import 'core/utils/url_strategy/url_strategy.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configura rotas limpas na web (sem o '#' na URL)
  configureAppUrlStrategy();

  try {
    await Future.wait([
      initializeDateFormatting('pt_BR', null),
    ]);
  } catch (_) {}

  // Inicializa o Supabase com as credenciais compiladas ou via --dart-define
  try {
    await initSupabase();
  } catch (e) {
    debugPrint('Erro ao inicializar Supabase: $e');
  }

  // Status bar e navigation bar para padrão edge-to-edge nativo
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );

  runApp(
    // ProviderScope é obrigatório para o Riverpod funcionar
    const ProviderScope(
      child: PassaiApp(),
    ),
  );
}

class PassaiApp extends StatelessWidget {
  const PassaiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Passaí',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      scrollBehavior: const PassaiScrollBehavior(),
      routerConfig: appRouter,
    );
  }
}
