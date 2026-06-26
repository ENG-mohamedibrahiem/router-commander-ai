/// Represents the network address of a specific router.
///
/// [cacheKey] is used by [SessionStorageContract] implementations
/// to key persisted sessions.
class RouterEndpoint {
  const RouterEndpoint({
    required this.host,
    this.port = 80,
    this.useHttps = false,
  });

  final String host;
  final int port;
  final bool useHttps;

  String get scheme => useHttps ? 'https' : 'http';

  /// Base URI without trailing slash.
  String get baseUri {
    final portSuffix =
        (useHttps && port == 443) || (!useHttps && port == 80)
            ? ''
            : ':$port';
    return '$scheme://$host$portSuffix';
  }

  /// Stable key for session caching — excludes scheme to tolerate
  /// http↔https switches on the same physical host.
  String get cacheKey => '$host:$port';

  @override
  String toString() => baseUri;

  @override
  bool operator ==(Object other) =>
      other is RouterEndpoint &&
      host == other.host &&
      port == other.port &&
      useHttps == other.useHttps;

  @override
  int get hashCode => Object.hash(host, port, useHttps);
}
