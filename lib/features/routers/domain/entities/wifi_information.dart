class WifiInformation {
  const WifiInformation({
    required this.radios,
  });

  final List<WifiRadioInformation> radios;

  bool get hasEnabledRadio => radios.any((radio) => radio.enabled);
}

class WifiRadioInformation {
  const WifiRadioInformation({
    required this.ssid,
    required this.enabled,
    required this.band,
    required this.channel,
    required this.securityMode,
    required this.macAddress,
  });

  final String ssid;
  final bool enabled;
  final String band;
  final int? channel;
  final String? securityMode;
  final String? macAddress;
}
