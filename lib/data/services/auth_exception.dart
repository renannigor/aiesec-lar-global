/// Uma classe de exceção personalizada para lidar com erros de autenticação do Firebase.
class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() => message;
}
