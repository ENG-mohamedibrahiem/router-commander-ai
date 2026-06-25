class WanStatus {
  const WanStatus({
    required this.connectionStatus,
    required this.ipAddress,
    required this.gateway,
    required this.primaryDns,
    required this.secondaryDns,
    required this.uptime,
    required this.protocol,
  });

  final String connectionStatus;
  final String? ipAddress;
  final String? gateway;
  final String? primaryDns;
  final String? secondaryDns;
  final Duration? uptime;
  final String? protocol;
}
