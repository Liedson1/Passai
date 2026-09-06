import 'package:passai/domain/entities/auth_user.dart';

/// Contrato abstrato do repositório de autenticação.
///
/// Define o que o sistema PODE fazer com auth, sem ditar COMO.
/// A implementação concreta vive em [data/repositories/auth_repository_impl.dart].
///
/// Princípio DIP: as camadas superiores (usecases, providers, pages)
/// dependem desta abstração, nunca do Supabase diretamente.
abstract class AuthRepository {
  /// Realiza login com e-mail e senha.
  /// Lança [AuthException] em caso de falha.
  Future<AuthUser> login({
    required String email,
    required String senha,
  });

  /// Cria uma nova conta com nome, e-mail, telefone e senha.
  /// Lança [AuthException] em caso de falha.
  Future<AuthUser> cadastro({
    required String nome,
    required String email,
    required String telefone,
    required String senha,
  });

  /// Encerra a sessão do usuário atual.
  Future<void> logout();

  /// Retorna o usuário atual da sessão ativa, ou null se não autenticado.
  AuthUser? get usuarioAtual;
}

/// Exceção de domínio para erros de autenticação.
/// Encapsula mensagens de erro sem vazar detalhes de implementação.
class AuthException implements Exception {
  const AuthException(this.mensagem);

  final String mensagem;

  @override
  String toString() => 'AuthException: $mensagem';
}
