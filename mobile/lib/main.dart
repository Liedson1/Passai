import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:intl/date_symbol_data_local.dart';

import 'core/network/supabase_client.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'domain/entities/detalhes_viagem.dart';
import 'domain/entities/horario.dart';
import 'domain/entities/parada_itinerario.dart';
import 'domain/entities/rota.dart';
import 'domain/usecases/buscar_rotas.dart';
import 'presentation/providers/rotas_provider.dart';
// Páginas de auth mantidas no filesystem para uso futuro, não importadas no MVP (RN07)
// import 'presentation/pages/auth/sign_in_page.dart';
// import 'presentation/pages/auth/sign_up_page.dart';
import 'presentation/pages/home/home_page.dart';
import 'presentation/pages/horarios/horarios_page.dart';
import 'core/utils/url_strategy/url_strategy.dart';
import 'presentation/pages/resultados/resultados_page.dart';
import 'presentation/pages/detalhes_viagem/detalhes_viagem_page.dart';

import 'core/theme/app_colors.dart';
import 'presentation/widgets/responsive_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  // Configura rotas limpas na web (sem o '#' na URL)
  configureAppUrlStrategy();

  // Inicialização assíncrona para arranque rápido antes do primeiro frame
  await Future.wait([
    initializeDateFormatting('pt_BR', null),
  ]);

  // Inicializa o Supabase com as credenciais compiladas
  await initSupabase();

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

/// Configuração das rotas do GoRouter com suporte completo a Web Deep Linking e F5
final _router = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomePage(),
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
        return _buildEmptyStateScaffold(
          context,
          icon: Icons.alt_route_rounded,
          title: 'Selecione uma rota para consultar',
          subtitle: 'Inicie sua consulta selecionando a origem e destino.',
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

        // Suporte a Deep Linking e F5 na Web via query parameters
        final origem = state.uri.queryParameters['origem'];
        final destino = state.uri.queryParameters['destino'];
        final rotaIdStr = state.uri.queryParameters['rotaId'];
        final sentidoStr = state.uri.queryParameters['sentido'];

        if ((origem != null && destino != null) || rotaIdStr != null) {
          return _ResultadosResolverPage(
            origem: origem,
            destino: destino,
            rotaId: int.tryParse(rotaIdStr ?? ''),
            sentidoStr: sentidoStr,
          );
        }

        return _buildEmptyStateScaffold(
          context,
          icon: Icons.search_off_rounded,
          title: 'Nenhuma busca ativa',
          subtitle: 'Selecione a origem e o destino na página inicial para consultar os horários.',
        );
      },
    ),
    GoRoute(
      path: AppRoutes.detalhesViagem,
      builder: (context, state) {
        final extra = state.extra;
        if (extra is DetalhesViagemArgs) {
          return DetalhesViagemPage(args: extra);
        }

        // Suporte a recarregamento F5 na Web
        final rotaIdStr = state.uri.queryParameters['rotaId'];
        final sentidoStr = state.uri.queryParameters['sentido'];
        final hora = state.uri.queryParameters['hora'];

        if (rotaIdStr != null) {
          final rotaId = int.tryParse(rotaIdStr);
          if (rotaId != null) {
            return _DetalhesViagemResolverPage(
              rotaId: rotaId,
              sentidoStr: sentidoStr ?? 'IDA',
              hora: hora,
            );
          }
        }

        return _buildEmptyStateScaffold(
          context,
          icon: Icons.route_rounded,
          title: 'Viagem não encontrada',
          subtitle: 'Selecione uma viagem a partir da tela de resultados.',
        );
      },
    ),
  ],
);

/// Resolve a busca ao recarregar a página (F5) ou acessar via link compartilhado
class _ResultadosResolverPage extends ConsumerWidget {
  const _ResultadosResolverPage({
    this.origem,
    this.destino,
    this.rotaId,
    this.sentidoStr,
  });

  final String? origem;
  final String? destino;
  final int? rotaId;
  final String? sentidoStr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rotasAsync = ref.watch(todasAsRotasProvider);

