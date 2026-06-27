import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:router_commander_ai/core/config/app_constants.dart';

/// Provides the singleton [Dio] instance configured for router communication.
///
/// Timeout values are read from [AppConstants] so they can be tuned
/// centrally without touching this file.
final networkClientProvider = Provider<Dio>((ref) {
  final options = BaseOptions(
    connectTimeout:
        const Duration(milliseconds: AppConstants.connectTimeoutMs),
    sendTimeout:
        const Duration(milliseconds: AppConstants.sendTimeoutMs),
    receiveTimeout:
        const Duration(milliseconds: AppConstants.receiveTimeoutMs),
    headers: {
      'Accept': 'application/json, text/javascript, */*; q=0.01',
      'X-Requested-With': 'XMLHttpRequest',
    },
    validateStatus: (status) => status != null && status < 500,
  );

  final dio = Dio(options);

  // -------------------------------------------------------------------------
  // Interceptors
  // -------------------------------------------------------------------------

  // 1. Request/response logging (debug only).
  assert(() {
    dio.interceptors.add(
      LogInterceptor(
        requestBody: false,
        responseBody: false,
        logPrint: (obj) => _log(obj.toString()),
      ),
    );
    return true;
  }());

  return dio;
});

void _log(String message) {
  // ignore: avoid_print
  print('[Dio] $message');
}
