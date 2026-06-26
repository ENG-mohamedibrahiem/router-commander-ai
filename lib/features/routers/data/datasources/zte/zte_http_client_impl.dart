import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../../domain/entities/router_endpoint.dart';
import '../../../../../../../core/errors/app_exception.dart';
import '../../../../../../core/network/dio_client.dart';
import '../auth/zte_authentication_strategy.dart';
import '../protocol/zte_protocol_constants.dart';

/// Dio-backed implementation of [ZteHttpClient].
///
/// Handles the ZTE-specific quirks:
///   - Mandatory `Referer` header on every request (VERIFIED)
///   - Form-encoded POST body (VERIFIED)
///   - Raw `Set-Cookie` header capture for session extraction (VERIFIED)
final class ZteHttpClientImpl implements ZteHttpClient {
  const ZteHttpClientImpl(this._dio);

  final Dio _dio;

  @override
  Future<Map<String, dynamic>> get(
    RouterEndpoint endpoint,
    String path, {
    required Map<String, String> queryParams,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = '${endpoint.baseUri}$path';
      final response = await _dio.get<String>(
        uri,
        queryParameters: queryParams,
        options: Options(
          headers: {
            'Referer': '${endpoint.baseUri}$kZteRefererSuffix',
            ...?headers,
          },
          responseType: ResponseType.plain,
        ),
      );
      final data = response.data;
      if (data == null || data.isEmpty) {
        throw const ParseException(message: 'ZTE GET returned empty body.');
      }
      return jsonDecode(data) as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _mapDio(e);
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
      final uri = '${endpoint.baseUri}$path';
      final response = await _dio.post<String>(
        uri,
        data: body,
        options: Options(
          headers: {
            'Referer': '${endpoint.baseUri}$kZteRefererSuffix',
            ...headers,
          },
          responseType: ResponseType.plain,
          // Preserve raw headers so we can extract Set-Cookie.
          validateStatus: (_) => true,
        ),
      );

      final rawData = response.data;
      if (rawData == null || rawData.isEmpty) {
        throw const ParseException(message: 'ZTE POST returned empty body.');
      }

      final setCookie = response.headers
          .map[kZteSetCookieHeader]
          ?.join('; ');

      return ZtePostResult(
        body: jsonDecode(rawData) as Map<String, dynamic>,
        setCookieHeader: setCookie,
      );
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  AppException _mapDio(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return TimeoutException(
          message: 'ZTE request timed out: ${e.message}', cause: e);
    }
    if (e.type == DioExceptionType.connectionError) {
      return NetworkException(
          message: 'Cannot reach ZTE router: ${e.message}', cause: e);
    }
    return NetworkException(
        message: 'ZTE HTTP error: ${e.message}', cause: e);
  }
}
