class RouterEndpoint {
  const RouterEndpoint({
    required this.baseUri,
    this.displayName,
  });

  factory RouterEndpoint.fromHost(
    String host, {
    bool secure = false,
    int? port,
    String? displayName,
  }) {
    final scheme = secure ? 'https' : 'http';

    return RouterEndpoint(
      baseUri: Uri(
        scheme: scheme,
        host: host,
        port: port ?? (secure ? 443 : 80),
      ),
      displayName: displayName,
    );
  }

  final Uri baseUri;
  final String? displayName;

  String get host => baseUri.host;

  RouterEndpoint normalize() {
    final normalizedPath = baseUri.path == '/' ? '' : baseUri.path;

    return RouterEndpoint(
      baseUri: baseUri.replace(path: normalizedPath, query: ''),
      displayName: displayName,
    );
  }
}
