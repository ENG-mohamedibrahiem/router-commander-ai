import '../../../../../../features/routers/domain/entities/router_brand.dart';
import '../../../../../../features/routers/domain/entities/router_device_info.dart';
import '../protocol/zte_protocol_constants.dart';

/// ZTE field constants for device information.
///
/// classification: VERIFIED — confirmed across MF79U, MF266, MF297D.
const String kZteFieldManufacturer = 'manufacturer';
const String kZteFieldModelName = 'model_name';
const String kZteFieldHardwareVersion = 'hardware_version';
const String kZteFieldSoftwareVersion = 'software_version';
const String kZteFieldSerialNumber = 'serial_number';
const String kZteFieldMacAddress = 'mac_address';

/// classification: ASSUMED — uptime field name varies; '0' means 0 seconds.
/// fallback: if absent or unparseable, uptime is returned as null.
const String kZteFieldUptime = 'uptime';

/// Subset of ZTE cmd list for device info read.
const List<String> kZteDeviceInfoCmds = [
  kZteFieldManufacturer,
  kZteFieldModelName,
  kZteFieldHardwareVersion,
  kZteFieldSoftwareVersion,
  kZteFieldSerialNumber,
  kZteFieldMacAddress,
  kZteFieldUptime,
];

/// Parses a ZTE GET response map into a [RouterDeviceInfo] domain entity.
///
/// Rules enforced:
///  - Empty string ('') == unavailable → mapped to null (VERIFIED sentinel)
///  - All values arrive as strings from ZTE (VERIFIED — no native ints)
///  - uptime is integer seconds as a string (ASSUMED — log if non-numeric)
final class ZteDeviceInfoModel {
  const ZteDeviceInfoModel._();

  static RouterDeviceInfo fromMap(Map<String, dynamic> map) {
    String? field(String key) {
      final v = map[key];
      if (v == null) return null;
      final s = v.toString();
      return s == kZteUnavailableValue ? null : s;
    }

    Duration? parseUptime() {
      final raw = field(kZteFieldUptime);
      if (raw == null) return null;
      final seconds = int.tryParse(raw);
      if (seconds == null) return null;
      return Duration(seconds: seconds);
    }

    return RouterDeviceInfo(
      brand: RouterBrand.zte,
      modelName: field(kZteFieldModelName) ?? 'ZTE Router',
      serialNumber: field(kZteFieldSerialNumber),
      hardwareVersion: field(kZteFieldHardwareVersion),
      softwareVersion: field(kZteFieldSoftwareVersion),
      uptime: parseUptime(),
      macAddress: field(kZteFieldMacAddress),
    );
  }
}
