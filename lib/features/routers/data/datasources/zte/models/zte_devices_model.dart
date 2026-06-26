import 'dart:convert';
import '../../../../../domain/entities/connected_device.dart';

/// Parses the ZTE host_info JSON blob into a list of [ConnectedDevice].
///
/// The ZTE router encodes connected-device data as a JSON-encoded string
/// inside the `host_info` field. Classification: VERIFIED on MF297D.
///
/// Field map (VERIFIED unless noted):
///   HostName    → hostname
///   ip_addr     → ipAddress
///   mac_addr    → macAddress (ASSUMED field name, verify on device)
///   isActive    → isActive (ASSUMED)
final class ZteDevicesModel {
  const ZteDevicesModel(this.devices);

  final List<ConnectedDevice> devices;

  factory ZteDevicesModel.fromJson(Map<String, dynamic> json) {
    final raw = json['host_info'];
    if (raw == null || raw.toString().isEmpty) {
      return const ZteDevicesModel([]);
    }

    try {
      // ZTE encodes device list as a JSON array string inside host_info.
      final decoded = raw is String ? jsonDecode(raw) : raw;
      if (decoded is! List) return const ZteDevicesModel([]);

      final devices = decoded
          .whereType<Map<String, dynamic>>()
          .map(_parseDevice)
          .whereType<ConnectedDevice>()
          .toList();

      return ZteDevicesModel(devices);
    } catch (_) {
      return const ZteDevicesModel([]);
    }
  }

  List<ConnectedDevice> toEntityList() => devices;

  static ConnectedDevice? _parseDevice(Map<String, dynamic> d) {
    final ip = _str(d['ip_addr']);
    if (ip == null) return null; // IP is minimum viable data.
    return ConnectedDevice(
      hostname: _str(d['HostName']),
      ipAddress: ip,
      macAddress: _str(d['mac_addr']),
      isActive: d['isActive']?.toString() == '1',
    );
  }

  static String? _str(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }
}
