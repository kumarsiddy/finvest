enum VerificationStatus {
  NOT_STARTED("not_started"),
  PROCESSING("processing"),
  FAILED("failed"),
  DENIED("denied"),
  SUCCESSFUL("successful"),
  CLOSED("closed");

  final String value;

  const VerificationStatus(this.value);
}
