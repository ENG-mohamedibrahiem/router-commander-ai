enum RouterBrand {
  zte,
  tplink,
  unknown;

  String get displayName {
    return switch (this) {
      RouterBrand.zte => 'ZTE',
      RouterBrand.tplink => 'TP-Link',
      RouterBrand.unknown => 'Unknown',
    };
  }
}
