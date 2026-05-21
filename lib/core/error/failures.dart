/// Base failure class
abstract class Failure {
  final String message;

  Failure({required this.message});
}

/// General failure
class GeneralFailure extends Failure {
  GeneralFailure({required String message}) : super(message: message);
}

/// Network failure
class NetworkFailure extends Failure {
  NetworkFailure({required String message}) : super(message: message);
}

/// Server failure
class ServerFailure extends Failure {
  ServerFailure({required String message}) : super(message: message);
}

/// Cache failure
class CacheFailure extends Failure {
  CacheFailure({required String message}) : super(message: message);
}
