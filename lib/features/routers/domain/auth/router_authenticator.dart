import '../entities/router_credentials.dart';
import '../entities/router_endpoint.dart';
import '../entities/router_session.dart';

abstract interface class RouterAuthenticator {
  Future<RouterSession> login({
    required RouterEndpoint endpoint,
    required RouterCredentials credentials,
  });

  Future<void> logout(RouterSession session);
}
