import 'router_endpoint.dart';
import 'router_model.dart';

class RouterSession {
  const RouterSession({
    required this.id,
    required this.endpoint,
    required this.model,
    required this.createdAt,
    this.expiresAt,
    this.authToken,
    this.cookieHeader,
    this.metadata = const {},
  });

  final String id;
  final RouterEndpoint endpoint;
  final RouterModel model;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final String? authToken;
  final String? cookieHeader;
  final Map<String, String> metadata;

  bool get isExpired {
    final expiresAt = this.expiresAt;
    return expiresAt != null && !DateTime.now().isBefore(expiresAt);
  }

  RouterSession copyWith({
    String? id,
    RouterEndpoint? endpoint,
    RouterModel? model,
    DateTime? createdAt,
    DateTime? expiresAt,
    String? authToken,
    String? cookieHeader,
    Map<String, String>? metadata,
  }) {
    return RouterSession(
      id: id ?? this.id,
      endpoint: endpoint ?? this.endpoint,
      model: model ?? this.model,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      authToken: authToken ?? this.authToken,
      cookieHeader: cookieHeader ?? this.cookieHeader,
      metadata: metadata ?? this.metadata,
    );
  }
}
