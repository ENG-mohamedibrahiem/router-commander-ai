import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:router_commander_ai/core/config/app_constants.dart';
import 'package:router_commander_ai/core/errors/app_exception.dart';

/// Singleton Dio instance with:
///  - Configured timeouts
///  - Mandatory Referer header (required by ZTE firmware)
///  - Retry interceptor (up to [AppConstants.maxRetries])
///  - Error-mapping interceptor (DioException → AppException)
class DioClient {
  DioClient._({required String baseUrl}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout:
            const Duration(milliseconds: AppConstants.connectTimeoutMs),
        receiveTimeout:
            const Duration(milliseconds: AppConstants.receiveTimeoutMs),
        sendTimeout:
            const Duration(milliseconds: AppConstants.sendTimeoutMs),
        // ZTE firmware requires Referer on every request — VERIFIED.
        headers: <String, String>{
          'Referer': baseUrl,
          'Accept': '*/*',
        },
        // Disable auto-throw so our interceptor handles all status codes.
        validateStatus: (_) => true,
      ),
    )
      ..httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: () {
          final client = HttpClient();
          client.badCertificateCallback =
              (X509Certificate cert, String host, int port) => true;
          return client;
        },
      )
      ..interceptors.add(_RetryInterceptor(_dio!))
      ..interceptors.add(LogInterceptor(
        requestBody: false,
        responseBody: false,
        logPrint: (o) => _log(o.toString()),
      ));
  }

  Dio? _dio;

  Dio get dio => _dio!;

  factory DioClient.forBaseUrl(String baseUrl) => DioClient._(baseUrl: baseUrl);

  /// Perform GET, mapping network errors to [AppException].
  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) =>
      _execute(() => _dio!.get<dynamic>(path, queryParameters: queryParameters));

  /// Perform POST, mapping network errors to [AppException].
  Future<Response<dynamic>> post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      _execute(
        () => _dio!.post<dynamic>(
          path,
          data: data,
          queryParameters: queryParameters,
          options: options,
        ),
      );

  Future<Response<dynamic>> _execute(
    Future<Response<dynamic>> Function() call,
  ) async {
    try {
      final response = await call();
      return response;
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (e) {
      throw UnknownException(message: e.toString());
    }
  }

  static AppException _mapDioException(DioException e) => switch (e.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.receiveTimeout =>
          TimeoutException(
            message: 'Request timed out: ${e.requestOptions.path}',
          ),
        DioExceptionType.badResponse => e.response?.statusCode == 401
            ? AuthException(
                message: 'Authentication failed',
              )
            : HttpStatusException(
                message:
                    'HTTP ${e.response?.statusCode}: ${e.requestOptions.path}',
                statusCode: e.response?.statusCode ?? 500,
              ),
        DioExceptionType.connectionError => NetworkException(
            message: 'Cannot connect to router: ${e.requestOptions.baseUrl}',
          ),
        _ => UnknownException(message: e.message ?? 'Unknown Dio error'),
      };

  static void _log(String message) {
    // ignore: avoid_print
    assert(() {
      // Only log in debug mode.
      // Replace with logger service when integrated.
      // ignore: avoid_print
      print('[DioClient] $message');
      return true;
    }());
  }
}

/// Retry interceptor — exponential back-off up to [AppConstants.maxRetries].
class _RetryInterceptor extends Interceptor {
  _RetryInterceptor(this._dio);
  final Dio _dio;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    var attempt = err.requestOptions.extra['_retryCount'] as int? ?? 0;

    final isRetryable = err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError;

    if (isRetryable && attempt < AppConstants.maxRetries) {
      attempt++;
      final delay = AppConstants.retryBaseDelayMs * (1 << (attempt - 1));
      await Future<void>.delayed(Duration(milliseconds: delay));

      final options = err.requestOptions
        ..extra['_retryCount'] = attempt;
      try {
        final response = await _dio.fetch<dynamic>(options);
        return handler.resolve(response);
      } catch (e) {
        // Fall through to super handler on final attempt.
      }
    }
    return handler.next(err);
  }
}
