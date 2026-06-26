import 'router_brand.dart';

class RouterModel {
  const RouterModel({
    required this.brand,
    required this.modelName,
    this.hardwareVersion,
    this.firmwareVersion,
  });

  final RouterBrand brand;
  final String modelName;
  final String? hardwareVersion;
  final String? firmwareVersion;

  bool get isKnown => brand != RouterBrand.unknown && modelName.isNotEmpty;

  // ---------------------------------------------------------------------------
  // Well-known model constants
  // ---------------------------------------------------------------------------

  /// Generic ZTE model used by [ZteRouterAdapter] before model detection.
  static const RouterModel zteGeneric = RouterModel(
    brand: RouterBrand.zte,
    modelName: 'ZTE Generic',
  );

  /// Generic TP-Link model placeholder.
  static const RouterModel tpLinkGeneric = RouterModel(
    brand: RouterBrand.tpLink,
    modelName: 'TP-Link Generic',
  );

  /// Sentinel value for an undetected/unknown router.
  static const RouterModel unknown = RouterModel(
    brand: RouterBrand.unknown,
    modelName: 'Unknown',
  );
}
