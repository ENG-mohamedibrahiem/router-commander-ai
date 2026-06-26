import 'package:dio/dio.dart';

import '../../../../../../core/errors/app_exception.dart';
import '../../../../../routers/domain/entities/router_endpoint.dart';
import 'auth/zte_authentication_strategy.dart';
import 'protocol/zte_protocol_constants.dart';

/// Dio-backed implementation of [ZteHttpClient].
///
/// Handles:
///  - Mandatory Referer header on every request (classification: VERIFIED)
///  - Raw Set-Cookie header extraction (classification: VERIFIED)
///  - DioException → AppException mapping
final class ZteDioHttpClient implements ZteHttpClient {
  ZteDioHttpClient({required Dio dio}) : _dio = dio;

  final Dio _dio;

  @override
  Future<Map<String, dynamic>> get(
    RouterEndpoint endpoint,
    String path, {
    required Map<String, String> queryParams,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '${endpoint.baseUri}$path',
        queryParameters: queryParams,
        options: Options(
          headers: {
            'Referer': '${endpoint.baseUri}$kZteRefererSuffix',
            ...?headers,
          },
          receiveDataWhenStatusError: true,
        ),
      );
      final data = response.data;
      if (data == null) {
        throw const ParseException(message: 'ZTE GET returned null body.');
      }
      return data;
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  @override
  Future<ZtePostResult> post(
    RouterEndpoint endpoint,
    String path, {
    required String body,
    required Map<String, String> headers,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '${endpoint.baseUri}$path',
        data: body,
        options: Options(
          headers: {
            'Referer': '${endpoint.baseUri}$kZteRefererSuffix',
            ...headers,
          },
          receiveDataWhenStatusError: true,
        ),
      );
      final data = response.data;
      if (data == null) {
        throw const ParseException(message: 'ZTE POST returned null body.');
      }
      final rawCookie =
          response.headers.value('set-cookie');
      return ZtePostResult(body: data, setCookieHeader: rawCookie);
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  AppException _mapDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return TimeoutException(
          message: 'ZTE request timed out: ${e.requestOptions.uri}',
          cause: e,
        );
      case DioExceptionType.connectionError:
        return NetworkException(
          message: 'Cannot reach ZTE router at ${e.requestOptions.baseUrl}',
          cause: e,
        );
      case DioExceptionType.badResponse:
        return HttpStatusException(
          message: 'ZTE returned HTTP ${e.response?.statusCode}',
          statusCode: e.response?.statusCode ?? 0,
          cause: e,
        );
      default:
        return NetworkException(
          message: 'ZTE network error: ${e.message}',
          cause: e,
        );
    }
  }
}
