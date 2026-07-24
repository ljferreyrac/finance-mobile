/// Repositories surface errors as [Failure] subclasses so BLoC handlers can
/// branch on the specific problem instead of catching raw exceptions.
abstract class Failure {
  const Failure(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, {this.statusCode});

  final int? statusCode;
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Sin conexion a internet']);
}

class ParseFailure extends Failure {
  const ParseFailure([super.message = 'Error al procesar la respuesta']);
}

/// A resource requested by ID was not found (404).
class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Recurso no encontrado']);
}

/// The current user is not authorized for the requested action (403).
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'No tienes permiso para esta accion']);
}

/// Validation error caught on the client before the request is sent.
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}
