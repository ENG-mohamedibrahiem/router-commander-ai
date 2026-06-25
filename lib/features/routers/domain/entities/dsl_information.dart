class DslInformation {
  const DslInformation({
    required this.status,
    required this.downstreamRateKbps,
    required this.upstreamRateKbps,
    required this.downstreamSnrDb,
    required this.upstreamSnrDb,
    required this.downstreamAttenuationDb,
    required this.upstreamAttenuationDb,
    required this.lineMode,
  });

  final String status;
  final int? downstreamRateKbps;
  final int? upstreamRateKbps;
  final double? downstreamSnrDb;
  final double? upstreamSnrDb;
  final double? downstreamAttenuationDb;
  final double? upstreamAttenuationDb;
  final String? lineMode;
}
