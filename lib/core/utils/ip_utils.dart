import 'dart:io';

/// IP address utilities — gateway detection and validation.
abstract final class IpUtils {
  static final _ipv4Regex = RegExp(
      r'^((25[0-5]|2[0-4]\d|[01]?\d\d?)\.){3}(25[0-5]|2[0-4]\d|[01]?\d\d?)$');

  /// Returns true if [address] is a syntactically valid IPv4 string.
  static bool isValidIpv4(String address) =>
      _ipv4Regex.hasMatch(address);

  /// Derives the likely gateway from an interface IP by replacing the
  /// last octet with `.1`.
  ///
  /// Example: `192.168.1.105` → `192.168.1.1`
  static String? deriveGateway(String interfaceIp) {
    if (!isValidIpv4(interfaceIp)) return null;
    final parts = interfaceIp.split('.');
    return '${parts[0]}.${parts[1]}.${parts[2]}.1';
  }

  /// Attempts to detect the default gateway by iterating [NetworkInterface]s.
  ///
  /// Returns `null` when detection is not possible (e.g. on web).
  static Future<String?> detectGateway() async {
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLinkLocal: false,
      );
      for (final iface in interfaces) {
        for (final addr in iface.addresses) {
          if (!addr.isLoopback &&
              !addr.isLinkLocal &&
              !addr.isMulticast) {
            final gw = deriveGateway(addr.address);
            if (gw != null) return gw;
          }
        }
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  /// Normalises a host input: strips protocol prefix, trailing slashes.
  /// Returns just the IP or hostname.
  ///
  /// Example: `"http://192.168.1.1/"` → `"192.168.1.1"`
  static String normaliseHost(String raw) {
    var s = raw.trim();
    s = s.replaceFirst(RegExp(r'^https?://'), '');
    s = s.replaceAll(RegExp(r'/.*$'), '');
    return s;
  }
}
