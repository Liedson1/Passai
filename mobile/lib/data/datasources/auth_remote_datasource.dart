import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:passai/domain/entities/auth_user.dart' as domain;
import 'package:passai/domain/repositories/auth_repository.dart' as domain;

/// Fonte de dados remota de autenticação via Supabase Auth.
///
/// ÚNICO lugar no projeto que referencia o Supabase Auth diretamente.
/// Todas as outras camadas dependem de [AuthRepository] (abstração).
/// Prefixo 'domain.' usado para resolver ambiguidade com tipos do Supabase.
class AuthRemoteDatasource {
  SupabaseClient get _client => Supabase.instance.client;

  /// Autentica o usuário com e-mail e senha via Supabase Auth.
  Future<domain.AuthUser> login({
    required String email,
    required String senha,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: senha,
      );

      final user = response.user;
      if (user == null) {
        throw const domain.AuthException(
            'Credenciais inválidas. Tente novamente.');
      }

      return domain.AuthUser(
        id: user.id,
        email: user.email ?? email,
        nome: user.userMetadata?['nome'] as String?,
        telefone: user.userMetadata?['telefone'] as String?,
      );
    } on domain.AuthException {
      rethrow;
    } catch (e) {
      throw domain.AuthException(_traduzirErro(e.toString()));
    }
  }

  /// Registra um novo usuário via Supabase Auth.
  Future<domain.AuthUser> cadastro({
    required String nome,
    required String email,
    required String telefone,
    required String senha,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: senha,
        data: {'nome': nome, 'telefone': telefone},
      );

      final user = response.user;
      if (user == null) {
        throw const domain.AuthException(
            'Não foi possível criar a conta. Tente novamente.');
      }

      return domain.AuthUser(
        id: user.id,
        email: user.email ?? email,
        nome: nome,
        telefone: telefone,
      );
    } on domain.AuthException {
      rethrow;
    } catch (e) {
      throw domain.AuthException(_traduzirErro(e.toString()));
    }
  }

  /// Encerra a sessão do usuário atual.
  Future<void> logout() async {
    await _client.auth.signOut();
  }

  /// Retorna o usuário da sessão ativa, ou null.
  domain.AuthUser? get usuarioAtual {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    return domain.AuthUser(
      id: user.id,
      email: user.email ?? '',
      nome: user.userMetadata?['nome'] as String?,
      telefone: user.userMetadata?['telefone'] as String?,
    );
  }

  /// Traduz mensagens de erro do Supabase para português do Brasil.
  String _traduzirErro(String erro) {
    if (erro.contains('Invalid login credentials')) {
      return 'E-mail ou senha incorretos.';
    }
    if (erro.contains('Email already registered') ||
        erro.contains('already been registered')) {
      return 'Este e-mail já está cadastrado.';
    }
    if (erro.contains('Password should be at least')) {
      return 'A senha deve ter pelo menos 6 caracteres.';
    }
    if (erro.contains('network') || erro.contains('SocketException')) {
      return 'Sem conexão com a internet.';
    }
    return 'Ocorreu um erro inesperado. Tente novamente.';
  }
}
