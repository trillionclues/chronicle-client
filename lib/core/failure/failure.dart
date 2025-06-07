// Failures are errors which are not fatal, and can be handled by the application.

abstract class Failure {
  final String message;
  Failure({required this.message});
}

class AuthFailure extends Failure {
  AuthFailure({required super.message});
}

class CreateGameFailure extends Failure {
  CreateGameFailure({required super.message});
}

class GameFailure extends Failure {
  GameFailure({required super.message});
}
