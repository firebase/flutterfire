package io.flutter.plugins.firebaseadmob;

enum AnchorType {
  TOP("AnchorType.top"),
  BOTTOM("AnchorType.bottom");

  private String name;

  AnchorType(final String name) {
    this.name = name;
  }

  static AnchorType fromName(final String name) {
    for (AnchorType type : AnchorType.values()) {
      if (type.name.equals(name)) return type;
    }
    throw new IllegalArgumentException();
  }
}
