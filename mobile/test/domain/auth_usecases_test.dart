import 'package:flutter_test/flutter_test.dart';
import 'package:passai/domain/entities/auth_user.dart';
import 'package:passai/domain/repositories/auth_repository.dart';
import 'package:passai/domain/usecases/cadastro_usecase.dart';
import 'package:passai/domain/usecases/login_usecase.dart';

class FakeAuthRepository implements AuthRepository {
  AuthUser? loggedUser;

  @override
  Future<AuthUser> login({
    required String email,
    required String senha,
  }) async {
    if (email == 'user@passai.com' && senha == '123456') {
      final user = AuthUser(id: '1', email: email, nome: 'Test User');
      loggedUser = user;
      return user;
    }
    throw const AuthException('E-mail ou senha incorretos.');
  }

  @override
  Future<AuthUser> cadastro({
    required String nome,
    required String email,
    required String telefone,
    required String senha,
  }) async {
    final user = AuthUser(
      id: '2',
      email: email,
      nome: nome,
      telefone: telefone,
    );
    loggedUser = user;
    return user;
  }

  @override
  Future<void> logout() async {
    loggedUser = null;
  }

  @override
  AuthUser? get usuarioAtual => loggedUser;
}

void main() {
  group('LoginUsecase', () {
    late FakeAuthRepository repo;
    late LoginUsecase usecase;

    setUp(() {
      repo = FakeAuthRepository();
      usecase = LoginUsecase(repo);
    });

    test('Deve autenticar com sucesso quando dados forem válidos', () async {
      final user = await usecase(
        email: 'user@passai.com',
        senha: '123456',
      );

      expect(user.id, '1');
      expect(user.email, 'user@passai.com');
    });

    test('Deve lançar AuthException quando e-mail for inválido', () async {
      expect(
        () => usecase(email: 'invalido', senha: '123456'),
        throwsA(isA<AuthException>().having(
          (e) => e.mensagem,
          'message',
          'Informe um e-mail válido.',
        )),
      );
    });

    test('Deve lançar AuthException quando senha tiver menos de 6 caracteres', () async {
      expect(
        () => usecase(email: 'user@passai.com', senha: '123'),
        throwsA(isA<AuthException>().having(
          (e) => e.mensagem,
          'message',
          'A senha deve ter pelo menos 6 caracteres.',
        )),
      );
    });
  });

  group('CadastroUsecase', () {
    late FakeAuthRepository repo;
    late CadastroUsecase usecase;

    setUp(() {
      repo = FakeAuthRepository();
      usecase = CadastroUsecase(repo);
    });

    test('Deve cadastrar com sucesso quando dados forem válidos', () async {
      final user = await usecase(
        nome: 'Maria Silva',
        email: 'maria@passai.com',
        telefone: '82999998888',
        senha: '123456',
      );

      expect(user.id, '2');
      expect(user.nome, 'Maria Silva');
      expect(user.email, 'maria@passai.com');
    });

    test('Deve lançar AuthException quando nome for muito curto', () async {
      expect(
        () => usecase(
          nome: 'M',
          email: 'maria@passai.com',
          telefone: '82999998888',
          senha: '123456',
        ),
        throwsA(isA<AuthException>().having(
          (e) => e.mensagem,
          'message',
          'Informe seu nome completo.',
        )),
      );
    });

    test('Deve lançar AuthException quando telefone for incompleto', () async {
      expect(
        () => usecase(
          nome: 'Maria Silva',
          email: 'maria@passai.com',
          telefone: '1234',
          senha: '123456',
        ),
        throwsA(isA<AuthException>().having(
          (e) => e.mensagem,
          'message',
          'Informe um telefone válido com DDD.',
        )),
      );
    });
  });
}
