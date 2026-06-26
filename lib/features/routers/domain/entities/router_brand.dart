/// Enumeration of supported router brands.
///
/// When adding a new brand:
///   1. Add enum value here.
///   2. Implement [RouterAdapter] for it in the data layer.
///   3. Register it in [RouterAdapterFactoryImpl].
enum RouterBrand {
  zte('ZTE', '192.168.1.1'),
  tpLink('TP-Link', '192.168.0.1'),
  unknown('Unknown', '192.168.1.1');

  const RouterBrand(this.displayName, this.defaultGateway);

  final String displayName;
  final String defaultGateway;

  static RouterBrand fromString(String value) {
    return RouterBrand.values.firstWhere(
      (b) => b.name.toLowerCase() == value.toLowerCase(),
      orElse: () => RouterBrand.unknown,
    );
  }
}
