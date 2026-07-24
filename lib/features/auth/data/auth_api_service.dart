import 'package:dio/dio.dart';
import '../../../core/api/dio_client.dart';
import '../models/auth_model.dart';

/// Raw HTTP calls against the authentication API endpoints.
///
/// All paths are relative to the [DioClient] baseUrl (`/api/v1`).
/// Throws [DioException] on non-2xx responses; the repository converts
/// those into typed [Failure] objects.
class AuthApiService {
  AuthApiService({Dio? dio}) : _dio = dio ?? DioClient.instance;

  final Dio _dio;

  static const _basePath = '/auth';

  Future<AuthResponse> register({
    required String email,
    required String password,
    required String fullName,
    String currency = 'PEN',
    String? timezone,
  }) async {
    final body = <String, dynamic>{
      'email': email,
      'password': password,
      'fullName': fullName,
      'currency': currency,
      if (timezone != null) 'timezone': timezone,
    };
    final response = await _dio.post<Map<String, dynamic>>(
      '$_basePath/register',
      data: body,
    );
    return AuthResponse.fromJson(response.data!);
  }

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final body = <String, dynamic>{
      'email': email,
      'password': password,
    };
    final response = await _dio.post<Map<String, dynamic>>(
      '$_basePath/login',
      data: body,
    );
    return AuthResponse.fromJson(response.data!);
  }

  Future<AuthResponse> refresh({required String refreshToken}) async {
    final body = <String, dynamic>{'refreshToken': refreshToken};
    final response = await _dio.post<Map<String, dynamic>>(
      '$_basePath/refresh',
      data: body,
    );
    return AuthResponse.fromJson(response.data!);
  }

  /// Invalidates the refresh token on the server (best-effort).
  Future<void> logout({required String refreshToken}) async {
    final body = <String, dynamic>{'refreshToken': refreshToken};
    await _dio.post<void>('$_basePath/logout', data: body);
  }
}
