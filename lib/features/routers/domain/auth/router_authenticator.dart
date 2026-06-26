import '../entities/router_credentials.dart';
import '../entities/router_endpoint.dart';
import '../entities/router_session.dart';

/// Domain contract for any router authentication strategy.
abstract interface class RouterAuthenticator {
  /// Authenticates with the router and returns a live [RouterSession].
  ///
  /// Throws a subclass of [AppException] on failure.
  Future<RouterSession> login({
    required RouterEndpoint endpoint,
    required RouterCredentials credentials,
  });
}
