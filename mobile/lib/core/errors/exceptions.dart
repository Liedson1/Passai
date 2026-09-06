/// Exceções customizadas da aplicação Passaí
library;

/// Lançada quando não há conexão ativa com a internet ou ocorre timeout de rede.
class NetworkException implements Exception {
  const NetworkException([
    this.message =
        'Sem conexão com a internet. O Passaí precisa de conexão ativa para consultar os horários em tempo real.',
  ]);

  final String message;

  @override
  String toString() => message;
}

/// Lançada em caso de erro interno de servidor ou resposta inesperada da API.
class ServerException implements Exception {
  const ServerException([
    this.message = 'Ocorreu um erro no servidor. Tente novamente mais tarde.',
  ]);

  final String message;

  @override
  String toString() => message;
}
