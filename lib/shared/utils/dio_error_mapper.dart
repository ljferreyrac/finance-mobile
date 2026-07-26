import 'package:dio/dio.dart';

import '../models/failure.dart';

/// Maps a [DioException] to a typed [Failure], preferring the backend's
/// RFC 7807 ProblemDetail `detail` field (falling back to `message`) when the
/// response body is JSON.
///
/// Single shared implementation for every repository's `_run`/try-catch
/// wrapper, so error classification does not silently drift per feature.
Failure mapDioError(DioException e) {
  if (e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.receiveTimeout ||
      e.type == DioExceptionType.connectionError) {
    return const NetworkFailure();
  }
  final status = e.response?.statusCode;
  if (status == 401 || status == 403) return const UnauthorizedFailure();
  if (status == 404) return const NotFoundFailure();
  final body = e.response?.data;
  final message = (body is Map)
      ? ((body['detail'] ?? body['message']) as String? ??
          e.message ??
          'Error del servidor')
      : (e.message ?? 'Error del servidor');
  return ServerFailure(message, statusCode: status);
}
