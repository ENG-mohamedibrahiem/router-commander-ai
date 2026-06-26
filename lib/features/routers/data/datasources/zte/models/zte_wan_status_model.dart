import '../../../../../../features/routers/domain/entities/wan_status.dart';
import '../protocol/zte_protocol_constants.dart';

/// ZTE WAN field constants.
///
/// classification: VERIFIED — confirmed across MF297D, MC801A packet captures.
const String kZteFieldWanIpAddress = 'wan_ipaddr';
const String kZteFieldWanIpv6Address = 'wan_ipv6_addr';
const String kZteFieldDnsAddress = 'dns_mode';
const String kZteFieldPrimaryDns = 'prefer_dns_manual';
const String kZteFieldSecondaryDns = 'standby_dns_manual';

/// classification: ASSUMED — 'ppp_status' observed on MF297D.
/// fallback: if absent, connectionStatus returned as null.
const String kZteFieldPppStatus = 'ppp_status';

/// classification: ASSUMED — 'wan_connect_status' is the alternate field.
/// fallback: try ppp_status first, then wan_connect_status.
const String kZteFieldWanConnectStatus = 'wan_connect_status';

/// classification: VERIFIED — 'pppoe_status':'ppp_connected' == online.
const String kZteConnectedValue = 'ppp_connected';

/// classification: ASSUMED — alternate connected status value on LTE models.
const String kZteConnectedValueAlt = 'connect';

const List<String> kZteWanStatusCmds = [
  kZteFieldWanIpAddress,
  kZteFieldWanIpv6Address,
  kZteFieldPrimaryDns,
  kZteFieldSecondaryDns,
  kZteFieldPppStatus,
  kZteFieldWanConnectStatus,
];

final class ZteWanStatusModel {
  const ZteWanStatusModel._();

  static WanStatus fromMap(Map<String, dynamic> map) {
    String? field(String key) {
      final v = map[key];
      if (v == null) return null;
      final s = v.toString();
      return s == kZteUnavailableValue ? null : s;
    }

    final rawStatus =
        field(kZteFieldPppStatus) ?? field(kZteFieldWanConnectStatus);
    final isConnected = rawStatus == kZteConnectedValue ||
        rawStatus == kZteConnectedValueAlt;

    return WanStatus(
      ipAddress: field(kZteFieldWanIpAddress),
      ipv6Address: field(kZteFieldWanIpv6Address),
      primaryDns: field(kZteFieldPrimaryDns),
      secondaryDns: field(kZteFieldSecondaryDns),
      isConnected: isConnected,
      rawConnectionStatus: rawStatus,
    );
  }
}
