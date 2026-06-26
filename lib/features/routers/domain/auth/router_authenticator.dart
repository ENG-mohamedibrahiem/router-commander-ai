import '../entities/router_credentials.dart';
import '../entities/router_endpoint.dart';
import '../entities/router_session.dart';

/// Domain contract for authenticating against a router.
///
/// Every brand adapter must implement this interface. The domain layer
/// only calls this — it never references Dio, HTTP, or any data class.
abstract interface class RouterAuthenticator {
  Future<RouterSession> login({
    required RouterEndpoint endpoint,
    required RouterCredentials credentials,
  });

  Future<void> logout(RouterSession session);
}