    return rotasAsync.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      error: (err, _) => Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.wifi_off_rounded, size: 48, color: AppColors.primary),
                const SizedBox(height: 16),
                const Text(
                  'Não foi possível carregar os horários.',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                  onPressed: () => ref.invalidate(todasAsRotasProvider),
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (rotas) {
        Rota? rotaEncontrada;
        Sentido sentido = sentidoStr?.toLowerCase() == 'volta'
            ? Sentido.volta
            : Sentido.ida;

        if (rotaId != null) {
          rotaEncontrada = rotas.where((r) => r.id == rotaId).firstOrNull;
        }

        if (rotaEncontrada == null && origem != null && destino != null) {
          final oNorm = BuscarRotas.normalizar(origem!);
          final dNorm = BuscarRotas.normalizar(destino!);

          rotaEncontrada = rotas.where((r) {
            return BuscarRotas.normalizar(r.origem) == oNorm &&
                BuscarRotas.normalizar(r.destino) == dNorm;
          }).firstOrNull;

          if (rotaEncontrada != null) {
            sentido = Sentido.ida;
          } else {
            rotaEncontrada = rotas.where((r) {
              return BuscarRotas.normalizar(r.origem) == dNorm &&
                  BuscarRotas.normalizar(r.destino) == oNorm;
            }).firstOrNull;
            if (rotaEncontrada != null) {
              sentido = Sentido.volta;
            }
          }
        }

        if (rotaEncontrada != null) {
          return ResultadosPage(
            args: ResultadosArgs(rota: rotaEncontrada, sentido: sentido),
          );
        }

        return _buildEmptyStateScaffold(
          context,
          icon: Icons.directions_bus_outlined,
          title: 'Rota não encontrada',
          subtitle:
              'Não encontramos vans cadastradas entre ${origem ?? "origem"} e ${destino ?? "destino"}.',
        );
      },
    );
  }
}

/// Resolve detalhes da viagem ao recarregar a página (F5) na Web
class _DetalhesViagemResolverPage extends ConsumerWidget {
  const _DetalhesViagemResolverPage({
    required this.rotaId,
    required this.sentidoStr,
    this.hora,
  });

  final int rotaId;
  final String sentidoStr;
  final String? hora;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rotasAsync = ref.watch(todasAsRotasProvider);

    return rotasAsync.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      error: (_, __) => _buildEmptyStateScaffold(
        context,
        icon: Icons.error_outline,
        title: 'Erro ao carregar viagem',
        subtitle: 'Verifique sua conexão e tente novamente.',
      ),
      data: (rotas) {
        final rota = rotas.where((r) => r.id == rotaId).firstOrNull;
        if (rota == null) {
          return _buildEmptyStateScaffold(
            context,
            icon: Icons.route_rounded,
            title: 'Viagem não encontrada',
            subtitle: 'A rota selecionada não está disponível.',
          );
        }

        final isIda = sentidoStr.toUpperCase() != 'VOLTA';
        final origem = isIda ? rota.origem : rota.destino;
        final destino = isIda ? rota.destino : rota.origem;
        final precoStr = rota.tarifa != null
            ? 'R\$ ${rota.tarifa!.toStringAsFixed(2).replaceAll('.', ',')}'
            : 'Consulte';

        final itinerarioFallback = [
          ParadaItinerario(parada: origem, horario: hora ?? '', descricao: 'Partida'),
          ParadaItinerario(parada: destino, horario: '', descricao: 'Chegada'),
        ];

        final duracaoStr = rota.distanciaKm != null
            ? '${(rota.distanciaKm! * 1.15).round()} min'
            : 'A consultar';
        final distanciaStr = rota.distanciaKm != null
            ? '${rota.distanciaKm} km'
            : 'A consultar';

        final detalhes = DetalhesViagem(
          codigo: rota.linha,
          preco: precoStr,
          rota: '$origem x $destino',
          origem: origem,
          destino: destino,
          itinerario: itinerarioFallback,
          horaSaida: hora,
          duracao: duracaoStr,
          distancia: distanciaStr,
          tipoLinha: 'Transporte Intermunicipal',
          diasOperacao: rota.diasOperacao,
          seccionamentos: rota.seccionamentos,
          via: rota.via,
        );

        return DetalhesViagemPage(
          args: DetalhesViagemArgs(
            detalhes: detalhes,
            rotaId: rota.id,
            sentido: isIda ? 'IDA' : 'VOLTA',
          ),
        );
      },
    );
  }
}

/// Helper para tela vazia consistente com botão de voltar ao início
Widget _buildEmptyStateScaffold(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String subtitle,
}) {
  return Scaffold(
    backgroundColor: AppColors.background,
    body: ResponsiveShell(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 56, color: AppColors.primary),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
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
}

/// Comportamento de rolagem adaptativo por plataforma:
/// - iOS e macOS: BouncingScrollPhysics nativo com suporte a toque
/// - Android, Web e Desktop: ClampingScrollPhysics consistente
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
    final platform = Theme.of(context).platform;
    if (platform == TargetPlatform.iOS || platform == TargetPlatform.macOS) {
      return const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      );
    }
    return const ClampingScrollPhysics(
      parent: AlwaysScrollableScrollPhysics(),
    );
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

