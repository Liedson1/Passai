import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/network/supabase_client.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'domain/entities/rota.dart';
import 'presentation/pages/auth/sign_in_page.dart';
import 'presentation/pages/auth/sign_up_page.dart';
import 'presentation/pages/home/home_page.dart';
import 'presentation/pages/horarios/horarios_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Carrega as variáveis de ambiente do arquivo .env
  await dotenv.load(fileName: '.env');

  // Inicializa o Supabase com as credenciais do .env
  await initSupabase();

  // Status bar transparente para o hero banner ter fundo vermelho completo
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    // ProviderScope é obrigatório para o Riverpod funcionar
    const ProviderScope(
      child: PassaiApp(),
    ),
  );
}

/// Configuração das rotas do GoRouter
final _router = GoRouter(
  initialLocation: AppRoutes.signIn,
  routes: [
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: AppRoutes.signIn,
      builder: (context, state) => const SignInPage(),
    ),
    GoRoute(
      path: AppRoutes.signUp,
      builder: (context, state) => const SignUpPage(),
    ),
    GoRoute(
      path: AppRoutes.horarios,
      builder: (context, state) {
        final extra = state.extra;
        if (extra is HorariosArgs) {
          return HorariosPage(
            rota: extra.rota,
            initialSentido: extra.initialSentido,
          );
        } else if (extra is Rota) {
          return HorariosPage(rota: extra);
        }
        return const Scaffold(
          body: Center(child: Text('Rota não encontrada.')),
        );
      },
    ),
  ],
);

class PassaiApp extends StatelessWidget {
  const PassaiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Passaí',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: _router,
    );
  }
}
