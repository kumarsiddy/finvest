enum HoldingStatus {
  ACTIVE("ACTIVE"),
  MATURED("MATURED"),
  PROCESSING("PROCESSING"),
  SOLD("SOLD"),
  TRANSFERRED("TRANSFERRED"),
  PENDING("PENDING"),
  INACTIVE("INACTIVE");

  final String value;

  const HoldingStatus(this.value);
}
