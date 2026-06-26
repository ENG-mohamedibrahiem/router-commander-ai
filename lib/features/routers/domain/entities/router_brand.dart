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

  /// Matches by [name] (enum key) OR by [displayName] — case-insensitive.
  ///
  /// Examples:
  ///   'zte'       → RouterBrand.zte
  ///   'ZTE'       → RouterBrand.zte
  ///   'TP-Link'   → RouterBrand.tpLink
  ///   'tpLink'    → RouterBrand.tpLink
  ///   'anything'  → RouterBrand.unknown
  static RouterBrand fromString(String value) {
    final lower = value.toLowerCase();
    return RouterBrand.values.firstWhere(
      (b) =>
          b.name.toLowerCase() == lower ||
          b.displayName.toLowerCase() == lower,
      orElse: () => RouterBrand.unknown,
    );
  }
}
