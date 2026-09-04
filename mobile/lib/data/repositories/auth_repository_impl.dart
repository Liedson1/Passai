import 'package:passai/data/datasources/auth_remote_datasource.dart';
import 'package:passai/domain/entities/auth_user.dart';
import 'package:passai/domain/repositories/auth_repository.dart';

/// Implementação concreta do [AuthRepository].
///
/// Princípio DIP: esta classe implementa a abstração do domínio
/// e depende do datasource (detalhe de infra), nunca o contrário.
/// Princípio SRP: apenas adapta chamadas entre domínio e datasource.
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._datasource);

  final AuthRemoteDatasource _datasource;

  @override
  Future<AuthUser> login({
    required String email,
    required String senha,
  }) =>
      _datasource.login(email: email, senha: senha);

  @override
  Future<AuthUser> cadastro({
    required String nome,
    required String email,
    required String telefone,
    required String senha,
  }) =>
      _datasource.cadastro(
        nome: nome,
        email: email,
        telefone: telefone,
        senha: senha,
      );

  @override
  Future<void> logout() => _datasource.logout();

  @override
  AuthUser? get usuarioAtual => _datasource.usuarioAtual;
}
