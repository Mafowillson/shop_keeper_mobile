sealed class Failure {
  final String message;
  const Failure(this.message);
}

final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network error.']);
}

final class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error.']);
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Not found.']);
}

final class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

final class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Auth failed.']);
}

final class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error.']);
}