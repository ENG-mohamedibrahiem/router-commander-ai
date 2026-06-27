import 'package:router_commander_ai/features/routers/domain/entities/dsl_information.dart';
import 'package:router_commander_ai/features/routers/data/datasources/zte/protocol/zte_protocol_constants.dart';

/// ZTE DSL field constants.
///
/// classification: ASSUMED — field names inferred from community dumps.
/// fallback: all DSL fields are nullable; return null rather than throw.
const String kZteFieldDslStatus = 'dsl_status';
const String kZteFieldDslUprate = 'dsl_uprate';
const String kZteFieldDslDownrate = 'dsl_downrate';
const String kZteFieldDslUpsnr = 'dsl_upsnr';
const String kZteFieldDslDownsnr = 'dsl_downsnr';
const String kZteFieldDslUpattn = 'dsl_upattn';
const String kZteFieldDslDownattn = 'dsl_downattn';

const List<String> kZteDslInfoCmds = [
  kZteFieldDslStatus,
  kZteFieldDslUprate,
  kZteFieldDslDownrate,
  kZteFieldDslUpsnr,
  kZteFieldDslDownsnr,
  kZteFieldDslUpattn,
  kZteFieldDslDownattn,
];

final class ZteDslInformationModel {
  const ZteDslInformationModel._();

  static DslInformation fromMap(Map<String, dynamic> map) {
    String? field(String key) {
      final v = map[key];
      if (v == null) return null;
      final s = v.toString();
      return s == kZteUnavailableValue ? null : s;
    }

    double? parseDb(String key) {
      final raw = field(key);
      if (raw == null) return null;
      return double.tryParse(raw);
    }

    int? parseKbps(String key) {
      final raw = field(key);
      if (raw == null) return null;
      return int.tryParse(raw);
    }

    return DslInformation(
      status: field(kZteFieldDslStatus) ?? 'unknown',
      upstreamRateKbps: parseKbps(kZteFieldDslUprate),
      downstreamRateKbps: parseKbps(kZteFieldDslDownrate),
      upstreamSnrDb: parseDb(kZteFieldDslUpsnr),
      downstreamSnrDb: parseDb(kZteFieldDslDownsnr),
      upstreamAttenuationDb: parseDb(kZteFieldDslUpattn),
      downstreamAttenuationDb: parseDb(kZteFieldDslDownattn),
      lineMode: null,
    );
  }
}
