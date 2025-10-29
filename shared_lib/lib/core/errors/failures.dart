abstract class Failure {
  final String message;
  final Object? error;

  const Failure({required this.message, this.error});
}

class FirebaseFailure extends Failure {
  const FirebaseFailure({required String message, Object? error})
      : super(message: message, error: error);
}

class AuthFailure extends Failure {
  const AuthFailure({required String message, Object? error})
      : super(message: message, error: error);
}

class AuthorizationFailure extends Failure {
  const AuthorizationFailure({required String message, Object? error})
      : super(message: message, error: error);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({required String message, Object? error})
      : super(message: message, error: error);
}