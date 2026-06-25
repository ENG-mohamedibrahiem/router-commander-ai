import 'router_brand.dart';

class RouterModel {
  const RouterModel({
    required this.brand,
    required this.modelName,
    required this.hardwareVersion,
    required this.firmwareVersion,
  });

  final RouterBrand brand;
  final String modelName;
  final String? hardwareVersion;
  final String? firmwareVersion;

  bool get isKnown => brand != RouterBrand.unknown && modelName.isNotEmpty;
}
