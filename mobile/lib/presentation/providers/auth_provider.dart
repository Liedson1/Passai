import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:passai/data/datasources/auth_remote_datasource.dart';
import 'package:passai/data/repositories/auth_repository_impl.dart';
import 'package:passai/domain/entities/auth_user.dart';
import 'package:passai/domain/repositories/auth_repository.dart';
import 'package:passai/domain/usecases/cadastro_usecase.dart';
import 'package:passai/domain/usecases/login_usecase.dart';

// ---------------------------------------------------------------------------
// Providers de infraestrutura — espelham o padrão de rotas_provider.dart
// ---------------------------------------------------------------------------

/// Datasource remoto de auth — singleton compartilhado.
final authDatasourceProvider = Provider<AuthRemoteDatasource>(
  (_) => AuthRemoteDatasource(),
);

/// Repositório concreto — depende da abstração [AuthRepository].
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(ref.watch(authDatasourceProvider)),
);

/// Use case de login.
final loginUsecaseProvider = Provider<LoginUsecase>(
  (ref) => LoginUsecase(ref.watch(authRepositoryProvider)),
);

/// Use case de cadastro.
final cadastroUsecaseProvider = Provider<CadastroUsecase>(
  (ref) => CadastroUsecase(ref.watch(authRepositoryProvider)),
);

// ---------------------------------------------------------------------------
// Notifiers de estado
// ---------------------------------------------------------------------------

/// Estado do fluxo de login.
/// Usa [AsyncNotifier] para loading/error/data — padrão Riverpod 2.x.
class SignInNotifier extends AsyncNotifier<AuthUser?> {
  @override
  Future<AuthUser?> build() async {
    // Retorna o usuário da sessão ativa (se houver) sem fazer network call.
    return ref.read(authRepositoryProvider).usuarioAtual;
  }

  /// Executa o login via [LoginUsecase].
  /// Atualiza o estado para loading → success/error automaticamente.
  Future<void> login({
    required String email,
    required String senha,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return ref.read(loginUsecaseProvider).call(
            email: email,
            senha: senha,
          );
    });
  }
}

/// Provider do notifier de login.
final signInNotifierProvider =
    AsyncNotifierProvider<SignInNotifier, AuthUser?>(SignInNotifier.new);

/// Estado do fluxo de cadastro.
class SignUpNotifier extends AsyncNotifier<AuthUser?> {
  @override
  Future<AuthUser?> build() async => null;

  /// Executa o cadastro via [CadastroUsecase].
  Future<void> cadastro({
    required String nome,
    required String email,
    required String telefone,
    required String senha,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return ref.read(cadastroUsecaseProvider).call(
            nome: nome,
            email: email,
            telefone: telefone,
            senha: senha,
          );
    });
  }
}

/// Provider do notifier de cadastro.
final signUpNotifierProvider =
    AsyncNotifierProvider<SignUpNotifier, AuthUser?>(SignUpNotifier.new);
