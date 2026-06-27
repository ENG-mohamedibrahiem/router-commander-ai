import 'package:router_commander_ai/features/routers/domain/entities/router_credentials.dart';
import 'package:router_commander_ai/features/routers/domain/entities/router_endpoint.dart';
import 'package:router_commander_ai/features/routers/domain/entities/router_session.dart';

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
