import 'package:router_commander_ai/features/routers/domain/entities/wifi_information.dart';

/// Maps ZTE JSON fields for WiFi configuration to [WifiInformation].
///
/// Classification: VERIFIED for ssid/auth_mode. ASSUMED for channel fields.
final class ZteWifiModel {
  const ZteWifiModel({
    this.ssid,
    this.authMode,
    this.band,
    this.channel,
    this.enabled,
  });

  final String? ssid;
  final String? authMode;
  final String? band;
  final String? channel;
  final bool? enabled;

  factory ZteWifiModel.fromJson(Map<String, dynamic> json) {
    final enabledRaw = _str(json['wifi_enable']);
    return ZteWifiModel(
      ssid: _str(json['ssid']),
      authMode: _str(json['auth_mode']),
      band: _str(json['wifi_band']),
      channel: _str(json['wifi_channel']),
      enabled: enabledRaw == null ? null : enabledRaw == '1',
    );
  }

  WifiInformation toEntity() => WifiInformation(
        radios: [
          if (ssid != null)
            WifiRadioInformation(
              band: band ?? 'unknown',
              enabled: enabled ?? false,
              ssid: ssid!,
              macAddress: null,
              channel: int.tryParse(channel ?? '') ?? 0,
              securityMode: authMode,
            ),
        ],
      );

  static String? _str(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }
}
