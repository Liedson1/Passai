import 'package:supabase_flutter/supabase_flutter.dart';

/// Cliente Supabase centralizado — use este getter em toda a aplicação.
/// Nunca instancie [SupabaseClient] diretamente fora deste arquivo.
SupabaseClient get supabase => Supabase.instance.client;

/// Configurações públicas do Supabase (URL e Chave Anônima/Pública).
/// Podem ser sobrescritas em tempo de compilação via --dart-define.
const String _defaultSupabaseUrl = 'https://iwwduklpqbbyjhtovgjq.supabase.co';
const String _defaultSupabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Iml3d2R1a2xwcWJieWpodG92Z2pxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODUyNjI3ODUsImV4cCI6MjEwMDgzODc4NX0.4-oweykwcrPfXFSwKi8PfU3E3nMgBii-kfpWuTOt9_0';

/// Inicializa o Supabase com as credenciais compiladas ou via --dart-define.
/// Não realiza chamadas HTTP para arquivos .env em runtime, eliminando vazamentos de arquivos
/// e acelerando a inicialização do app.
Future<void> initSupabase() async {
  const envUrl = String.fromEnvironment('SUPABASE_URL');
  const envAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  final url = envUrl.isNotEmpty ? envUrl : _defaultSupabaseUrl;
  final anonKey = envAnonKey.isNotEmpty ? envAnonKey : _defaultSupabaseAnonKey;

  await Supabase.initialize(
    url: url,
    publishableKey: anonKey,
  );
}

