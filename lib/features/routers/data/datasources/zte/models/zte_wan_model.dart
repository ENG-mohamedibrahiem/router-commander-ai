import '../../../../../domain/entities/wan_status.dart';

/// Maps ZTE JSON fields for WAN / internet status to [WanStatus].
///
/// Classification: VERIFIED — ppp_status, ipv4_wan_ipaddr confirmed on MF297D.
final class ZteWanModel {
  const ZteWanModel({
    this.wanState,
    this.wanIp,
    this.wanGateway,
    this.dns,
    this.wanType,
  });

  final String? wanState;
  final String? wanIp;
  final String? wanGateway;
  final String? dns;
  final String? wanType;

  factory ZteWanModel.fromJson(Map<String, dynamic> json) {
    return ZteWanModel(
      wanState: _str(json['ppp_status']),
      wanIp: _str(json['ipv4_wan_ipaddr']),
      wanGateway: _str(json['wan_gateway']),
      dns: _str(json['ipv4_wan_dns1']),
      wanType: _str(json['wan_apn']),
    );
  }

  WanStatus toEntity() => WanStatus(
        isConnected: wanState == 'ppp_connected',
        ipAddress: wanIp,
        gateway: wanGateway,
        dns: dns,
        connectionType: wanType,
      );

  static String? _str(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }
}
