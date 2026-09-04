import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Cliente Supabase centralizado — use este getter em toda a aplicação.
/// Nunca instancie [SupabaseClient] diretamente fora deste arquivo.
SupabaseClient get supabase => Supabase.instance.client;

/// Inicializa o Supabase com as credenciais do arquivo .env.
/// Deve ser chamado antes de [runApp].
Future<void> initSupabase() async {
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    publishableKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
}
