import 'package:dio/dio.dart';

import 'package:router_commander_ai/core/errors/app_exception.dart';
import 'package:router_commander_ai/features/routers/domain/entities/router_endpoint.dart';
import 'auth/zte_authentication_strategy.dart';

/// Concrete [ZteHttpClient] implementation backed by [Dio].
///
/// This client:
/// - Constructs URLs from [RouterEndpoint.baseUri]
/// - Forwards query parameters
/// - Automatically attaches `Referer` when not provided
/// - Maps Dio exceptions to typed [AppException] subclasses
/// - Extracts `Set-Cookie` from response headers for auth flows
final class ZteDioHttpClient implements ZteHttpClient {
  const ZteDioHttpClient({required this._dio});

  final Dio _dio;

  @override
  Future<Map<String, dynamic>> get(
    RouterEndpoint endpoint,
    String path, {
    required Map<String, String> queryParams,
    Map<String, String>? headers,
  }) async {
    final uri = '${endpoint.baseUri}$path';
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        uri,
        queryParameters: queryParams,
        options: Options(
          headers: {
            'Referer': endpoint.baseUri,
            ...?headers,
          },
          responseType: ResponseType.json,
        ),
      );
      final data = response.data;
      if (data == null) {
        throw ParseException(
          message: 'ZTE GET $path returned null body.',
          rawBody: null,
        );
      }
      return data;
    } on DioException catch (e) {
      throw _mapDioException(e, path);
    }
  }

  @override
  Future<ZtePostResult> post(
    RouterEndpoint endpoint,
    String path, {
    required String body,
    required Map<String, String> headers,
  }) async {
    final uri = '${endpoint.baseUri}$path';
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        uri,
        data: body,
        options: Options(
          headers: {
            'Referer': endpoint.baseUri,
            ...headers,
          },
          responseType: ResponseType.json,
        ),
      );

      final responseData = response.data ?? {};
      final setCookie =
          response.headers.value('set-cookie');

      return ZtePostResult(
        body: responseData,
        setCookieHeader: setCookie,
      );
    } on DioException catch (e) {
      throw _mapDioException(e, path);
    }
  }

  // -------------------------------------------------------------------------
  // Private helpers
  // -------------------------------------------------------------------------

  AppException _mapDioException(DioException e, String path) {
    return switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
          TimeoutException(
            message:
                'ZTE request timed out on $path (${e.type.name}).',
            cause: e,
            timeoutMs: _dio.options.connectTimeout?.inMilliseconds,
          ),
      DioExceptionType.badResponse => HttpStatusException(
          message:
              'ZTE HTTP ${e.response?.statusCode} on $path.',
          statusCode: e.response?.statusCode ?? 0,
          cause: e,
        ),
      DioExceptionType.connectionError => NetworkException(
          message:
              'Cannot reach ZTE router at $path: ${e.message}',
          cause: e,
        ),
      _ => NetworkException(
          message: 'Dio error on ZTE $path: ${e.message}',
          cause: e,
        ),
    };
  }
}
