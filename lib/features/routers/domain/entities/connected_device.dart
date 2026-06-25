class ConnectedDevice {
  const ConnectedDevice({
    required this.name,
    required this.ipAddress,
    required this.macAddress,
    required this.interfaceType,
    required this.isActive,
    required this.leaseExpiresAt,
  });

  final String name;
  final String? ipAddress;
  final String? macAddress;
  final String interfaceType;
  final bool isActive;
  final DateTime? leaseExpiresAt;
}
