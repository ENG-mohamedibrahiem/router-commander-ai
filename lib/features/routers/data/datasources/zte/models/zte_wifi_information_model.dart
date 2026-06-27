import 'package:router_commander_ai/features/routers/domain/entities/wifi_information.dart';
import 'package:router_commander_ai/features/routers/data/datasources/zte/protocol/zte_protocol_constants.dart';

/// ZTE WiFi field constants — 2.4 GHz band.
///
/// classification: VERIFIED — confirmed MF297D firmware JS.
const String kZteFieldWifiEnable = 'wifi_enable';
const String kZteFieldWifiSsid = 'ssid';
const String kZteFieldWifiChannel = 'channel';

/// classification: ASSUMED — '5g' prefix for 5 GHz fields observed on MC801A.
/// fallback: 5 GHz fields returned null if absent.
const String kZteFieldWifi5gEnable = 'wifi_5g_enable';
const String kZteFieldWifi5gSsid = 'ssid_5g';
const String kZteFieldWifi5gChannel = 'channel_5g';

/// classification: VERIFIED — '1' == enabled, '0' == disabled.
const String kZteWifiEnabledValue = '1';

const List<String> kZteWifiInfoCmds = [
  kZteFieldWifiEnable,
  kZteFieldWifiSsid,
  kZteFieldWifiChannel,
  kZteFieldWifi5gEnable,
  kZteFieldWifi5gSsid,
  kZteFieldWifi5gChannel,
];

final class ZteWifiInformationModel {
  const ZteWifiInformationModel._();

  static WifiInformation fromMap(Map<String, dynamic> map) {
    String? field(String key) {
      final v = map[key];
      if (v == null) return null;
      final s = v.toString();
      return s == kZteUnavailableValue ? null : s;
    }

    bool isEnabled(String key) => field(key) == kZteWifiEnabledValue;

    return WifiInformation(
      radios: [
        if (field(kZteFieldWifiSsid) != null)
          WifiRadioInformation(
            band: '2.4GHz',
            enabled: isEnabled(kZteFieldWifiEnable),
            ssid: field(kZteFieldWifiSsid)!,
            macAddress: null,
            channel: int.tryParse(field(kZteFieldWifiChannel) ?? '') ?? 0,
            securityMode: null,
          ),
        if (field(kZteFieldWifi5gSsid) != null)
          WifiRadioInformation(
            band: '5GHz',
            enabled: isEnabled(kZteFieldWifi5gEnable),
            ssid: field(kZteFieldWifi5gSsid)!,
            macAddress: null,
            channel: int.tryParse(field(kZteFieldWifi5gChannel) ?? '') ?? 0,
            securityMode: null,
          ),
      ],
    );
  }
}
