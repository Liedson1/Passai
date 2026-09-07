import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/network/supabase_client.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'domain/entities/rota.dart';
import 'presentation/pages/auth/sign_in_page.dart';
import 'presentation/pages/auth/sign_up_page.dart';
import 'presentation/pages/home/home_page.dart';
import 'presentation/pages/horarios/horarios_page.dart';
import 'core/utils/url_strategy/url_strategy.dart';
import 'presentation/pages/resultados/resultados_page.dart';

import 'core/theme/app_colors.dart';
import 'presentation/widgets/responsive_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Desativa download HTTP externo de fontes em runtime: todas são empacotadas localmente (zero FOUT)
  GoogleFonts.config.allowRuntimeFetching = false;

  // Configura rotas limpas na web (sem o '#' na URL)
  configureAppUrlStrategy();

  // Inicialização assíncrona paralela para arranque rápido antes do primeiro frame
  await Future.wait([
    initializeDateFormatting('pt_BR', null),
    dotenv.load(fileName: '.env').catchError((_) {}),
  ]);

  // Inicializa o Supabase com as credenciais do .env ou --dart-define
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
  initialLocation: AppRoutes.home,
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
        return Scaffold(
          backgroundColor: AppColors.background,
          body: ResponsiveShell(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.alt_route_rounded,
                      size: 56,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Selecione uma rota para consultar',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Ao recarregar a página web, volte ao início para iniciar uma nova consulta.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                      onPressed: () => context.go(AppRoutes.home),
                      icon: const Icon(Icons.home_outlined),
                      label: const Text('Voltar ao início'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.resultados,
      builder: (context, state) {
        final extra = state.extra;
        if (extra is ResultadosArgs) {
          return ResultadosPage(args: extra);
        }
        return Scaffold(
          backgroundColor: AppColors.background,
          body: ResponsiveShell(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.search_off_rounded,
                      size: 56,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Nenhuma busca ativa',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Ao recarregar a página web, selecione a origem e o destino novamente.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                      onPressed: () => context.go(AppRoutes.home),
                      icon: const Icon(Icons.home_outlined),
                      label: const Text('Voltar ao início'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ),
  ],
);

/// Comportamento de rolagem customizado: física sem deformação de malha (Clamping)
/// e suporte completo a toque, mouse e trackpad.
class PassaiScrollBehavior extends MaterialScrollBehavior {
  const PassaiScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const ClampingScrollPhysics();
  }
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
      routerConfig: _router,
    );
  }
}

