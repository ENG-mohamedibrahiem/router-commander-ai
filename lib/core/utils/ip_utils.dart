import 'dart:io';

import 'package:router_commander_ai/core/config/app_constants.dart';

/// Utility functions for IP address handling and gateway detection.
abstract final class IpUtils {
  /// Returns true if [ip] is a valid IPv4 address.
  static bool isValidIpV4(String ip) {
    final parts = ip.split('.');
    if (parts.length != 4) return false;
    return parts.every((p) {
      final n = int.tryParse(p);
      return n != null && n >= 0 && n <= 255;
    });
  }

  /// Probes each candidate gateway in [AppConstants.defaultGatewaysCandidates]
  /// and returns the first one that accepts a TCP connection on port 80.
  /// Returns null if no gateway responds within the timeout.
  static Future<String?> detectActiveGateway() async {
    for (final ip in AppConstants.defaultGatewaysCandidates) {
      if (await _canReach(ip)) return ip;
    }
    return null;
  }

  /// Returns true if [host] accepts a TCP connection on [port] within timeout.
  static Future<bool> canReachHost(
    String host, {
    int port = 80,
    Duration timeout = const Duration(
      milliseconds: AppConstants.gatewayProbeTimeoutMs,
    ),
  }) =>
      _canReach(host, port: port, timeout: timeout);

  // ── private ──────────────────────────────────────────────────────────────

  static Future<bool> _canReach(
    String host, {
    int port = 80,
    Duration timeout = const Duration(
      milliseconds: AppConstants.gatewayProbeTimeoutMs,
    ),
  }) async {
    try {
      final socket = await Socket.connect(
        host,
        port,
        timeout: timeout,
      );
      socket.destroy();
      return true;
    } catch (_) {
      return false;
    }
  }
}
