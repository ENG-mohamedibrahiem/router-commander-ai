import 'router_brand.dart';

class RouterDeviceInfo {
  const RouterDeviceInfo({
    required this.brand,
    required this.modelName,
    required this.serialNumber,
    required this.hardwareVersion,
    required this.softwareVersion,
    required this.uptime,
    required this.macAddress,
  });

  final RouterBrand brand;
  final String modelName;
  final String? serialNumber;
  final String? hardwareVersion;
  final String? softwareVersion;
  final Duration? uptime;
  final String? macAddress;
}
