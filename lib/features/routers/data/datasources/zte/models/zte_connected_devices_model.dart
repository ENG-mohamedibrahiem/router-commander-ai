import '../../../../../../features/routers/domain/entities/connected_device.dart';
import '../protocol/zte_protocol_constants.dart';

/// ZTE connected-devices field constants.
///
/// classification: VERIFIED — 'host_info' confirmed on MF297D packet captures.
/// Each entry is a comma-delimited string: hostname,mac,ip,conn_type,lease
const String kZteFieldHostInfo = 'host_info';

/// classification: ASSUMED — entry delimiter observed as newline on MF297D.
/// fallback: try both '\n' and '\r\n'; split result filtered of empty strings.
const String kZteHostEntrySeparator = '\n';

/// classification: VERIFIED — field order: hostname,mac,ip,conn_type,lease_time
const int kZteHostFieldCount = 5;
const int _kIdxHostname = 0;
const int _kIdxMac = 1;
const int _kIdxIp = 2;
const int _kIdxConnType = 3;

const List<String> kZteConnectedDevicesCmds = [kZteFieldHostInfo];

final class ZteConnectedDevicesModel {
  const ZteConnectedDevicesModel._();

  static List<ConnectedDevice> fromMap(Map<String, dynamic> map) {
    final raw = map[kZteFieldHostInfo];
    if (raw == null || raw.toString() == kZteUnavailableValue) return [];

    final lines = raw
        .toString()
        .split(kZteHostEntrySeparator)
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    final devices = <ConnectedDevice>[];
    for (final line in lines) {
      final parts = line.split(',');
      if (parts.length < kZteHostFieldCount) continue;
      final mac = parts[_kIdxMac].trim();
      final ip = parts[_kIdxIp].trim();
      if (mac.isEmpty && ip.isEmpty) continue;
      devices.add(
        ConnectedDevice(
          hostname: _nullIfEmpty(parts[_kIdxHostname].trim()),
          macAddress: _nullIfEmpty(mac),
          ipAddress: _nullIfEmpty(ip),
          connectionType: _nullIfEmpty(parts[_kIdxConnType].trim()),
        ),
      );
    }
    return devices;
  }

  static String? _nullIfEmpty(String s) => s.isEmpty ? null : s;
}
