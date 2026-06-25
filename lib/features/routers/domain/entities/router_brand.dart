enum RouterBrand {
  zte,
  unknown;

  String get displayName {
    return switch (this) {
      RouterBrand.zte => 'ZTE',
      RouterBrand.unknown => 'Unknown',
    };
  }
}
