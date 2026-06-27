import 'package:router_commander_ai/features/routers/domain/entities/dsl_information.dart';

/// Maps ZTE JSON fields for DSL line statistics to [DslInformation].
///
/// Classification: ASSUMED — field names not confirmed on all models.
/// Guard: returns null for every field if absent rather than throwing.
final class ZteDslModel {
  const ZteDslModel({
    this.snrDown,
    this.snrUp,
    this.attenuationDown,
    this.attenuationUp,
    this.syncDown,
    this.syncUp,
    this.lineState,
  });

  final String? snrDown;
  final String? snrUp;
  final String? attenuationDown;
  final String? attenuationUp;
  final String? syncDown;
  final String? syncUp;
  final String? lineState;

  factory ZteDslModel.fromJson(Map<String, dynamic> json) {
    return ZteDslModel(
      snrDown: _str(json['adsl_snr_down']),
      snrUp: _str(json['adsl_snr_up']),
      attenuationDown: _str(json['adsl_attenuation_down']),
      attenuationUp: _str(json['adsl_attenuation_up']),
      syncDown: _str(json['adsl_dsync_dots']),
      syncUp: _str(json['adsl_usync_dots']),
      lineState: _str(json['dsl_state']),
    );
  }

  DslInformation toEntity() => DslInformation(
        status: lineState ?? 'unknown',
        upstreamRateKbps: _parseInt(syncUp),
        downstreamRateKbps: _parseInt(syncDown),
        upstreamSnrDb: _parseDouble(snrUp),
        downstreamSnrDb: _parseDouble(snrDown),
        upstreamAttenuationDb: _parseDouble(attenuationUp),
        downstreamAttenuationDb: _parseDouble(attenuationDown),
        lineMode: null,
      );

  static String? _str(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  static double? _parseDouble(String? s) =>
      s == null ? null : double.tryParse(s);

  static int? _parseInt(String? s) => s == null ? null : int.tryParse(s);
}
