import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Cliente Supabase centralizado — use este getter em toda a aplicação.
/// Nunca instancie [SupabaseClient] diretamente fora deste arquivo.
SupabaseClient get supabase => Supabase.instance.client;

bool _isConfigured = false;

/// Indica se o Supabase foi inicializado com credenciais válidas.
bool get isSupabaseConfigured => _isConfigured;

/// Inicializa o Supabase com credenciais fornecidas via `--dart-define`
/// ou `--dart-define-from-file=.env.json`.
///
/// Não contém valores hardcoded no código por segurança (SEC-01).
/// Caso as credenciais não sejam fornecidas, registra um aviso e
/// mantém o app responsivo sem causar crash fatal antes de [runApp].
Future<void> initSupabase() async {
  const envUrl = String.fromEnvironment('SUPABASE_URL');
  const envAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  if (envUrl.isEmpty || envAnonKey.isEmpty) {
    debugPrint(
      '⚠️ [Passaí] SUPABASE_URL ou SUPABASE_ANON_KEY não foram fornecidos.\n'
      'Para executar localmente, use: ./run.sh ou flutter run --dart-define-from-file=.env.json\n'
      'No CI/CD ou Vercel, configure as variáveis de ambiente do projeto.',
    );
    _isConfigured = false;
    return;
  }

  await Supabase.initialize(
    url: envUrl,
    publishableKey: envAnonKey,
  );
  _isConfigured = true;
}

