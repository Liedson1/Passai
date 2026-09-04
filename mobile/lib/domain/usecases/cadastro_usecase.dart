import 'package:passai/domain/entities/auth_user.dart';
import 'package:passai/domain/repositories/auth_repository.dart';

/// Caso de uso: registrar um novo usuário no sistema.
///
/// Responsabilidade única (SRP): validar todos os campos do formulário
/// de cadastro e delegar ao [AuthRepository].
class CadastroUsecase {
  const CadastroUsecase(this._repository);

  final AuthRepository _repository;

  /// Executa o cadastro após validar os campos.
  /// Lança [AuthException] se qualquer campo for inválido ou se o cadastro falhar.
  Future<AuthUser> call({
    required String nome,
    required String email,
    required String telefone,
    required String senha,
  }) async {
    final nomeNorm = nome.trim();
    final emailNorm = email.trim();
    final telefoneNorm = telefone.trim();

    if (nomeNorm.length < 2) {
      throw const AuthException('Informe seu nome completo.');
    }

    if (emailNorm.isEmpty || !_emailValido(emailNorm)) {
      throw const AuthException('Informe um e-mail válido.');
    }

    if (telefoneNorm.length < 10) {
      throw const AuthException('Informe um telefone válido com DDD.');
    }

    if (senha.length < 6) {
      throw const AuthException('A senha deve ter pelo menos 6 caracteres.');
    }

    return _repository.cadastro(
      nome: nomeNorm,
      email: emailNorm,
      telefone: telefoneNorm,
      senha: senha,
    );
  }

  bool _emailValido(String email) {
    return RegExp(r'^[\w.+-]+@[\w-]+\.[a-z]{2,}$', caseSensitive: false)
        .hasMatch(email);
  }
}
