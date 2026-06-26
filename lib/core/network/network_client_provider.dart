import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:router_commander_ai/core/network/dio_client.dart';

/// Provides a [DioClient] scoped to a specific [baseUrl].
/// Consumers must override this provider with the router's base URL
/// (e.g., 'http://192.168.1.1') before making any requests.
///
/// Usage:
/// ```dart
/// final container = ProviderContainer(
///   overrides: [
///     dioClientProvider('http://192.168.1.1'),
///   ],
/// );
/// ```
DioClient dioClientForUrl(String baseUrl) => DioClient.forBaseUrl(baseUrl);

/// Family provider — one DioClient per base URL.
/// Riverpod caches by [baseUrl] string.
final dioClientProvider =
    Provider.family.autoDispose<DioClient, String>((ref, baseUrl) {
  return DioClient.forBaseUrl(baseUrl);
});
