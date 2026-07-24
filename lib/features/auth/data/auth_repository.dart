import 'package:dio/dio.dart';
import '../../../core/services/token_storage.dart';
import '../../../shared/models/failure.dart';
import '../models/auth_model.dart';
import 'auth_api_service.dart';

abstract class AuthRepository {
  Future<AuthResponse> register({
    required String email,
    required String password,
    required String fullName,
    String currency = 'PEN',
    String? timezone,
  });

  Future<AuthResponse> login({
    required String email,
    required String password,
  });

  Future<AuthResponse> refresh({required String refreshToken});

  Future<void> logout({required String refreshToken});
}

/// Default implementation backed by [AuthApiService].
///
/// Tokens are persisted via [TokenStorage] right after a successful login or
/// register, so subsequent requests are automatically authenticated.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    AuthApiService? apiService,
    TokenStorage? tokenStorage,
  })  : _api = apiService ?? AuthApiService(),
        _tokenStorage = tokenStorage ?? TokenStorage();

  final AuthApiService _api;
  final TokenStorage _tokenStorage;

  @override
  Future<AuthResponse> register({
    required String email,
    required String password,
    required String fullName,
    String currency = 'PEN',
    String? timezone,
  }) =>
      _run(() async {
        final response = await _api.register(
          email: email,
          password: password,
          fullName: fullName,
          currency: currency,
          timezone: timezone,
        );
        await _tokenStorage.saveTokens(
          response.accessToken,
          response.refreshToken,
        );
        return response;
      });

  @override
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) =>
      _run(() async {
        final response = await _api.login(email: email, password: password);
        await _tokenStorage.saveTokens(
          response.accessToken,
          response.refreshToken,
        );
        return response;
      });

  @override
  Future<AuthResponse> refresh({required String refreshToken}) =>
      _run(() async {
        final response = await _api.refresh(refreshToken: refreshToken);
        await _tokenStorage.saveTokens(
          response.accessToken,
          response.refreshToken,
        );
        return response;
      });

  @override
  Future<void> logout({required String refreshToken}) async {
    try {
      await _api.logout(refreshToken: refreshToken);
    } catch (_) {
      // Ignored: tokens are cleared below regardless of server response.
    } finally {
      await _tokenStorage.clearTokens();
    }
  }

  /// Wraps [action] and maps [DioException] to a typed [Failure].
  Future<T> _run<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on DioException catch (e) {
      throw _mapDioError(e);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  Failure _mapDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return const NetworkFailure();
    }
    final status = e.response?.statusCode;
    if (status == 401) return const UnauthorizedFailure();
    if (status == 403) return const UnauthorizedFailure();
    if (status == 404) return const NotFoundFailure();
    final message = e.response?.data?['message'] as String? ??
        e.message ??
        'Error del servidor';
    return ServerFailure(message, statusCode: status);
  }
}
