import '../../../../../domain/entities/router_device_info.dart';

/// Maps ZTE JSON response fields to [RouterDeviceInfo].
///
/// All fields are nullable — ZTE returns empty string "" for unavailable data.
/// Classification: VERIFIED fields from MF297D packet captures.
final class ZteDeviceInfoModel {
  const ZteDeviceInfoModel({
    this.deviceName,
    this.firmwareVersion,
    this.hardwareVersion,
    this.imei,
    this.uptime,
  });

  final String? deviceName;
  final String? firmwareVersion;
  final String? hardwareVersion;
  final String? imei;
  final String? uptime;

  factory ZteDeviceInfoModel.fromJson(Map<String, dynamic> json) {
    return ZteDeviceInfoModel(
      deviceName: _str(json['device_name']),
      firmwareVersion: _str(json['wa_inner_version']),
      hardwareVersion: _str(json['hardware_version']),
      imei: _str(json['imei']),
      uptime: _str(json['uptime']),
    );
  }

  RouterDeviceInfo toEntity() => RouterDeviceInfo(
        deviceName: deviceName,
        firmwareVersion: firmwareVersion,
        hardwareVersion: hardwareVersion,
        imei: imei,
        uptime: uptime,
      );

  /// ZTE uses empty string for missing values — normalise to null.
  static String? _str(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }
}
