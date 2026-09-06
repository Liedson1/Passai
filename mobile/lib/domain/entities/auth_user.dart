/// Entidade de domínio que representa um usuário autenticado.
/// Imutável, sem dependência de frameworks externos.
class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    this.nome,
    this.telefone,
  });

  /// Identificador único do usuário (UUID do Supabase Auth).
  final String id;

  /// E-mail do usuário — utilizado como credencial de acesso.
  final String email;

  /// Nome completo, opcional (preenchido no cadastro).
  final String? nome;

  /// Telefone, opcional (preenchido no cadastro).
  final String? telefone;

  @override
  String toString() => 'AuthUser(id: $id, email: $email, nome: $nome)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthUser &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email;

  @override
  int get hashCode => id.hashCode ^ email.hashCode;
}
