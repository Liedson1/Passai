import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Cliente Supabase centralizado — use este getter em toda a aplicação.
/// Nunca instancie [SupabaseClient] diretamente fora deste arquivo.
SupabaseClient get supabase => Supabase.instance.client;

/// Inicializa o Supabase com as credenciais do arquivo .env ou --dart-define.
/// Deve ser chamado antes de [runApp].
Future<void> initSupabase() async {
  final url = const String.fromEnvironment('SUPABASE_URL').isNotEmpty
      ? const String.fromEnvironment('SUPABASE_URL')
      : (dotenv.env['SUPABASE_URL'] ?? '');

  final anonKey = const String.fromEnvironment('SUPABASE_ANON_KEY').isNotEmpty
      ? const String.fromEnvironment('SUPABASE_ANON_KEY')
      : (dotenv.env['SUPABASE_ANON_KEY'] ?? '');

  if (url.isEmpty || anonKey.isEmpty) {
    throw StateError(
      'SUPABASE_URL ou SUPABASE_ANON_KEY não foram definidos. '
      'Configure no arquivo .env ou passe via --dart-define no build.',
    );
  }

  await Supabase.initialize(
    url: url,
    publishableKey: anonKey,
  );
}

