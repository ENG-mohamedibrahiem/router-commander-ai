import '../entities/router_endpoint.dart';
import '../entities/router_session.dart';

/// Domain contract for session persistence with TTL (Option C).
///
/// Implementations may use Hive, SharedPreferences, or in-memory storage.
/// The domain layer depends only on this interface.
abstract interface class SessionStorageContract {
  /// Persists [session] associated with [endpoint].
  ///
  /// Overwrites any existing entry for the same endpoint.
  Future<void> save(RouterEndpoint endpoint, RouterSession session);

  /// Loads the cached session for [endpoint].
  ///
  /// Returns null if no session exists, the session has expired
  /// ([RouterSession.isExpired] == true), or the stored data is corrupted.
  Future<RouterSession?> load(RouterEndpoint endpoint);

  /// Removes the cached session for [endpoint].
  Future<void> invalidate(RouterEndpoint endpoint);

  /// Removes all cached sessions.
  Future<void> invalidateAll();
}
