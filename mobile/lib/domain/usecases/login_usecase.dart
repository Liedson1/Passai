import 'package:passai/domain/entities/auth_user.dart';
import 'package:passai/domain/repositories/auth_repository.dart';

/// Caso de uso: autenticar um usuário com e-mail e senha.
///
/// Responsabilidade única (SRP): validar campos de entrada
/// e delegar ao [AuthRepository] — zero lógica de UI aqui.
class LoginUsecase {
  const LoginUsecase(this._repository);

  final AuthRepository _repository;

  /// Executa o login após validar os campos.
  /// Lança [AuthException] se a validação ou o login falharem.
  Future<AuthUser> call({
    required String email,
    required String senha,
  }) async {
    final emailNorm = email.trim();

    if (emailNorm.isEmpty) {
      throw const AuthException('O e-mail não pode estar vazio.');
    }

    if (!_emailValido(emailNorm)) {
      throw const AuthException('Informe um e-mail válido.');
    }

    if (senha.length < 6) {
      throw const AuthException('A senha deve ter pelo menos 6 caracteres.');
    }

    return _repository.login(email: emailNorm, senha: senha);
  }

  bool _emailValido(String email) {
    return RegExp(r'^[\w.+-]+@[\w-]+\.[a-z]{2,}$', caseSensitive: false)
        .hasMatch(email);
  }
}
