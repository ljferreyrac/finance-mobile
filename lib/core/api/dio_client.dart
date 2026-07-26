import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';
import '../services/token_storage.dart';

/// Shared Dio instance used by all API services.
///
/// [_AuthInterceptor] injects the Bearer token and silently refreshes it on
/// 401, retrying the original request; if refresh fails it emits
/// [DioClient.onSessionExpired] so the app can redirect to login.
class DioClient {
  DioClient._();

  static Dio? _instance;

  // Emits once the session can no longer be recovered (refresh token expired
  // or missing); listeners should redirect to login.
  static final StreamController<void> _sessionExpiredController =
      StreamController<void>.broadcast();

  static Stream<void> get onSessionExpired => _sessionExpiredController.stream;

  static Dio get instance {
    _instance ??= _build();
    return _instance!;
  }

  static Dio _build() {
    final dio = Dio(
      BaseOptions(
        baseUrl: apiV1,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    dio.interceptors.add(_AuthInterceptor(TokenStorage(), dio));
    // Debug-only logging; headers/bodies are never logged since they can hold
    // the auth token, plaintext passwords, or financial data.
    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        requestHeader: false,
        requestBody: false,
        responseHeader: false,
        responseBody: false,
        error: true,
        logPrint: (o) => debugPrint('[DioClient] $o'),
      ));
    }
    return dio;
  }

  /// Replaces the singleton - useful in tests to inject a mock [Dio].
  static void overrideWith(Dio dio) => _instance = dio;

  /// Extracts a human-readable message from a [DioException], preferring the
  /// RFC 7807 `detail`/`title` fields before falling back to Dio's message.
  static String errorMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      final detail = data['detail'];
      if (detail is String && detail.isNotEmpty) return detail;
      final title = data['title'];
      if (title is String && title.isNotEmpty) return title;
    }
    return e.message ?? 'Error al conectar con el servidor.';
  }

  static void _notifySessionExpired() {
    if (!_sessionExpiredController.isClosed) {
      _sessionExpiredController.add(null);
    }
  }
}

/// Injects the stored Bearer token into every request.
///
/// On 401/403 it refreshes the token via a clean Dio instance (no
/// interceptors, to avoid recursive loops), retries the original request, and
/// only expires the session if the refresh itself fails.
class _AuthInterceptor extends Interceptor {
  _AuthInterceptor(this._tokenStorage, this._mainDio);

  final TokenStorage _tokenStorage;
  final Dio _mainDio;

  bool _isRefreshing = false;

  // Requests queued while a refresh is in flight; each completer resolves
  // with the new token or rejects, so all waiters retry or fail together.
  final List<Completer<String>> _queue = [];

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final status = err.response?.statusCode;
    // Only intercept 401. The backend's 403 means an authenticated user
    // hitting a resource they don't own (UnauthorizedAccessException), not
    // an expired token - refreshing would just burn a rotation for nothing.
    if (status != 401) {
      handler.next(err);
      return;
    }

    // A refresh is already running, queue this request and wait.
    if (_isRefreshing) {
      final completer = Completer<String>();
      _queue.add(completer);
      try {
        final newToken = await completer.future;
        err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
        try {
          final retryResponse = await _mainDio.fetch(err.requestOptions);
          handler.resolve(retryResponse);
        } on DioException catch (retryErr) {
          // Surface the retry's own failure, not the stale original 401.
          handler.next(retryErr);
        }
      } catch (_) {
        // Refresh failed; session already expired by the leading request.
        handler.next(err);
      }
      return;
    }

    _isRefreshing = true;
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        await _expireSession();
        _rejectQueue();
        handler.next(err);
        return;
      }

      // Use a clean Dio instance without interceptors to avoid recursive loops.
      final refreshDio = Dio(
        BaseOptions(
          baseUrl: apiV1,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 30),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      final String newAccessToken;
      final String newRefreshToken;
      try {
        final refreshResponse = await refreshDio.post<Map<String, dynamic>>(
          '/auth/refresh',
          data: {'refreshToken': refreshToken},
        );
        final data = refreshResponse.data!;
        newAccessToken = data['accessToken'] as String;
        newRefreshToken = data['refreshToken'] as String;
      } catch (_) {
        await _expireSession();
        _rejectQueue();
        handler.next(err);
        return;
      }

      await _tokenStorage.saveTokens(newAccessToken, newRefreshToken);

      _resolveQueue(newAccessToken);

      // Retry the original (leading) request.
      err.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
      try {
        final retryResponse = await _mainDio.fetch(err.requestOptions);
        handler.resolve(retryResponse);
      } on DioException catch (retryErr) {
        // Retry failed for a non-auth reason; do NOT expire the session, and
        // surface the retry's own failure rather than the stale original 401.
        handler.next(retryErr);
      }
    } finally {
      _isRefreshing = false;
    }
  }

  void _resolveQueue(String newToken) {
    for (final c in _queue) {
      c.complete(newToken);
    }
    _queue.clear();
  }

  void _rejectQueue() {
    for (final c in _queue) {
      c.completeError('session_expired');
    }
    _queue.clear();
  }

  Future<void> _expireSession() async {
    await _tokenStorage.clearTokens();
    DioClient._notifySessionExpired();
  }
}
